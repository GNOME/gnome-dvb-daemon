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
using Gst;
using Gee;
using DVB.Logging;

namespace DVB {

    public errordomain DeviceError {
        UNKNOWN_TYPE
    }

    public enum AdapterType {
        UNKNOWN,
        TERRESTRIAL,
        SATELLITE,
        CABLE
    }

    public class Device : GLib.Object {

        private static Logger log = LogManager.getLogManager().getDefaultLogger();

        private const int PRIME = 31;

        public uint Adapter { get; construct; }
        public uint Frontend { get; construct; }

        /* Device Path i.e. /dev/dvb/adapter0/frontend0 */
        public string DevFile { get; private set; }

        /* unified ID */
        public string UID { get; private set; }

        public string Name { get; private set; }

        private ArrayList<DvbSrcDelsys> delsys;

        public Device (uint adapter, uint frontend) {
            base (Adapter: adapter, Frontend: frontend);
            setAdapterTypeAndName(adapter, frontend);
        }

        public Device.with_udev (GUdev.Device device, string dev_file,
                uint adapter, uint frontend) {
            base(Adapter: adapter, Frontend: frontend);
            setAdapterTypeAndName(adapter, frontend);

            GUdev.Device parent = device.get_parent ();
            string name = this.Name;

            string tmp = parent.get_property ("ID_MODEL_FROM_DATABASE");
            if (tmp == null)
                this.Name = name;
            else
                this.Name = tmp + ": " + name;
            log.debug("Adding Device: %s", this.Name);
            this.DevFile = dev_file;

            /* Generating UID */
            if (parent.get_subsystem () == "pci") {
                /* UID from PCI */
                string uid = parent.get_property("PCI_SLOT_NAME");
                uid += ":" + parent.get_property("PCI_SUBSYS_ID");
                uid += ":" + name;
                log.debug("UID: %s", uid);
                this.UID = uid;
            } else if (parent.get_subsystem () == "usb") {
                string uid = parent.get_property("ID_SERIAL");
                uid += ":" + name;
                log.debug("UID: %s", uid);
                this.UID = uid;
            }
        }

        public static bool equal (Device dev1, Device dev2) {
            if (dev1 == null || dev2 == null) return false;

            return (dev1.Adapter == dev2.Adapter
                    && dev1.Frontend == dev2.Frontend);
        }

        public static uint hash (Device device) {
            if (device == null) return 0;

            return hash_without_device (device.Adapter, device.Frontend);
        }

        public static uint hash_without_device (uint adapter, uint frontend) {
            return 2 * PRIME + PRIME * adapter + frontend;
        }

        public bool isTerrestrial () {
            foreach (DvbSrcDelsys delsys in this.delsys) {
                switch (delsys) {
                    case DvbSrcDelsys.SYS_DVBT:
                    case DvbSrcDelsys.SYS_DVBT2:
                    case DvbSrcDelsys.SYS_DVBH:
                    case DvbSrcDelsys.SYS_ATSC:
                    case DvbSrcDelsys.SYS_ATSCMH:
                    case DvbSrcDelsys.SYS_ISDBT:
                        return true;
                    default:
                        break;
                }
            }
            return false;
        }

        public bool isCable () {
             foreach (DvbSrcDelsys delsys in this.delsys) {
                switch (delsys) {
                    case DvbSrcDelsys.SYS_DVBC_ANNEX_A:
                    case DvbSrcDelsys.SYS_DVBC_ANNEX_B:
                    case DvbSrcDelsys.SYS_DVBC_ANNEX_C:
                    case DvbSrcDelsys.SYS_ISDBC:
                        return true;
                    default:
                        break;
                }
            }
            return false;
        }

        public bool isSatellite () {
            bool ret = false;
            foreach (DvbSrcDelsys delsys in this.delsys) {
                switch (delsys) {
                   case DvbSrcDelsys.SYS_DVBS:
                   case DvbSrcDelsys.SYS_DVBS2:
                   case DvbSrcDelsys.SYS_ISDBS:
                   case DvbSrcDelsys.SYS_DSS:
                   case DvbSrcDelsys.SYS_TURBO:
                       return true;
                   default:
                       break;
                }
            }
            return ret;
        }

        public bool isDVB () {
            foreach (DvbSrcDelsys delsys in this.delsys) {
                switch (delsys) {
                    case DvbSrcDelsys.SYS_DVBT:
                    case DvbSrcDelsys.SYS_DVBT2:
                    case DvbSrcDelsys.SYS_DVBS:
                    case DvbSrcDelsys.SYS_DVBS2:
                    case DvbSrcDelsys.SYS_DVBC_ANNEX_A:
                    case DvbSrcDelsys.SYS_DVBC_ANNEX_C:
                    case DvbSrcDelsys.SYS_DVBH:
                        return true;
                    default:
                        break;
                }
            }
            return false;
        }

        public bool isATSC () {
            foreach (DvbSrcDelsys delsys in this.delsys) {
                switch (delsys) {
                    case DvbSrcDelsys.SYS_DVBC_ANNEX_B:
                    case DvbSrcDelsys.SYS_ATSC:
                    case DvbSrcDelsys.SYS_ATSCMH:
                        return true;
                    default:
                        break;
                }
            }
            return false;
        }

