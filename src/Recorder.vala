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
using DVB.database;

namespace DVB {

    /**
     * This class is responsible for managing upcoming recordings and
     * already recorded items for a single group of devices
     */
    public class Recorder : GLib.Object, IDBusRecorder, Iterable<Timer> {

        public unowned DVB.DeviceGroup DeviceGroup { get; construct; }
        
        public uint count {
            get { return this.recordings.size; }
        }
        
        // Contains timer ids
        private Set<uint32> active_timers;
        
        private bool have_check_timers_timeout;
        // Maps timer id to timer
        private HashMap<uint32, Timer> timers;
        // Maps timer id to Recording
        private Map<uint, Recording> recordings;
        
        private static const int CHECK_TIMERS_INTERVAL = 5;
        
        construct {
            this.active_timers = new HashSet<uint32> ();
            this.timers = new HashMap<uint, Timer> ();
            this.have_check_timers_timeout = false;
            RecordingsStore.get_instance ().restore_from_dir (
                this.DeviceGroup.RecordingsDirectory);
            this.recordings = new HashMap<uint, Recording> ();
        }
        
        public Recorder (DVB.DeviceGroup dev) {
            this.DeviceGroup = dev;
        }
        
	public Type element_type { get { return typeof (Timer); } }
    
        public Gee.Iterator<Timer> iterator () {
            return this.timers.values.iterator ();
        }
        
        /**
         * @channel: Channel number
         * @start_year: The year when the recording should start
         * @start_month: The month when recording should start
         * @start_day: The day when recording should start
         * @start_hour: The hour when recording should start
         * @start_minute: The minute when recording should start
         * @duration: How long the channel should be recorded (in minutes)
         * @timer_id: The new timer's id on success, or 0 if timer couldn't
         * be created
         * @returns: TRUE on success
         * 
         * Add a new timer
         */
        public bool AddTimer (uint channel,
                int start_year, int start_month, int start_day,
                int start_hour, int start_minute, uint duration,
                out uint32 timer_id) throws DBus.Error {
            
            Timer new_timer = this.create_timer (channel, start_year, start_month,
                start_day, start_hour, start_minute, duration);
            
            if (new_timer == null) {
                timer_id = 0;
                return false;
            } else {
                return this.add_timer (new_timer, out timer_id);
            }
        }
        
        /**
         * Works the same way as AddTimer() but adds a margin before and
         * after the timer.
         *
         * If the timer with added margins conflicts with a scheduled
         * recording the margins are removed and adding the timer will
         * be tried again.
         */
        public bool AddTimerWithMargin (uint channel,
                int start_year, int start_month, int start_day,
                int start_hour, int start_minute, uint duration,
                out uint32 timer_id) throws DBus.Error {
            
            Timer new_timer = this.create_timer (channel, start_year, start_month,
                start_day, start_hour, start_minute, duration);

            if (new_timer == null) {
                timer_id = 0;
                return false;
            }

            Settings settings = Factory.get_settings ();
            int start_margin = 0;
            uint end_margin = 0;
            try {
                start_margin = -1 * settings.get_integer (
                    Settings.TIMERS_SECTION, Settings.MARGIN_START);
                end_margin = 2 * (uint)settings.get_integer (
                    Settings.TIMERS_SECTION, Settings.MARGIN_END);
                new_timer.Duration += end_margin;
                new_timer.add_to_start_time (start_margin);
            } catch (KeyFileError e) {
                critical ("Could not retrieve start/end margins: %s",
                    e.message);
            }

            bool ret = true;
            if (!this.add_timer (new_timer, out timer_id)) {
                // The timer conflicts, see what happens when we remove margins
                new_timer.Duration -= end_margin;
                new_timer.add_to_start_time (-1*start_margin);
                ret = this.add_timer (new_timer, out timer_id);
            }
            return ret;
        }
        
