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
    
    public class Manager : Object, IDBusManager {
        
        public Gee.Collection<DeviceGroup> device_groups {
            owned get {
                return this.devices.values;
            }
        }
        
        // Map object path to Scanner
        private HashMap<string, Scanner> scanners;
        
        // Maps device group id to Device
        private HashMap<uint, DeviceGroup> devices;
        
        private uint device_group_counter;
        private GUdev.Client udev_client;
        
        private static Manager instance;
        private static StaticRecMutex instance_mutex = StaticRecMutex ();
        private static const string[] UDEV_SUBSYSTEMS = {"dvb", null};
        
        construct {
            this.scanners = new HashMap<string, Scanner> (GLib.str_hash,
                GLib.str_equal, GLib.direct_equal);
            this.devices = new HashMap<uint, DeviceGroup> ();
            this.device_group_counter = 0;
            this.udev_client = new GUdev.Client (UDEV_SUBSYSTEMS);
            this.udev_client.uevent += this.on_udev_event;
        }
        
        public static unowned Manager get_instance () {
            instance_mutex.lock ();
            if (instance == null) {
                instance = new Manager ();
            }
            instance_mutex.unlock ();
            return instance;
        }
        
        public static void shutdown () {
            instance_mutex.lock ();
            Manager m = instance;
            
            if (instance != null) {
                m.udev_client = null;
                lock (m.scanners) {
                    foreach (Scanner scanner in m.scanners.values) {
                        debug ("Stopping scanner");
                        scanner.do_destroy ();
                    }
                    m.scanners.clear ();
                }
                
                lock (m.devices) {
                    foreach (DeviceGroup devgrp in m.devices.values) {
                        devgrp.destroy ();
                    }
                    m.devices.clear ();
                }
                
                instance = null;
            }
            instance_mutex.unlock ();
        }
        
        /**
         * @adapter: Number of the device's adapter
         * @frontend: Number of the device's frontend
         * @opath: Object path of the scanner service
         * @dbusiface: DBus interface of the scanner service
         * @returns: TRUE on success
         *
         * Get the object path of the channel scanner for this device.
         */
        public bool GetScannerForDevice (uint adapter, uint frontend,
                out DBus.ObjectPath opath, out string dbusiface) throws DBus.Error {
            string path = Constants.DBUS_SCANNER_PATH.printf (adapter, frontend);
            opath = new DBus.ObjectPath (path);
            
            Device device;
            Device? reg_dev = this.get_registered_device (adapter, frontend);
            
            if (reg_dev == null) {
                // Create new device
                device = Device.new_with_type (adapter, frontend);
            } else {
                // Stop epgscanner for device if there's any
                this.get_device_group_of_device (reg_dev).stop_epg_scanner ();
                
                // Assign existing device
                device = reg_dev;
            }

            switch (device.Type) {
                case AdapterType.DVB_T:
                dbusiface = "org.gnome.DVB.Scanner.Terrestrial";
                break;
                
                case AdapterType.DVB_S:
                dbusiface = "org.gnome.DVB.Scanner.Satellite";
                break;
                
                case AdapterType.DVB_C:
                dbusiface = "org.gnome.DVB.Scanner.Cable";
                break;

                default:
                dbusiface = null;
                break;
            }
            
            if (dbusiface == null) {
                critical ("Unknown adapter type");
                dbusiface = "";
                return false;
            }
            
            lock (this.scanners) {
                if (!this.scanners.contains (path)) {
                    Scanner scanner = null;
                    switch (device.Type) {
                        case AdapterType.DVB_T:
                        scanner = new TerrestrialScanner (device);
                        break;
                        
                        case AdapterType.DVB_S:
                        scanner = new SatelliteScanner (device);
                        break;
                        
                        case AdapterType.DVB_C:
                        scanner = new CableScanner (device);
                        break;
                    }
                    
                    if (scanner == null) {
                        critical ("Unknown adapter type");
                        return false;
                    }
                    
                    scanner.destroyed += this.on_scanner_destroyed;
                    
                    this.scanners.set (path, scanner);
                    
                    var conn = Utils.get_dbus_connection ();
                    if (conn == null) return false;
                    
                    conn.register_object (
                        path,
                        scanner);
                    
                    debug ("Created new Scanner D-Bus service for adapter %u, frontend %u (%s)",
                          adapter, frontend, dbusiface);
                }
            }
            
            return true;
        }
        
        /**
         * @group_id: A group ID
         * @path: Device group's DBus path
         * @returns: TRUE on success
         */
        public bool GetDeviceGroup (uint group_id, out DBus.ObjectPath opath)
                throws DBus.Error
        {
            bool ret;
            lock (this.devices) {
                if (this.devices.contains (group_id)) {
                    opath = new DBus.ObjectPath (Constants.DBUS_DEVICE_GROUP_PATH.printf (group_id));
                    ret = true;
                } else {
                    opath = new DBus.ObjectPath ("");
                    ret = false;
                }
            }
            return ret;
        }
        
        /**
         * @returns: Device groups' DBus path
         */
        public DBus.ObjectPath[] GetRegisteredDeviceGroups () throws DBus.Error {
            DBus.ObjectPath[] devs = new DBus.ObjectPath[this.devices.size];
            int i = 0;
            lock (this.devices) {
                foreach (uint key in this.devices.keys) {
                    devs[i] = new DBus.ObjectPath (
                        Constants.DBUS_DEVICE_GROUP_PATH.printf (key));
                    i++;
                }
            }
            return devs;
        }
        
        /**
         * @adapter: Number of the device's adapter
         * @frontend: Number of the device's frontend
         * @channels_conf: Path to channels.conf for this device
         * @recordings_dir: Path where the recordings should be stored
         * @name: Name of group
         * @returns: TRUE when the device has been registered successfully
         *
         * Creates a new DeviceGroup and new DVB device whereas the
         * DVB device is the reference device of this group (i.e.
         * all other devices of this group will inherit the settings
         * of the reference device).
         */
        public bool AddDeviceToNewGroup (uint adapter, uint frontend,
                string channels_conf, string recordings_dir, string name)
                throws DBus.Error
        {   
            File chan_file = File.new_for_path (channels_conf);
            File rec_dir = File.new_for_path (recordings_dir);
            
            Device device;
            try {
                device = Device.new_full (adapter, frontend, chan_file,
                    rec_dir, device_group_counter + 1);
            } catch (DeviceError e) {
            	critical ("Could not create device: %s", e.message);
            	return false;
            }
            
            // Check if device is already assigned to other group
            if (this.device_is_in_any_group (device)) return false;
            
            device_group_counter++;
            
            DeviceGroup devgroup = new DeviceGroup (device_group_counter, device);
            devgroup.Name = name;
            
            this.restore_device_group (devgroup);
            
            this.group_added (device_group_counter);
            
            return true;
        }
        
        /**
         * @adapter: Adapter of device
         * @frontend: Frontend of device
         * @name: The name of the device or "Unknown"
         * @returns: TRUE on success
         *
         * The device must be part of group, otherwise "Unknown"
         * is returned.
         */
        public bool GetNameOfRegisteredDevice (uint adapter, uint frontend,
                out string name) throws DBus.Error
        {
            Device? dev = this.get_registered_device (adapter, frontend);
            
            if (dev == null) {
                name = "";
                return false;
            } else {
                name = dev.Name;
                return true;
            }
        }
        
        /**
         * @returns: the numner of configured device groups
         */
        public int GetDeviceGroupSize () throws DBus.Error {
            return this.devices.size;
        }
        
        /**
         * @returns: ID and name of each channel group
         */
		public ChannelGroupInfo[] GetChannelGroups () throws DBus.Error {
            ConfigStore config = Factory.get_config_store ();
            Gee.List<ChannelGroup> groups;
            try {
                groups = config.get_channel_groups ();
            } catch (SqlError e) {
                critical ("%s", e.message);
                return new ChannelGroupInfo[] {};
            }
            ChannelGroupInfo[] arr = new ChannelGroupInfo[groups.size];
            for (int i=0; i<arr.length; i++) {
                ChannelGroup cg = groups.get (i);
                arr[i] = ChannelGroupInfo ();
                arr[i].id = cg.id;
                arr[i].name = cg.name;
            }
            return arr;
        }

        /**
         * @name: Name of the new group
         * @returns: TRUE on success
         */
		public bool AddChannelGroup (string name, out int channel_group_id) throws DBus.Error {
            ConfigStore config = Factory.get_config_store ();
            bool ret;
            try {
                ret = config.add_channel_group (name, out channel_group_id);
            } catch (SqlError e) {
                critical ("%s", e.message);
                ret = false;
            }
            return ret;
        }

        /**
	     * @channel_group_id: ID of the ChannelGroup
         * @returns: TRUE on success
         */
		public bool RemoveChannelGroup (int channel_group_id) throws DBus.Error {
            ConfigStore config = Factory.get_config_store ();
            bool ret;
            try {
                ret = config.remove_channel_group (channel_group_id);
            } catch (SqlError e) {
                critical ("%s", e.message);
                ret = false;
            }
            return ret;
        }

        /**
         * @returns: informations about all connected
         * devices retrieved via udev
         */
        public GLib.HashTable<string, string>[] GetDevices () throws DBus.Error {
            GLib.List<GUdev.Device> devices = 
                this.udev_client.query_by_subsystem ("dvb");
            var devices_list = new GLib.List<HashTable<string, string>> ();

            for (int i=0; i<devices.length (); i++) {
                GUdev.Device dev = devices.nth_data (i);
                string? device_file = dev.get_device_file ();

                if (device_file == null || !device_file.contains ("frontend"))
                    continue;

                var map = new HashTable<string, string>.full (GLib.str_hash,
                    GLib.str_equal, GLib.g_free, GLib.g_free);
                devices_list.prepend (map);

                map.insert ("device_file", device_file);

                GUdev.Device? parent = dev.get_parent ();
                if (parent != null) {
                    string attr;
                    attr = parent.get_sysfs_attr ("manufacturer");
                    if (attr != null) map.insert ("manufacturer", attr);

                    attr = parent.get_sysfs_attr ("product");
                    if (attr != null) map.insert ("product", attr);
                }
            }

            var arr = new GLib.HashTable<string, string>[devices_list.length ()];
            for (int i=0; i<devices_list.length (); i++) {
                arr[i] = devices_list.nth_data (i);
            }

            return arr;
        }

        /**
         * @returns: Whether the device has been added successfully
         *
         * Register device, create Recorder and ChannelList D-Bus service
         */
        public bool add_device_group (DeviceGroup devgroup) {
            uint group_id = devgroup.Id;
            debug ("Adding device group %u with %d devices", group_id,
                devgroup.size);
            
            if (devgroup.Type == AdapterType.UNKNOWN) {
                warning ("Not adding device group %u of unknown type",
                    devgroup.Id);
                return false;
            }
            
            lock (this.devices) {
                this.devices.set (group_id, devgroup);
            }
            try {
                Factory.get_config_store ().add_device_group (devgroup);
            } catch (SqlError e) {
                critical ("%s", e.message);
                return false;
            }
            devgroup.device_removed += this.on_device_removed_from_group;
            
            // Register D-Bus object
            var conn = Utils.get_dbus_connection ();
            if (conn == null) return false;
            
            string path = Constants.DBUS_DEVICE_GROUP_PATH.printf (group_id);
            conn.register_object (
                path,
                devgroup);
            
            if (group_id > device_group_counter)
                device_group_counter = group_id;

            devgroup.start_epg_scanner ();
            
            return true;
        }

        public bool restore_device_group (DeviceGroup device_group) {
            debug ("Restoring group %u", device_group.Id);

            try {    
                device_group.Channels.load (device_group.Type);
            } catch (Error e) {
            	critical ("Error reading channels from file: %s", e.message);
            	return false;
            }
            
            return this.add_device_group (device_group);
        }
    
        public void restore_timers (DeviceGroup device_group) {
            message ("Restoring timers of device group %u", device_group.Id);
            TimersStore timers_store = Factory.get_timers_store ();

            Gee.List<Timer> timers;
            try {
                timers = timers_store.get_all_timers_of_device_group (
                    device_group);
            } catch (SqlError e) {
                critical ("Failed retrieving timers of group %u: %s",
                    device_group.Id, e.message);
                return;
            }

            uint32 max_id = 0;
            Recorder rec = device_group.recorder;
            foreach (Timer t in timers) {
                if (t.Id > max_id) max_id = t.Id;
                uint32 rec_id;
                if (!rec.add_timer (t, out rec_id)) {
                    try {
                        timers_store.remove_timer_from_device_group (t.Id, device_group);
                    } catch (SqlError e) {
                        critical ("Failed removing timer: %s", e.message);
                    }
                }
            }

            RecordingsStore recstore = RecordingsStore.get_instance ();
            recstore.update_last_id (max_id);
        }

        public void restore_device_group_and_timers (DeviceGroup device_group)
        {
            if (this.restore_device_group (device_group)) {
                this.restore_timers (device_group);
            }
        }
        
        public DeviceGroup? get_device_group_if_exists (uint group_id) {
            DeviceGroup? result = null;
            lock (this.devices) {
                if (this.devices.contains (group_id))
                    result = this.devices.get (group_id);
            }
            return result;
        }
        
        public bool device_is_in_any_group (Device device) {
            bool result = false;
            lock (this.devices) {
                foreach (uint group_id in this.devices.keys) {
                    DeviceGroup devgroup = this.devices.get (group_id);
                    if (devgroup.contains (device)) {
                        result = true;
                        break;
                    }
                }
            }
            return result;
        }
        
        private void on_scanner_destroyed (Scanner scanner) {
            uint adapter = scanner.Device.Adapter;
            uint frontend = scanner.Device.Frontend;
            
            string path = Constants.DBUS_SCANNER_PATH.printf (adapter, frontend);
            lock (this.scanners) {
                this.scanners.remove (path);
            }
            
            debug ("Destroying scanner for adapter %u, frontend %u (%s)", adapter,
                frontend, path);
            
            // Start epgscanner for device again if there was one
            DeviceGroup? devgroup = this.get_device_group_of_device (scanner.Device);
            if (devgroup != null) {
                devgroup.start_epg_scanner ();
            }
        }
        
        private Device? get_registered_device (uint adapter, uint frontend) {
            Device? result = null;
            Device fake_device = new Device (adapter, frontend);
            lock (this.devices) {
                foreach (uint group_id in this.devices.keys) {
                    DeviceGroup devgroup = this.devices.get (group_id);
                    if (devgroup.contains (fake_device)) {
                        foreach (Device device in devgroup) {
                            if (Device.equal (fake_device, device)) {
                                result = device;
                                break;
                            }
                        }
                    }
                }
            }
            
            return result;
        }
        
        private DeviceGroup? get_device_group_of_device (Device device) {
            DeviceGroup? result = null;
            lock (this.devices) {
                foreach (uint group_id in this.devices.keys) {
                    DeviceGroup devgroup = this.devices.get (group_id);
                    if (devgroup.contains (device)) {
                        foreach (Device grp_device in devgroup) {
                            if (Device.equal (grp_device, device)) {
                                result = devgroup;
                                break;
                            }
                        }
                    }
                }
            }
            
            return result;
        }
        
        private void on_device_removed_from_group (DeviceGroup devgroup,
                uint adapter, uint frontend) {
            uint group_id = devgroup.Id;
            if (devgroup.size == 0) {
                bool success;
                lock (this.devices) {
                    success = this.devices.remove (group_id);
                }
                if (success) {
                    devgroup.destroy ();
                    
                    try {
                        Factory.get_config_store ().remove_device_group (
                            devgroup);
                        Factory.get_epg_store ().remove_events_of_group (
                            devgroup.Id
                        );
                        Factory.get_timers_store ().remove_all_timers_from_device_group (
                            devgroup.Id
                        );
                        this.group_removed (group_id);
                    } catch (SqlError e) {
                        critical ("%s", e.message);
                    }
                }
           }
        }

        private void create_device_group_by_id (uint group_id) {
            ConfigStore config_store = Factory.get_config_store ();

            Gee.List<DeviceGroup> groups;
            try {
                groups = config_store.get_all_device_groups ();
            } catch (SqlError e) {
                critical ("Error restoring group %u: %s", group_id,
                    e.message);
                return;
            }
            
            foreach (DeviceGroup group in groups) {
                if (group.Id == group_id) {
                    this.restore_device_group_and_timers (group);
                }
            }
        }

        private void on_udev_event (string action, GUdev.Device device) {
            if (action == "add" || action == "remove") {
                string dev_file = device.get_device_file ();

                uint adapter = -1, frontend = -1;
                if (dev_file.scanf ("/dev/dvb/adapter%u/frontend%u",
                        &adapter, &frontend) != 2)
                    return;

                uint group_id;
                bool found = false;
                ConfigStore config_store = Factory.get_config_store ();
                try {
                    found = config_store.get_parent_group (adapter,
                            frontend, out group_id);
                } catch (SqlError e) {
                    critical ("%s", e.message);
                }
                if (!found)
                    return;

                debug ("%s device %s, part of group %u", action, dev_file,
                    group_id);

                DeviceGroup? group = this.get_device_group_if_exists (group_id);
                if (group != null)
                    group.stop_epg_scanner ();

                if (action == "add") {
                    if (group == null) {
                        /* This is the first device part of the group
                         * that has been added. We have to create the
                         * whole group */
                        this.create_device_group_by_id (group_id);
                    } else {
                        Device dvb_device = Device.new_with_type (adapter,
                            frontend);
                        if (dvb_device == null) return;

                        group.add (dvb_device);
                    }
                } else {
                    Device dvb_device = new Device (adapter, frontend);

                    // FIXME emit signal without removing
                    // the device from the DB
                    group.remove (dvb_device);
                }

                if (group != null)
                    group.start_epg_scanner ();
            }
        }
        
    }

}