        public bool isISDB () {
            foreach (DvbSrcDelsys delsys in this.delsys) {
                switch (delsys) {
                    case DvbSrcDelsys.SYS_ISDBT:
                    case DvbSrcDelsys.SYS_ISDBC:
                    case DvbSrcDelsys.SYS_ISDBS:
                        return true;
                    default:
                        break;
                }
            }
            return false;
        }

        public bool isDelsys (DvbSrcDelsys delsys) {
            foreach (DvbSrcDelsys d in this.delsys) {
                if (d == delsys)
                    return true;
            }
            return false;
        }

        public bool is_busy () {
            Element dvbsrc = ElementFactory.make ("dvbsrc", DevFile);
            if (dvbsrc == null) {
                log.error ("Could not create dvbsrc element");
                return true;
            }
            dvbsrc.set ("adapter", this.Adapter);
            dvbsrc.set ("frontend", this.Frontend);

            Element pipeline = new Pipeline ("");
            ((Bin)pipeline).add (dvbsrc);
            pipeline.set_state (State.READY);

            Gst.Bus bus = pipeline.get_bus();

            bool busy_val = false;

            while (bus.have_pending()) {
                Message msg = bus.pop();

                if (msg.type == MessageType.ERROR && msg.src == dvbsrc) {
                    Error gerror;
                    string debug_text;
                    msg.parse_error (out gerror, out debug_text);

                    log.debug ("Error tuning: %s; %s", gerror.message, debug_text);

                    busy_val = true;
                }
            }

            pipeline.set_state(State.NULL);

            return busy_val;
        }

        private bool setAdapterTypeAndName (uint adapter, uint frontend) {
            Element dvbsrc = ElementFactory.make ("dvbsrc", DevFile);
            if (dvbsrc == null) {
                log.error ("Could not create dvbsrc element");
                return false;
            }

            dvbsrc.set ("adapter", adapter);
            dvbsrc.set ("frontend", frontend);

            Element pipeline = new Pipeline ("type_name");
            ((Bin)pipeline).add (dvbsrc);
            pipeline.set_state (State.READY);

            Gst.Bus bus = pipeline.get_bus();

            bool success = false;
            this.delsys = new ArrayList<DvbSrcDelsys> ();

            while (bus.have_pending()) {
                Message msg = bus.pop();

                if (msg.type == MessageType.ELEMENT && msg.src == dvbsrc) {
                    weak Structure structure = msg.get_structure ();

                    if (structure.get_name() == "dvb-adapter") {

                        this.Name = "%s".printf (structure.get_string("name"));

                        if (structure.has_field("dvb-c-a"))
                            this.delsys.add (DvbSrcDelsys.SYS_DVBC_ANNEX_A);

                        if (structure.has_field("dvb-c-b"))
                            this.delsys.add (DvbSrcDelsys.SYS_DVBC_ANNEX_B);

                        if (structure.has_field("dvb-t"))
                            this.delsys.add (DvbSrcDelsys.SYS_DVBT);

                        if (structure.has_field("dss"))
                            this.delsys.add (DvbSrcDelsys.SYS_DSS);

                        if (structure.has_field("dvb-s"))
                            this.delsys.add (DvbSrcDelsys.SYS_DVBS);

                        if (structure.has_field("dvb-s2"))
                            this.delsys.add (DvbSrcDelsys.SYS_DVBS2);

                        if (structure.has_field("dvb-h"))
                            this.delsys.add (DvbSrcDelsys.SYS_DVBH);

                        if (structure.has_field("isdb-t"))
                            this.delsys.add (DvbSrcDelsys.SYS_ISDBT);

                        if (structure.has_field("isdb-s"))
                            this.delsys.add (DvbSrcDelsys.SYS_ISDBS);

                        if (structure.has_field("isdb-c"))
                            this.delsys.add (DvbSrcDelsys.SYS_ISDBC);

                        if (structure.has_field("atsc"))
                            this.delsys.add (DvbSrcDelsys.SYS_ATSC);

                        if (structure.has_field("atsc-mh"))
                            this.delsys.add (DvbSrcDelsys.SYS_ATSCMH);

                        if (structure.has_field("dtmb"))
                            this.delsys.add (DvbSrcDelsys.SYS_DTMB);

                        if (structure.has_field("cmmb"))
                            this.delsys.add (DvbSrcDelsys.SYS_CMMB);

                        if (structure.has_field("dab"))
                            this.delsys.add (DvbSrcDelsys.SYS_DAB);

                        if (structure.has_field("dvb-t2"))
                            this.delsys.add (DvbSrcDelsys.SYS_DVBT2);

                        if (structure.has_field("turbo"))
                            this.delsys.add (DvbSrcDelsys.SYS_TURBO);

                        if (structure.has_field("dvb-c-c"))
                            this.delsys.add (DvbSrcDelsys.SYS_DVBC_ANNEX_C);

                        success = true;
                        break;
                    }
                } else if (msg.type == MessageType.ERROR) {
                    Error gerror;
                    string debug;
                    msg.parse_error (out gerror, out debug);
                    warning ("%s %s", gerror.message, debug);
                }
            }

            pipeline.set_state(State.NULL);

            return success;
        }
    }
}