        public bool add_timer (Timer new_timer, out uint32 timer_id) {
            if (new_timer.has_expired()) return false;

            bool ret = false;
            lock (this.timers) {
                bool has_conflict = false;
                int conflict_count = 0;
                
                // Check for conflicts
                foreach (uint32 key in this.timers.keys) {
                    if (this.timers.get(key).conflicts_with (new_timer)) {
                        conflict_count++;
                        
                        if (conflict_count >= this.DeviceGroup.size) {
                            debug ("Timer is conflicting with another timer: %s",
                                this.timers.get(key).to_string ());
                            has_conflict = true;
                            break;
                        }
                    }
                }
                
                if (!has_conflict) {
                    this.timers.set (new_timer.Id, new_timer);
                    Factory.get_timers_store ().add_timer_to_device_group (new_timer,
                        this.DeviceGroup);
                    this.changed (new_timer.Id, ChangeType.ADDED);
                                   
                    if (this.timers.size == 1 && !this.have_check_timers_timeout) {
                        debug ("Creating new check timers");
                        Timeout.add_seconds (
                            CHECK_TIMERS_INTERVAL, this.check_timers
                        );
                        this.have_check_timers_timeout = true;
                    }
                    
                    timer_id = new_timer.Id;
                    ret = true;
                }
            }
            
            return ret;
        }
        
        /**
         * @event_id: id of the EPG event
         * @channel_sid: SID of channel
         * @timer_id: The new timer's id on success, or 0 if timer couldn't
         * be created
         * @returns: TRUE on success
         */
        public bool AddTimerForEPGEvent (uint event_id, uint channel_sid,
                out uint32 timer_id) throws DBus.Error {
            weak EPGStore epgstore = Factory.get_epg_store ();
            Event? event = null;
            try {
                event = epgstore.get_event (event_id, channel_sid, this.DeviceGroup.Id);
            } catch (SqlError e) {
                critical ("%s", e.message);
            }
            if (event == null) {
                debug ("Could not find event with id %u", event_id);
                timer_id = 0;
                return false;
            }
            Time start = event.get_local_start_time ();
            
            return this.AddTimerWithMargin (channel_sid,
                start.year + 1900, start.month + 1,
                start.day, start.hour, start.minute,
                event.duration / 60, out timer_id);
        }
        
        /**
         * @timer_id: The id of the timer you want to delete
         * @returns: TRUE on success
         *
         * Delete timer. If the id belongs to the currently
         * active timer recording is aborted.
         */
        public bool DeleteTimer (uint32 timer_id) throws DBus.Error {
            bool val;
            lock (this.timers) {
                if (this.timers.contains (timer_id)) {
                    if (this.IsTimerActive (timer_id)) {
                        // Abort recording
                        Timer timer = this.timers.get (timer_id);
                        this.stop_recording (timer);
                    }
                    this.timers.remove (timer_id);
                    Factory.get_timers_store ().remove_timer_from_device_group (
                        timer_id, this.DeviceGroup);
                    this.changed (timer_id, ChangeType.DELETED);
                    val = true;
                } else {
                    val = false;
                }
            }
            return val;
        }
        
        /**
         * dvb_recorder_GetTimers
         * @returns: A list of all timer ids
         */
        public uint32[] GetTimers () throws DBus.Error {
            uint32[] timer_arr;
            lock (this.timers) {
                timer_arr = new uint32[this.timers.size];
                
                int i=0;
                foreach (uint32 key in this.timers.keys) {
                    timer_arr[i++] = this.timers.get(key).Id;
                }
            }
        
            return timer_arr;
        }
        
        /**
         * @timer_id: Timer's id
         * @start_time: An array of length 5, where index 0 = year, 1 = month,
         * 2 = day, 3 = hour and 4 = minute.
         * @returns: TRUE on success
         */
        public bool GetStartTime (uint32 timer_id, out uint32[] start_time)
                throws DBus.Error
        {
            bool ret;
            lock (this.timers) {
                if (this.timers.contains (timer_id)) {
                    start_time = this.timers.get(timer_id).get_start_time ();
                    ret = true;
                } else {
                    start_time = new uint[] {};
                    ret = false;
                }
            }
            return ret;
        }
        
        /**
         * @timer_id: Timer's id
         * @end_time: Same as dvb_recorder_GetStartTime()
         * @returns: TRUE on success
         */
        public bool GetEndTime (uint32 timer_id, out uint[] end_time)
                throws DBus.Error
        {
            bool ret;
            lock (this.timers) {
                if (this.timers.contains (timer_id)) {
                    end_time = this.timers.get(timer_id).get_end_time ();
                    ret = true;
                } else {
                    end_time = new uint[] {};
                    ret = false;
                }
            }
            return ret;
        }
        
