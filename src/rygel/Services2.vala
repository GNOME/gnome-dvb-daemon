/*
 * Copyright (C) 2009 Sebastian Pölsterl
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

namespace DVB.MediaServer2 {
    
    private static const string SERVICE_NAME = "org.gnome.UPnP.MediaServer2.DVBDaemon";
    private static const string ROOT_PATH = "/org/gnome/UPnP/MediaServer2/DVBDaemon";
    
    private static const string GROUP_PATH = "/org/gnome/UPnP/MediaServer2/DVBDaemon/Group%u";
    private static const string CHANNEL_PATH = GROUP_PATH + "/Channel%u";
    
    /**
     * Holds all device groups
     *
     * It only contains containers only and no items
     */
    public class DeviceGroupsMediaContainer2 : GLib.Object, MediaContainer2, MediaObject2 {
        
        private HashMap<uint, ChannelsMediaContainer2> containers;
        private DBus.ObjectPath path;
        
        construct {
            containers = new  HashMap<uint, ChannelsMediaContainer2> ();
        
            Manager manager = Manager.get_instance ();
            manager.group_added.connect (this.on_device_added);
            manager.group_removed.connect (this.on_device_removed);
            
            this.path = new DBus.ObjectPath (ROOT_PATH);
        }
        
        public void create_container_services () {
            Manager manager = Manager.get_instance ();
            
            foreach (DeviceGroup devgroup in manager.device_groups) {
                this.create_service (devgroup);
            }
        }
        
        private void create_service (DeviceGroup devgroup) {
            debug ("Creating container for device group %u", devgroup.Id);
        
            var conn = Utils.get_dbus_connection ();
            if (conn == null) {
                critical ("Could not get DBus connection");
                return;
            }
            var devgroup_container = new ChannelsMediaContainer2 (
                    devgroup, this.path);
            conn.register_object (
                    devgroup_container.Path,
                    devgroup_container);
            devgroup_container.create_item_services ();
                    
            this.containers.set (devgroup.Id, devgroup_container);
        }
        
        public DBus.ObjectPath Parent {
            owned get {
                // root container => ref to itsself
                return this.path;
            }
        }

        public string Path {
            owned get {
                return ROOT_PATH;
            }
        }
        
        public string DisplayName {
            owned get {
                return "@REALNAME@'s TV on @HOSTNAME@";
            }
        }

        public string Type {
            owned get {
                return "container";
            }
        }

        public uint ItemCount {
            get {
                return 0;
            }
        }

        public uint ChildCount {
            get {
                return ContainerCount;
            }
        }
       
        public uint ContainerCount {
            get {
                return this.containers.size;
            }
        }
        
        public bool Searchable {
            get {
                return false;
            }
        }
     
        public GLib.HashTable<string, Value?>[] ListContainers (
                uint offset, uint max, string[] filter) throws DBus.Error {

            uint num_elements = get_num_elements (this.containers.size, offset, max);
            GLib.HashTable<string, Value?>[] hash =
                new GLib.HashTable<string, Value?>[num_elements];

            int i = 0;
            foreach (ChannelsMediaContainer2 container in this.containers.values) {
                if (i >= offset) {
                    uint index = i - offset;
                    hash[index] = new GLib.HashTable<string, Value?> (GLib.str_hash, GLib.str_equal);
                    hash[index].insert("Path", container.Path);
                    hash[index].insert("DisplayName", container.DisplayName);
                    hash[index].insert("ChildCount", container.ChildCount);
                    hash[index].insert("Searchable", container.Searchable);
                    hash[index].insert("Type", container.Type);
                    hash[index].insert("Parent", this.Path);
                }
                i++;
                if (i >= offset + num_elements)
                    break;
            }

            return hash;
        }

        public GLib.HashTable<string, Value?>[] ListChildren (
                uint offset, uint max, string[] filter) throws DBus.Error {
            return ListContainers(offset, max, filter);
        }

        public GLib.HashTable<string, Value?>[] ListItems (
                uint offset, uint max, string[] filter) throws DBus.Error {
            return new GLib.HashTable<string, Value?>[0];
        }
        
        private void on_device_added (uint group_id) {
            Manager manager = Manager.get_instance ();
            DeviceGroup devgroup = manager.get_device_group_if_exists (group_id);
            this.create_service (devgroup);
            this.Updated ();
        }
        
        private void on_device_removed (uint group_id) {
            this.containers.unset (group_id);
            this.Updated ();
        }
    }
    

    /**
     * Holds a list of channels for a single device group
     *
     * It only contains items only and no containers
     */
    public class ChannelsMediaContainer2 : GLib.Object, MediaContainer2, MediaObject2 {

        public DBus.ObjectPath parent;

        private DeviceGroup device_group;
        private HashMap<uint, ChannelMediaItem2> items;
        
        construct {
            this.items = new HashMap<uint, ChannelMediaItem2> ();
        }
        
        public ChannelsMediaContainer2(DeviceGroup devgroup, DBus.ObjectPath parent) {
            this.device_group = devgroup;
            this.parent = parent;
        }
        
        public void create_item_services () {
            foreach (Channel channel in this.device_group.Channels) {
                this.create_service (channel);
            }
        }
        
        public void create_service (Channel channel) {
            debug ("Creating container for channel %u", channel.Sid);
        
            var conn = Utils.get_dbus_connection ();
            if (conn == null) {
                critical ("Could not get DBus connection");
                return;
            }
            var channel_item = new ChannelMediaItem2 (
                    channel, new DBus.ObjectPath (this.Path));
            conn.register_object (
                    channel_item.Path,
                    channel_item);
                    
            this.items.set (channel.Sid, channel_item);
        }
    
        public DBus.ObjectPath Parent {
            owned get {
                return this.parent;
            }
        }

        public string Path {
            owned get {
                return GROUP_PATH.printf (this.device_group.Id);
            }
        }

        public string DisplayName {
            owned get {
                return this.device_group.Name;
            }
        }
    
        public string Type {
            owned get {
                return "container";
            }
        }

        public uint ChildCount {
            get {
                return ItemCount;
            }
        }

        public uint ItemCount {
            get {
                return this.items.size;
            }
        }

        public uint ContainerCount {
            get {
                return 0;
            }
        }

        public bool Searchable {
            get {
                return false;
            }
        }

        public GLib.HashTable<string, Value?>[] ListItems (
                uint offset, uint max, string[] filter) throws DBus.Error {
        
            uint num_elements = get_num_elements (this.items.size, offset, max);

            GLib.HashTable<string, Value?>[] hash =
                new GLib.HashTable<string, Value?>[num_elements];

            uint i = 0;
            foreach (ChannelMediaItem2 item in this.items.values) {
                if (i >= offset) {
                    uint index = i - offset;
                    hash[index] = new  GLib.HashTable<string, Value?> (GLib.str_hash, GLib.str_equal);
                    hash[index].insert("Path", item.Path);
                    hash[index].insert("DisplayName", item.DisplayName);
                    hash[index].insert("Type", item.Type);
                    hash[index].insert("MIMEType", item.MIMEType);
                    hash[index].insert("URLs", item.URLs);
                    hash[index].insert("Parent", this.Path);
                }
                i++;
                if (i >= offset + num_elements)
                    break;
            }

            return hash;
        }
        
        public GLib.HashTable<string, Value?>[] ListContainers (
                uint offset, uint max, string[] filter) throws DBus.Error {
            return new GLib.HashTable<string, Value?>[0];
        }

        public GLib.HashTable<string, Value?>[] ListChildren (
                uint offset, uint max, string[] filter) throws DBus.Error {
            return ListItems(offset, max, filter);
        }
        
    }
    
    
    /**
     * Holds a single channel
     */
    public class ChannelMediaItem2 : GLib.Object, MediaItem2, MediaObject2 {

        private Channel channel;
        private DBus.ObjectPath parent;

        public ChannelMediaItem2(Channel channel, DBus.ObjectPath parent) {
            this.channel = channel;
            this.parent = parent;
        }
    
        public DBus.ObjectPath Parent {
            owned get {
                return this.parent;
            }
        }

        public string Path {
            owned get {
                return CHANNEL_PATH.printf (channel.GroupId, channel.Sid);
            }
        }

        public string DisplayName {
            owned get {
                return this.channel.Name;
            }
        }
    
         public string[] URLs {
            owned get {
                return new string[] {
                    this.channel.URL
                };
            }
        }
        
        public string MIMEType {
            owned get {
                return "video/mpeg";
            }
        }
        
        public string Type {
            owned get {
                return "video";
            }
        }
    }

    private static uint get_num_elements (int items, uint offset, uint max) {
        uint num_elements;
        if (max > 0) {
            if (max > (items - offset)) {
                num_elements = items - offset;
            } else {
                num_elements = max;
            }
        } else {
            num_elements = items - offset;
        }
        return num_elements;
    }

    private static DeviceGroupsMediaContainer2 root_container;

    public static bool start_rygel_services () {
        try {
            var conn = DBus.Bus.get (DBus.BusType.SESSION);

            dynamic DBus.Object bus = conn.get_object (
                    "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus");

            // try to register service in session bus
            uint request_name_result = bus.RequestName (SERVICE_NAME, (uint) 0);

            if (request_name_result == DBus.RequestNameReply.PRIMARY_OWNER) {
                message ("Creating new Rygel MediaServer D-Bus service");

                root_container = new DeviceGroupsMediaContainer2 ();
                root_container.create_container_services ();

                conn.register_object (
                    root_container.Parent,
                    root_container);
            } else {
                warning ("Rygel MediaServer D-Bus service is already running");
                return false;
            }

        } catch (Error e) {
            critical ("Oops %s", e.message);
            return false;
        }
        return false;
    }

}
