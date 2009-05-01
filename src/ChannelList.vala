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

namespace DVB {

    public class ChannelList : GLib.Object, Iterable<Channel>, IDBusChannelList {
        
        public File? channels_file {get; construct;}
        public int size {
            get { return this.channels.size; }
        }
        public uint group_id {get; set;}
        
        /**
         * Maps channels' SID to the channels' data
         */
        protected HashMap<uint, Channel> channels;
        
        construct {
            this.channels = new HashMap<uint, Channel> ();
        }
        
        public ChannelList (File? channels=null) {
            this.channels_file = channels;
        }
        
        public Channel? get_channel (uint sid) {
            Channel? val = null;
            lock (this.channels) {
                if (this.channels.contains (sid))
                    val = this.channels.get (sid);
            }
            return val;
        }
        
        public void add (Channel channel) {
            channel.GroupId = group_id;
            lock (this.channels) {
                this.channels.set (channel.Sid, channel);
            }
        }
        
        public void remove (uint sid) {
            lock (this.channels) {
                this.channels.remove (sid);
            }
        }
        
        public bool contains (uint sid) {
            bool val;
            lock (this.channels) {
                val = this.channels.contains (sid);
            }
            return val;
        }
        
        public void clear () {
            lock (this.channels) {
                this.channels.clear ();
            }
        }
        
        public Type get_element_type () {
            return typeof(Channel);
        }
        
        public Iterator<Channel> iterator () {
            return this.channels.get_values().iterator();
        }
        
        public static ChannelList restore_from_file (File channelsfile,
                AdapterType type, uint group_id) throws Error {
            var reader = new DVB.ChannelListReader (channelsfile, type, group_id);
            return reader.read ();
        }
        
        /**
         * @returns: List of channel IDs aka SIDs
         */
        public uint[] GetChannels () {
            uint[] ids = new uint[this.size];
            int i=0;
            lock (this.channels) {
                foreach (uint id in this.channels.get_keys ()) {
                    ids[i] = id;
                    i++;
                }
            }
            
            return ids;
        }
        
        /**
         * @returns: List of channel IDs aka SIDs of radio channels
         */
        public uint[] GetRadioChannels () {
            SList<uint> radio_channels = new SList<uint> ();
            lock (this.channels) {
                foreach (uint id in this.channels.get_keys ()) {
                    Channel chan = this.channels.get (id);
                    if (chan.VideoPID == 0)
                        radio_channels.prepend (id);
                }
            }
            radio_channels.reverse ();
            
            uint[] ids = new uint[radio_channels.length ()];
            for (int i=0; i<radio_channels.length (); i++) {
                ids[i] = radio_channels.nth_data (i);
            }
            
            return ids;
        }
        
        /**
         * @returns: List of channel IDs aka SIDs of TV channels
         */
        public uint[] GetTVChannels () {
            SList<uint> video_channels = new SList<uint> ();
            lock (this.channels) {
                foreach (uint id in this.channels.get_keys ()) {
                    Channel chan = this.channels.get (id);
                    if (chan.VideoPID != 0)
                        video_channels.prepend (id);
                }
            }
            video_channels.reverse ();
            
            uint[] ids = new uint[video_channels.length ()];
            for (int i=0; i<video_channels.length (); i++) {
                ids[i] = video_channels.nth_data (i);
            }
            
            return ids;
        }
        
        /**
         * @channel_id: ID of channel
         * @returns: Name of channel if channel with id exists
         * otherwise an empty string
         */
        public string GetChannelName (uint channel_id) {
            string val = "";
            
            lock (this.channels) {
                if (this.channels.contains (channel_id)) {
                    string name = this.channels.get (channel_id).Name;
                    if (name != null) val = name;
                }
            }
            
            return val;
        }
        
        /**
         * @channel_id: ID of channel
         * @returns: Name of network the channel belongs to
         * if the channel with id exists, otherwise an empty
         * string
         */
        public string GetChannelNetwork (uint channel_id) {
            string val = "";
            lock (this.channels) {
                if (this.channels.contains (channel_id)) {
                    string network = this.channels.get (channel_id).Network;
                    if (network != null) val = network;
                }
            }
            
            return val;
        }
        
        /**
         * @channel_id: ID of channel
         * @returns: Whether the channel is a radio channel or not
         */
        public bool IsRadioChannel (uint channel_id) {
            bool val = false;
            lock (this.channels) {
                if (this.channels.contains (channel_id)) {
                    val = (this.channels.get (channel_id).VideoPID == 0);   
                }
            }
            
            return val;
        }
        
        /**
         * @channel_id: ID of channel
         * @returns: URL to watch the channel
         */
        public string GetChannelURL (uint channel_id) {
            string url = "";
            lock (this.channels) {
                if (this.channels.contains (channel_id)) {
                    Channel channel = this.channels.get (channel_id);
                    url = "rtsp://localhost:8554/%u/%u".printf (
                        this.group_id, channel.Sid);   
                }
            }
            
            return url;
        }
    }

}