        /**
         * @timer_id: Timer's id
         * @duration: Duration in seconds or 0 if there's no timer with
         * the given id
         * @returns: TRUE on success
         */
        public bool GetDuration (uint32 timer_id, out uint duration)
            throws DBus.Error
        {
            bool ret = false;
            lock (this.timers) {
                if (this.timers.contains (timer_id)) {
                    duration = this.timers.get(timer_id).Duration;
                    ret = true;
                }
            }
            return ret;
        }
        
        /**
         * @timer_id: Timer's id
         * @name: The name of the channel the timer belongs to or an
         * empty string when a timer with the given id doesn't exist
         * @returns: TRUE on success
         */
        public bool GetChannelName (uint32 timer_id, out string name)
            throws DBus.Error
        {
            bool ret;
            lock (this.timers) {
                if (this.timers.contains (timer_id)) {
                    Timer t = this.timers.get (timer_id);
                    name = t.Channel.Name;
                    ret = true;
                } else {
                    name = "";
                    ret = false;
                }
            }
            return ret;
        }

        /**
         * @timer_id: Timer's id
         * @title: The name of the show the timer belongs to or an
         * empty string if the timer doesn't exist or has no information
         * about the title of the show
         * @returns: TRUE on success
         */
        public bool GetTitle (uint32 timer_id, out string title)
            throws DBus.Error
        {
            bool ret = false;
            lock (this.timers) {
                if (this.timers.contains (timer_id)) {
                    Timer t = this.timers.get (timer_id);
                    Event? event = t.Channel.Schedule.get_event (t.EventID);
                    if (event != null) {
                        title = event.name;
                        ret = true;
                    }
                }
            }
            if (!ret) title = "";
            return ret;
        }

        public bool GetAllInformations (uint32 timer_id, out TimerInfo info)
                throws DBus.Error
        {
            info = TimerInfo ();
            bool ret = false;
            lock (this.timers) {
                if (this.timers.contains (timer_id)) {
                    Timer t = this.timers.get (timer_id);

                    info.id = timer_id;
                    info.duration = t.Duration;

                    info.active = this.active_timers.contains (timer_id);

                    Channel chan = t.Channel;
                    info.channel_name = chan.Name;

                    Event? event = chan.Schedule.get_event (t.EventID);
                    if (event != null)
                        info.title = event.name;
                    else
                        info.title = "";
                    ret = true;
                }
            }
            return ret;
        }

        /**
         * @returns: The currently active timers
         */
        public uint32[] GetActiveTimers () throws DBus.Error {
            uint32[] val = new uint32[this.active_timers.size];
            
            int i=0;
            foreach (uint32 timer_id in this.active_timers) {
                Timer timer = this.timers.get (timer_id);
                val[i] = timer.Id;
                i++;
            }
            return val;
        }
        
        /**
         * @timer_id: Timer's id
         * @returns: TRUE if timer is currently active
         */
        public bool IsTimerActive (uint32 timer_id) throws DBus.Error {
            return this.active_timers.contains (timer_id);
        }
        
        /**
         * @returns: TRUE if a timer is already scheduled in the given
         * period of time
         */
        public bool HasTimer (uint start_year, uint start_month, uint start_day,
                uint start_hour, uint start_minute, uint duration)
                throws DBus.Error
        {
            bool val = false;
            lock (this.timers) {
                foreach (uint32 key in this.timers.keys) {
                    OverlapType overlap = this.timers.get(key).get_overlap_local (
                        start_year, start_month, start_day, start_hour,
                        start_minute, duration);
                    
                    if (overlap == OverlapType.PARTIAL
                            || overlap == OverlapType.COMPLETE) {
                        val = true;
                        break;
                    }
                }
            }
        
            return val;
        }
        
        public OverlapType HasTimerForEvent (uint event_id, uint channel_sid)
                throws DBus.Error
        {
            weak EPGStore epgstore = Factory.get_epg_store ();
            Event? event = null;
            try {
                event = epgstore.get_event (event_id, channel_sid,
                    this.DeviceGroup.Id);
            } catch (SqlError e) {
                critical ("%s", e.message);
            }
            if (event == null) {
                debug ("Could not find event with id %u", event_id);
                return OverlapType.UNKNOWN;
            }
            
            OverlapType val= OverlapType.NONE;
            lock (this.timers) {
                foreach (uint32 key in this.timers.keys) {
                    Timer timer = this.timers.get (key);
                    
                    if (timer.Channel.Sid == channel_sid) {
                        OverlapType overlap = timer.get_overlap_utc (
                            event.year, event.month, event.day, event.hour,
                            event.minute, event.duration/60);
                        
                        if (overlap == OverlapType.PARTIAL
                                || overlap == OverlapType.COMPLETE) {
                            val = overlap;
                            break;
                        }
                    }
                } 
            }
            
            return val;
        }
        
