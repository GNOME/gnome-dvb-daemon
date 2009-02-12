using GLib;

namespace DVB {

    [DBus (name = "org.gnome.DVB.Manager")]
    public interface IDBusManager : GLib.Object {
    
        /**
         * @type: 0: added, 1: deleted, 2: updated
         *
         * Emitted when a group has been added or deleted
         */
        public abstract signal void changed (uint group_id, uint change_type);
        
        /**
         * Emitted when a device has been added or removed from a group
         */
        public abstract signal void group_changed (uint group_id, uint adapter,
            uint frontend, uint change_type);
            
        /**
         * @adapter: Number of the device's adapter
         * @frontend: Number of the device's frontend
         * @returns: Object path and interface to the scanner service
         *
         * Get the object path of the channel scanner for this device.
         */
        public abstract string[] GetScannerForDevice (uint adapter, uint frontend);
        
        /**
         * @returns: Device groups' ID
         */
        public abstract uint[] GetRegisteredDeviceGroups ();
        
        /**
         * @group_id: ID of device group
         * @returns: Name of adapter type the group holds
         * or an empty string when group with given id doesn't exist.
         */
        public abstract string GetTypeOfDeviceGroup (uint group_id);
        
        /**
         * @group_id: ID of device group
         * @returns: Object path of the device's recorder
         * 
         * Returns the object path to the device's recorder.
         * The device group must be registered with AddDeviceToNewGroup () first.
         */
        public abstract string GetRecorder (uint group_id);
        
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
        public abstract bool AddDeviceToNewGroup (uint adapter, uint frontend,
                string channels_conf, string recordings_dir, string name);
                
         /**
         * @adapter: Number of the device's adapter
         * @frontend: Number of the device's frontend
         * @group_id: ID of device group
         * @returns: TRUE when the device has been registered successfully
         *
         * Creates a new device and adds it to the specified DeviceGroup.
         * The new device will inherit all settings from the group's
         * reference device.
         */
        public abstract bool AddDeviceToExistingGroup (uint adapter, uint frontend,
                uint group_id);
                
                
        /**
         * @adapter: Number of the device's adapter
         * @frontend: Number of the device's frontend
         * @group_id: ID of device group
         * @returns: TRUE when device has been removed successfully
         *
         * Removes the device from the specified group. If the group contains
         * no devices after the removal it's removed as well.
         */
        public abstract bool RemoveDeviceFromGroup (uint adapter, uint frontend,
                uint group_id);
                
        /**
         * @group_id: ID of device group
         * @returns: Name of specified device group or
         * empty string if group with given ID doesn't exist
         */
        public abstract string GetDeviceGroupName (uint group_id);
        
        /**
         * @group_id: ID of device group
         * @returns: Object path to the ChannelList service for this device
         *
         * The device group must be registered with AddDeviceToNewGroup () first.
         */
        public abstract string GetChannelList (uint group_id);
        
        /**
         * @group_id: ID of device group
         * @returns: List of paths to the devices that are part of
         * the specified group (e.g. /dev/dvb/adapter0/frontend0)
         */
        public abstract string[] GetDeviceGroupMembers (uint group_id);
        
        /**
         * @adapter: Adapter of device
         * @frontend: Frontend of device
         * @returns: The name of the device or "Unknown"
         *
         * The device must be part of group, otherwise "Unknown"
         * is returned.
         */
        public abstract string GetNameOfRegisteredDevice (uint adapter, uint frontend);

        /**
         * @group_id: ID of device group
         * @channel_sid: ID of the channel
         * @returns: Object path to Schedule service
         */
        public abstract string GetSchedule (uint group_id, uint channel_sid);

    }

}
