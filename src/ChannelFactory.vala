/*
 * Copyright (C) 2008,2009 Sebastian Pölsterl
 *
 * This file is part of GNOME DVB Daemon.
 *
 * GNOME DVB Daemon is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * GNOME DVB Daemon is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GNOME DVB Daemon.  If not, see <http://www.gnu.org/licenses/>.
 */
using GLib;
using Gee;
using Gst;
using DVB.Logging;
using GstMpegts;

namespace DVB {

    public delegate void ForcedStopNotify (Channel channel);

    /**
     * This class handles watching channels one physical device.
     *
     * It's possible to watch multiple channels at the same time
     * if they are all on the same transport stream.
     *
     * The class is able to reuse channels that are already watched
     * and forward EPG data to #EPGScanner.
     */
    public class PlayerThread : GLib.Object {

        private static Logger log = LogManager.getLogManager().getDefaultLogger();

        private class ChannelElements {
            public uint sid;
            public ArrayList<Gst.Element> sinks;
            public Gst.Element tee;
            public bool forced;
            public unowned ForcedStopNotify notify_func;
        }

        /**
         * Emitted when we came across EIT table
         */
        public signal void eit_structure (Section section);

        // List of channels that are currently in use
        public HashSet<Channel> active_channels {get; construct;}
        // The device in use
        public Device device {get; construct;}
        public DeviceGroup group {get; construct;}
        // Whether watching one of the channels was forced
        public bool forced {
            get {
                bool val = false;
                lock (this.elements_map) {
                    foreach (ChannelElements celem in this.elements_map.values) {
                        if (celem.forced) {
                            val = true;
                            break;
                        }
                    }
                }
                return val;
            }
        }

        private Element? pipeline;
        private HashMap<uint, ChannelElements> elements_map;
        private EPGScanner? epgscanner;
        private Element? dvbbasebin;
        private bool destroyed;

        construct {
            this.elements_map = new HashMap<uint, ChannelElements> ();
            this.active_channels = new HashSet<Channel> ();
            this.destroyed = false;
        }

        /**
         * @device: The device to use
         * @epgscanner: #EPGScanner to forward EIT to
         * @group: #DeviceGroup
         */
        public PlayerThread (Device device, EPGScanner? epgscanner, DeviceGroup group) {
            base (device: device, group: group);
            this.epgscanner = epgscanner;
        }

        public Gst.Element? get_pipeline () {
            return this.pipeline;
        }

        public Gst.Element? get_dvbbasebin () {
            return this.dvbbasebin;
        }

        /**
         * @returns: GstBin containing queue and @sink_element
         *
         * Start watching @channel and link it with @sink_element
         */
        public Gst.Element? get_element (Channel channel, owned Gst.Element sink_element,
                bool forced, ForcedStopNotify? notify_func) {
            uint channel_sid = channel.Sid;
            string channel_sid_str = channel_sid.to_string ();
            bool create_channel;
            Element? bin, tee = null;

            lock (this.pipeline) {
                if (this.pipeline == null) {
                    // New channel and new pipeline
                    log.debug ("Creating new pipeline");

                    // Setup new pipeline
                    this.pipeline = new Pipeline ("recording");

                    Gst.Bus bus = this.pipeline.get_bus();
                    bus.add_signal_watch();
                    bus.message.connect (this.bus_watch_func);

                    this.dvbbasebin = ElementFactory.make ("dvbbasebin", null);
                    if (this.dvbbasebin == null) {
                        log.error ("Could not create dvbbasebin element");
                        return null;
                    }

                    channel.setup_dvb_source (this.dvbbasebin);

                    this.dvbbasebin.set ("program-numbers", channel_sid_str);
                    this.dvbbasebin.set ("adapter", this.device.Adapter);
                    this.dvbbasebin.set ("frontend", this.device.Frontend);

                    // don't use add_many because of problems with ownership transfer
                    ((Bin) this.pipeline).add (this.dvbbasebin);

                    tee = ElementFactory.make ("tee", null);
                    this.add_element (tee);

                    bin = this.add_sink_bin (sink_element);
                    if (bin == null)
                        log.error ("no bin");
                    if (!tee.link (bin)) {
                        log.error ("Could not link tee and bin");
                        return null;
                    }

                    this.link_tee_pad (this.dvbbasebin, tee);

                    create_channel = true;

                } else {
                    // Use current pipeline and add new sink
                    log.debug ("Reusing existing pipeline");
                    if (this.dvbbasebin == null) {
                        log.error ("No dvbbasebin element");
                        return null;
                    }

                    this.pipeline.set_state (State.PAUSED);

                    if (!this.active_channels.contains (channel)) {
                        // existing pipeline and new channel

                        tee = ElementFactory.make ("tee", null);
                        this.add_element (tee);

                        bin = this.add_sink_bin (sink_element);
                        if (!tee.link (bin)) {
                            log.error ("Could not link tee and bin");
                            return null;
                        }

                        string programs;
                        dvbbasebin.get ("program-numbers", out programs);

                        string new_programs = "%s:%s".printf (programs,
                            channel_sid_str);
                        log.debug ("Changing program-numbers from %s to %s", programs,
                            new_programs);
                        this.dvbbasebin.set ("program-numbers", new_programs);

                        create_channel = true;

                    } else { // existing pipeline and existing channel
                        ChannelElements c_element;
                        lock (this.elements_map) {
                            c_element = this.elements_map.get (channel_sid);

                            tee = c_element.tee;

                            bin = this.add_sink_bin (sink_element);

                            log.debug ("Linking %s with %s", tee.get_name (), bin.get_name ());
                            if (!tee.link (bin)) {
                                log.error ("Could not link tee and bin");
                                return null;
                            }

                            c_element.sinks.add (bin);
                        }
                        create_channel = false;
                    }
                }

                if (create_channel) {
                    ChannelElements celems = new ChannelElements ();
                    celems.sid = channel_sid;
                    celems.sinks = new ArrayList<Gst.Element> ();
                    celems.sinks.add (bin);
                    celems.tee = tee;
                    celems.forced = forced;
                    celems.notify_func = notify_func;

                    lock (this.elements_map) {
                        this.elements_map.set (channel_sid, celems);
                    }
                    this.active_channels.add (channel);
                }

                return bin;
            }
        }