        public void stop () {
            lock (this.timers) {
                foreach (uint32 timer_id in this.active_timers) {
                    Timer timer = this.timers.get (timer_id);
                    this.stop_recording (timer);
                }
            }
        }

        protected Timer? create_timer (uint channel,
                int start_year, int start_month, int start_day,
                int start_hour, int start_minute, uint duration) {
            debug ("Creating new timer: channel: %u, start: %04d-%02d-%02d %02d:%02d, duration: %u",
                channel, start_year, start_month, start_day,
                start_hour, start_minute, duration);
    
            ChannelList channels = this.DeviceGroup.Channels;
            if (!channels.contains (channel)) {
                warning ("No channel %u for device group %u", channel,
                    this.DeviceGroup.Id);
                return null;
            }
            Schedule schedule = channels.get_channel (channel).Schedule;

            uint32 timer_id = RecordingsStore.get_instance ().get_next_id ();

            var new_timer = new Timer (timer_id,
               this.DeviceGroup.Channels.get_channel (channel),
               start_year, start_month, start_day,
               start_hour, start_minute, duration,
               null);
            // See if we can find an EPG event belonging to this recording
            Event? event = schedule.get_event_around (
                new_timer.get_start_time_time (), duration);
            if (event != null)
                new_timer.EventID = event.id;

            return new_timer;
        }

        /**
         * Start recording of specified timer
         */
        protected void start_recording (Timer timer) {
            Channel channel = timer.Channel;
            
            File? location = this.create_recording_dirs (channel,
                timer.get_start_time ());
            if (location == null) return;

            Gst.Element filesink = Gst.ElementFactory.make ("filesink", null);
            if (filesink == null) {
                critical ("Could not create filesink element");
                return;
            }
            filesink.set ("location", location.get_path ());
            timer.sink = filesink;
            
            ChannelFactory channel_factory = this.DeviceGroup.channel_factory;
            PlayerThread? player = channel_factory.watch_channel (channel,
                filesink, true);
            if (player != null) {
                debug ("Setting pipeline to playing");
                player.get_pipeline().set_state (Gst.State.PLAYING);
                player.eit_structure += this.on_eit_structure;
                
                Recording recording = new Recording ();
                recording.Id = timer.Id;
                recording.ChannelSid = channel.Sid;
                recording.ChannelName = channel.Name;
                recording.StartTime =
                    timer.get_start_time_time ();
                recording.Location = location;
                recording.Name = null;
                recording.Description = null;

                if (timer.EventID != 0) {
                    /* We know the EPG event belonging to this timer,
                     * transfer informations */
                    Event? event = channel.Schedule.get_event (timer.EventID);
                    if (event != null) {
                        debug ("Transfering event information from timer");
                        recording.Name = event.name;
                        recording.Description = "%s\n%s".printf (
                            event.description,
                            event.extended_description);
                    }
                }
                
                lock (this.recordings) {
                    this.recordings.set (recording.Id, recording);
                }
                
                RecordingsStore.get_instance().add (recording, false);
            }
            
            this.active_timers.add (timer.Id);
            
            this.recording_started (timer.Id);
        }
        
        /**
         * Stop recording of specified timer
         */
        protected void stop_recording (Timer timer) {
            Recording rec;
            lock (this.recordings) {
                rec = this.recordings.get (timer.Id);
                rec.Length = Utils.difftime (Time.local (time_t ()),
                    rec.StartTime);

                debug ("Recording of channel %s stopped after %"
                    + int64.FORMAT +" seconds",
                    rec.ChannelName, rec.Length);
                    
                try {
                    rec.save_to_disk ();
                } catch (Error e) {
                    critical ("Could not save recording: %s", e.message);
                }
                ChannelFactory channel_factory = this.DeviceGroup.channel_factory;
                channel_factory.stop_channel (timer.Channel, timer.sink);
                
                this.recordings.remove (timer.Id);
            } 
            uint32 timer_id = timer.Id;
            lock (this.timers) {
                this.active_timers.remove (timer_id);
                this.timers.remove (timer_id);
            }
            RecordingsStore.get_instance().monitor_recording (rec);
            
            this.changed (timer_id, ChangeType.DELETED);
            
            this.recording_finished (rec.Id);
        }
        
