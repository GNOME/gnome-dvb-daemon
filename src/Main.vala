using GLib;

public class Main {

    private static DVB.Manager manager;
    private static DVB.RecordingsStore recstore;

    private static bool start_manager () {
        try {
            var conn = DBus.Bus.get (DBus.BusType.SESSION);
            
            dynamic DBus.Object bus = conn.get_object (
                    "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus");
            
            // try to register service in session bus
            uint request_name_result = bus.RequestName (DVB.Constants.DBUS_SERVICE, (uint) 0);

            if (request_name_result == DBus.RequestNameReply.PRIMARY_OWNER) {
                debug ("Creating new Manager D-Bus service");
            
                manager = new DVB.Manager ();
                                
                conn.register_object (
                    DVB.Constants.DBUS_MANAGER_PATH,
                    manager);
            } else {
                debug ("Manager D-Bus service is already running");
                return false;
            }

        } catch (Error e) {
            error ("Oops %s", e.message);
            return false;
        }
        
        return true;
    }
    
    private static bool start_recordings_store (uint32 minimum_id) {
       debug ("Creating new RecordingsStore D-Bus service");
       
       try {
            var conn = DBus.Bus.get (DBus.BusType.SESSION);
        
            recstore = DVB.RecordingsStore.get_instance ();
            recstore.update_last_id (minimum_id);
                            
            conn.register_object (
                DVB.Constants.DBUS_RECORDINGS_STORE_PATH,
                recstore);
        } catch (Error e) {
            error ("Oops %s", e.message);
            return false;
        }
        
        return true;
    }
    
    public static void main (string[] args) {
        MainLoop loop;
    
        // Creating a GLib main loop with a default context
        loop = new MainLoop (null, false);

        // Initializing GStreamer
        Gst.init (ref args);
        
        if (!start_manager ()) return;
        
        uint32 max_id = 0;
        // Restore devices and timers
        var gconf = DVB.GConfStore.get_instance ();
        
        Gee.ArrayList<DVB.DeviceGroup> device_groups = gconf.get_all_device_groups ();
        foreach (DVB.DeviceGroup device_group in device_groups) {
            
            if (manager.add_device_group (device_group)) {
                DVB.Recorder rec = manager.get_recorder_for_device_group (device_group);
            
                Gee.ArrayList<DVB.Timer> timers = gconf.get_all_timers_of_device_group (device_group);
                foreach (DVB.Timer t in timers) {
                    if (t.Id > max_id) max_id = t.Id;
                    if (rec.add_timer (t) == 0)
                        gconf.remove_timer_from_device_group (t.Id, device_group);
                }
            }
        }
        
        if (!start_recordings_store (max_id)) return;
        
        // Start GLib mainloop
        loop.run ();
    }

}