        private Gst.Element add_sink_bin (Gst.Element sink_element) {
            Element queue = ElementFactory.make ("queue", null);
            queue.set ("max-size-buffers", 0);

            Gst.Element bin = new Gst.Bin (sink_bin);
            ((Gst.Bin)bin).add_many (queue, sink_element);
            if (!queue.link (sink_element)) {
                log.error ("Could not link elements %s and %s", queue.get_name (),
                    sink_element.get_name ());
            }

            var pad = queue.get_static_pad ("sink");
            var ghost = new Gst.GhostPad ("sink", pad);
            ghost.set_active (true);
            bin.add_pad (ghost);
            /* src pad is ghosted by gst-rtsp-server */

            this.add_element (bin);

            return bin;
        }

        private static int find_element (GLib.Value av, Gst.Element bv) {
            Gst.Element a = (Gst.Element)av;
            Gst.Element b = (Gst.Element)bv;
            if (a == b) return 0;
            else return 1;
        }

        /**
         * @sid: Channel SID
         * @sink: The sink element that the bin should contain
         * @returns: GstBin containing queue and sink for the specified channel
         */
        public Gst.Element? get_sink_bin (uint sid, Gst.Element sink) {
            Gst.Element? result = null;

            log.debug ("Searching for sink %s (%p) of channel %u", sink.get_name (), sink, sid);
            lock (this.elements_map) {
                ChannelElements? celems = this.elements_map.get (sid);
                if (celems != null) {
                    foreach (Gst.Element sink_bin in celems.sinks) {
                        Gst.Iterator it = ((Gst.Bin)sink_bin).iterate_elements ();
                        GLib.Value elem;
                        if (it.find_custom (find_element, out elem, sink)) {
                            result = sink_bin;
                            break;
                        }
                    }
                } else {
                    warning ("Could not find any sinks of channel %u", sid);
                }
            }
            if (result == null)
                log.debug ("Found NO sink");
            else
                log.debug ("Found sink");
            return result;
        }