        /**
         * @returns: File on success, NULL otherwise
         * 
         * Create directories and set location of recording
         */
        private File? create_recording_dirs (Channel channel, uint[] start) {
            string channel_name = Utils.remove_nonalphanums (channel.Name);
            string time = "%u-%u-%u_%u-%u".printf (start[0], start[1],
                start[2], start[3], start[4]);
            
            File dir = this.DeviceGroup.RecordingsDirectory.get_child (
                channel_name).get_child (time);
            
            if (!dir.query_exists (null)) {
                try {
                    Utils.mkdirs (dir);
                } catch (Error e) {
                    error ("Could not create directory %s: %s",
                        dir.get_path (), e.message);
                    return null;
                }
            }
            
            string attributes = "%s,%s".printf (FILE_ATTRIBUTE_STANDARD_TYPE,
                                                FILE_ATTRIBUTE_ACCESS_CAN_WRITE);
            FileInfo info;
            try {
                info = dir.query_info (attributes, 0, null);
            } catch (Error e) {
                critical ("Could not retrieve attributes: %s", e.message);
                return null;
            }
            
            if (info.get_attribute_uint32 (FILE_ATTRIBUTE_STANDARD_TYPE)
                != FileType.DIRECTORY) {
                critical ("%s is not a directory", dir.get_path ());
                return null;
            }
            
            if (!info.get_attribute_boolean (FILE_ATTRIBUTE_ACCESS_CAN_WRITE)) {
                critical ("Cannot write to %s", dir.get_path ());
                return null;
            }
            
            return dir.get_child ("001.mpeg");
        }
        
        private bool check_timers () {
            debug ("Checking timers");
            
            bool val;
            SList<Timer> ended_recordings =
                new SList<Timer> ();
            lock (this.timers) {
                foreach (uint32 timer_id in this.active_timers) {
                    Timer timer =
                        this.timers.get (timer_id);
                    if (timer.is_end_due()) {
                        ended_recordings.prepend (timer);
                    }
                }

                // Delete timers of recordings that have ended
                for (int i=0; i<ended_recordings.length(); i++) {
                    Timer timer = ended_recordings.nth_data (i);
                    this.stop_recording (timer);
                }

                // Store items we want to delete in here
                SList<uint32> deleteable_items = new SList<uint32> ();

                foreach (uint32 key in this.timers.keys) {
                    Timer timer = this.timers.get (key);

                    debug ("Checking timer: %s", timer.to_string());

                    // Check if we should start new recording and if we didn't
                    // start it before
                    if (timer.is_start_due()
                            && !this.active_timers.contains (timer.Id)) {
                        this.start_recording (timer);
                    } else if (timer.has_expired()) {
                        debug ("Removing expired timer: %s", timer.to_string());
                        deleteable_items.prepend (key);
                    }
                }

                // Delete items from this.timers using this.DeleteTimer
                for (int i=0; i<deleteable_items.length(); i++) {
                    this.DeleteTimer (deleteable_items.nth_data (i));
                }

                if (this.timers.size == 0 && this.active_timers.size == 0) {
                    // We don't have any timers and no recording is in progress
                    debug ("No timers left and no recording in progress");
                    this.have_check_timers_timeout = false;
                    val = false;
                } else {
                    // We still have timers
                    debug ("%d timers and %d active recordings left",
                        this.timers.size,
                        this.active_timers.size);
                    val = true;
                }
            }
            return val;
        }
        
        private void on_eit_structure (PlayerThread player, Gst.Structure structure) {
            uint sid;
            structure.get_uint ("service-id", out sid);
            
            lock (this.recordings) {
                // Find name and description for recordings
                foreach (Recording rec in this.recordings.values) {
                    if (rec.Name == null && sid == rec.ChannelSid) {
                        Channel chan = this.DeviceGroup.Channels.get_channel (sid);
                        Schedule sched = chan.Schedule;
                        
                        Event? event = sched.get_running_event ();
                        if (event != null) {
                            debug ("Found running event for active recording");
                            rec.Name = event.name;
                            rec.Description = "%s\n%s".printf (event.description,
                                event.extended_description);
                        }
                    }
                }
            }
        }
    }

}