        /**
         * Stop watching @channel
         */
        public bool remove_channel (Channel channel, Gst.Element sink) {
            uint channel_sid = channel.Sid;

            if (!this.active_channels.contains (channel)) {
                log.error ("Could not find channel with SID %u", channel_sid);
                return false;
            }

            ChannelElements celements;
            bool stop_channel;
            lock (this.elements_map) {
                celements = this.elements_map.get (channel_sid);
                /* check if this is the last sink
                 * (no one watches this channel anymore)
                 * or if we still have sinks left
                 * (others are still watching this channel)
                 */
                stop_channel = (celements.sinks.size == 1);
            }

            lock (this.pipeline) {
                // Check if that's the only channel in use
                if (this.active_channels.size > 1) {

                    if (stop_channel) {
                        string channel_sid_string = channel_sid.to_string ();

                        string programs;
                        dvbbasebin.get ("program-numbers", out programs);
                        string[] programs_arr = programs.split (":");

                        // Remove SID of channel from program-numbers
                        ArrayList<string> new_programs_list = new ArrayList<string> ();
                        for (int i=0; i<programs_arr.length; i++) {
                            if (programs_arr[i] != channel_sid_string)
                                new_programs_list.add (programs_arr[i]);
                        }

                        StringBuilder new_programs = new StringBuilder (new_programs_list.get (0));
                        for (int i=1; i<new_programs_list.size; i++) {
                            new_programs.append (":" + new_programs_list.get (i));
                        }

                        log.debug ("Changing program-numbers from %s to %s", programs,
                                new_programs.str);
                        this.pipeline.set_state (State.PAUSED);

                        dvbbasebin.set ("program-numbers", new_programs.str);

                        if (!this.set_playing_or_destroy ())
                            return false;
                        this.active_channels.remove (channel);
                    }

                    this.remove_sink_bin (channel_sid, sink);

                    if (stop_channel) {
                        /* No one watches the channel anymore */
                        log.debug ("Removing tee %s from pipeline",
                            celements.tee.get_name ());
                        celements.tee.set_state (State.NULL);
                        ((Bin)this.pipeline).remove (celements.tee);
                        lock (this.elements_map) {
                            this.elements_map.unset (channel_sid);
                        }
                    }

                } else { /* More than one channel in use */
                    if (stop_channel) {
                        // this is the last sink
                        // (no one watches any channel anymore)
                        this.destroy ();
                    } else {
                        // we still have sinks left
                        // (others are still watching this channel)
                        this.remove_sink_bin (channel_sid, sink);

                        if (!this.set_playing_or_destroy ())
                            return false;
                    }
                }
            }

            return true;
        }

        private bool set_playing_or_destroy () {
            Gst.StateChangeReturn ret = this.pipeline.set_state (State.PLAYING);
            if (ret == Gst.StateChangeReturn.FAILURE) {
                log.error ("Failed setting pipeline to playing");
                this.destroy ();
                return false;
            }
            return true;
        }

        private void remove_sink_bin (uint channel_sid, Gst.Element sink) {
            log.debug ("Removing sink bin of sink %s (%p) of channel %u",
                sink.get_name (), sink, channel_sid);

            Gst.Element? sink_bin = this.get_sink_bin (channel_sid, sink);

            if (sink_bin == null) {
                log.error ("Could not find sink bin for channel %u and sink %s (%p)",
                    channel_sid, sink.get_name (), sink);
                return;
            }

            lock (this.elements_map) {
                ChannelElements celems = this.elements_map.get (channel_sid);

                log.debug ("Setting state of queue and sink %s (%p) to NULL",
                    sink.get_name (), sink);
                celems.tee.unlink (sink_bin);
                sink_bin.set_state (State.NULL);

                if (!celems.sinks.remove (sink_bin)) {
                    log.error ("Could not find sink bin %s (%p)",
                        sink_bin.get_name (), sink_bin);
                }
            }

            log.debug ("Removing queue and sink from pipeline");
            ((Bin)this.pipeline).remove (sink_bin);
        }

        /**
         * Stop pipeline and clean up everything else
         */
        public virtual void destroy (bool forced=false) {
            if (this.destroyed) return;
            lock (this.destroyed) {
                this.destroyed = true;
                if (forced) {
                    lock (this.elements_map) {
                        foreach (ChannelElements celems in this.elements_map.values) {
                            if (celems.notify_func != null) {
                                Channel channel = this.group.Channels.get_channel (
                                    celems.sid);
                                celems.notify_func (channel);
                            }
                        }
                    }
                }

                lock (this.pipeline) {
                    if (this.pipeline != null) {
                        log.debug ("Stopping pipeline");
                        Gst.Bus bus = this.pipeline.get_bus ();
                        bus.remove_signal_watch ();
                        this.pipeline.set_state (State.NULL);
                    }
                    this.pipeline = null;
                }
                lock (this.elements_map) {
                    this.elements_map.clear ();
                }
                this.active_channels.clear ();
            }
        }

        private bool add_element (owned Gst.Element elem) {
            string elem_name = elem.get_name ();
            if (!((Bin) this.pipeline).add (elem)) {
                log.error ("Could not add element %s", elem_name);
                return false;
            }
            log.debug ("Element %s (%p) added to pipeline", elem_name, elem);
            return true;
        }


        /**
         * Link program_%d pad with tee
         */
        private void link_tee_pad (Gst.Element dvbbasebin, Gst.Element tee) {
            log.debug ("link_tee_pad");

            log.debug ("Linking elements %s and %s", dvbbasebin.get_name(), tee.get_name ());
            Pad srcpad = dvbbasebin.get_static_pad ("src");
            Pad sinkpad = tee.get_static_pad ("sink");

            PadLinkReturn rc = srcpad.link (sinkpad);
            if (rc != PadLinkReturn.OK) {
                log.error ("Could not link pads %s and %s", srcpad.get_name (), sinkpad.get_name ());
            } else {
                log.debug ("Src pad %s linked with sink pad %s", srcpad.get_name (), sinkpad.get_name ());
            }
        }

        /**
         * Forward EIT structure
         */
        private void bus_watch_func (Gst.Bus bus, Gst.Message message) {
            unowned Gst.Structure structure = message.get_structure ();
            switch (message.type) {
                case Gst.MessageType.ELEMENT:
                    Section section = message_parse_mpegts_section(message);

                    if (section != null) {
                        if (section.section_type == SectionType.EIT) {
                            if (this.epgscanner != null)
                                this.epgscanner.on_eit_structure (section);
                            this.eit_structure (section);
                        }
                    }
                    break;
                case Gst.MessageType.WARNING:
                    warning ("%s", structure.to_string ());
                    break;
                case Gst.MessageType.ERROR:
                    log.error ("%s", structure.to_string ());
                    break;
                default:
                break;
            }
        }
    }

    /**
     * This class handles watching channels for a single #DeviceGroup
     */
    public class ChannelFactory : GLib.Object {

        private static Logger log = LogManager.getLogManager().getDefaultLogger();

        // The device group the factory belongs to
        public unowned DeviceGroup device_group {get; construct;}

        // List of players that are currently in use
        private HashSet<PlayerThread> active_players;

        public ChannelFactory (DeviceGroup devgroup) {
            base (device_group: devgroup);
            this.active_players = new HashSet<PlayerThread> ();
        }

        /**
         * Stop all currently active players
         */
        public void destroy () {
            lock (this.active_players) {
                foreach (PlayerThread active_player in this.active_players) {
                    active_player.destroy ();
                }
                this.active_players.clear ();
            }
        }

        /**
         * @channel: channel to watch
         * @sink_element: The element the src pad should be linked with
         * @force: Whether to stop a player when there's currently no free device
         * @notify_func: The given function is called when watching the channel
         *   is aborted because a recording on a different transport streams is
         *   about to start
         * @returns: The #PlayerThread used to watch @channel
         *
         * Watch @channel and use @sink_element as sink element
         */
        public PlayerThread? watch_channel (Channel channel, owned Gst.Element sink_element,
                bool force=false, ForcedStopNotify? notify_func = null) {
            log.debug ("Watching channel %s (%u)", channel.Name, channel.Sid);

            bool create_new = true;
            PlayerThread? player = null;
            DVB.Device? free_device = null;
            lock (this.active_players) {
                foreach (PlayerThread active_player in this.active_players) {
                    foreach (Channel other_channel in active_player.active_channels) {
                        if (channel.on_same_transport_stream (other_channel)) {
                            create_new = false;
                            player = active_player;
                            break;
                        }
                    }
                }
            }

            log.debug ("Creating new PlayerThread: %s", create_new.to_string ());
            if (create_new) {
                // Stop epgscanner before starting recording
                this.device_group.stop_epg_scanner ();

                free_device = this.device_group.get_next_free_device ();
                if (free_device == null && force) {
                    // Stop first player
                    lock (this.active_players) {
                        foreach (PlayerThread active_player in this.active_players) {
                            if (!active_player.forced) {
                                active_player.destroy (true);
                                break;
                            } else {
                                log.error ("No active players that are not forced");
                            }
                        }
                    }
                    free_device = this.device_group.get_next_free_device ();
                }
                if (free_device == null) {
                    log.info ("All devices are busy");
                    return null;
                }

                player = this.create_player (free_device);
            }

            player.get_element (channel, sink_element, force, notify_func);
            lock (this.active_players) {
                this.active_players.add (player);
            }

            return player;
        }

        /**
         * @returns: TRUE on success
         *
         * Stop watching @channel
         */
        public bool stop_channel (Channel channel, Gst.Element sink) {
            log.debug ("Stopping channel %s (%u)", channel.Name, channel.Sid);

            bool success = false;
            PlayerThread? player = null;
            lock (this.active_players) {
                foreach (PlayerThread active_player in this.active_players) {
                    if (active_player.active_channels.contains (channel)) {
                        success = active_player.remove_channel (channel, sink);
                        player = active_player;
                        break;
                    }
                }

                if (success && player.active_channels.size == 0)
                    this.active_players.remove (player);

                if (this.active_players.size == 0) {
                    // Start EPG scanner again
                    this.device_group.start_epg_scanner ();
                }
            }

            return success;
        }

        /**
         * @returns: a new #PlayerThread instance for @device
         */
        public virtual PlayerThread create_player (Device device) {
            return new PlayerThread (device, this.device_group.epgscanner, this.device_group);
        }

    }

}
