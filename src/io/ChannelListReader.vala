/*
 * Copyright (C) 2008-2010 Sebastian Pölsterl
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
using DVB.Logging;
using GstMpegts;

namespace DVB.io {

    public class ChannelListReader : GLib.Object {

        private static Logger log = LogManager.getLogManager().getDefaultLogger();

        public ChannelList channels {get; construct;}
        public AdapterType Type {get; construct;}

        private KeyFile file;

        public ChannelListReader (ChannelList channels, AdapterType type) {
            base (channels: channels, Type: type);
            this.file = new KeyFile ();
            this.file.set_list_separator (' ');
        }

        public void read_into () throws Error {
            return_if_fail (this.channels.channels_file != null);

            try {
                this.file.load_from_file (this.channels.channels_file.get_path(), KeyFileFlags.NONE);

                foreach (unowned string group in this.file.get_groups ()) {
                    log.debug ("Channel: %s", group);

                    // parse Delivery system stuff
                    Channel c = null;
                    switch (this.file.get_string (group, "DELIVERY_SYSTEM")) {
                        case "DVBT":
                            c = parse_dvb_t (group);
                            break;
                        case "DVBC/ANNEX_A":
                            c = parse_dvb_c (group);
                            break;
                        case "DVBS":
                            c = parse_dvb_s (group);
                            break;
                        default:
                            break;
                    }

                    if (c == null) continue;

                    if (this.file.has_key (group, "SERVICE_ID"))
                        c.Sid = (uint)this.file.get_uint64 (group, "SERVICE_ID");
                    if (this.file.has_key (group, "SERVICE_NAME"))
                        c.Name = this.file.get_string (group, "SERVICE_NAME");
                    if (this.file.has_key (group, "TRANSPORT_STREAM_ID"))
                        c.TransportStreamId = (uint)this.file.get_uint64 (group, "TRANSPORT_STREAM_ID");
                    if (this.file.has_key (group, "SCRAMBLED"))
                        c.Scrambled = this.file.get_boolean (group, "SCRAMBLED");
                    if (this.file.has_key (group, "SERVICE_TYPE"))
                        c.ServiceType = (DVBServiceType)this.file.get_uint64 (group, "SERVICE_TYPE");
                    if (this.file.has_key (group, "VIDEO_PID"))
                        c.VideoPID = (uint)this.file.get_uint64 (group, "VIDEO_PID");
                    if (this.file.has_key (group, "AUDIO_PID")) {
                        uint[] apids = (uint[])this.file.get_integer_list (group, "AUDIO_PID");
                        for (uint i = 0; i < apids.length; i++)
                            c.AudioPIDs.add(apids[i]);
                    }

                    if (c.is_valid ())
                        channels.add (c);
                    else
                        warning ("Could not parse channel");
                }
            } catch (FileError e) {
                log.error ("Can not open channel file: %s", e.message);
            } catch (KeyFileError e) {
                log.error ("%s", e.message);
            }

        }

        private Channel? parse_dvb_t (string group) throws KeyFileError, FileError {
            if (this.Type != AdapterType.TERRESTRIAL) return null;

            Channel c = new Channel (this.channels.GroupId);
            DvbTParameter param = new DvbTParameter.with_parameter ((uint)this.file.get_uint64 (group, "FREQUENCY"),
                (uint)this.file.get_uint64 (group, "BANDWIDTH_HZ"),
                getGuardIntervalEnum (this.file.get_string (group, "GUARD_INTERVAL")),
                getTransmissionModeEnum (this.file.get_string (group, "TRANSMISSION_MODE")),
                getHierarchyEnum (this.file.get_string (group, "HIERARCHY")),
                getModulationEnum (this.file.get_string (group, "MODULATION")),
                getCodeRateEnum (this.file.get_string (group, "CODE_RATE_LP")),
                getCodeRateEnum (this.file.get_string (group, "CODE_RATE_HP")));

            c.Param = param;

            return c;
        }

        private Channel? parse_dvb_s (string group) throws KeyFileError, FileError {
            if (this.Type != AdapterType.SATELLITE) return null;

            Channel c = new Channel (this.channels.GroupId);
            DvbSParameter param = new DvbSParameter.with_parameter ((uint)this.file.get_uint64 (group, "FREQUENCY"),
                (uint)this.file.get_uint64 (group, "SYMBOL_RATE"),
                (float)this.file.get_double (group, "ORBITAL_POSITION"),
                getPolarizationEnum (this.file.get_string (group, "POLARIZATION")),
                getCodeRateEnum (this.file.get_string (group, "INNER_FEC")));

            if (this.file.has_key (group, "SAT_NUMBER"))
                param.DiseqcSource = this.file.get_integer (group, "SAT_NUMBER");

            c.Param = param;

            return c;
        }

        private Channel? parse_dvb_c (string group) throws KeyFileError, FileError {
            if (this.Type != AdapterType.CABLE) return null;

            Channel c = new Channel (this.channels.GroupId);
            DvbCEuropeParameter param = new DvbCEuropeParameter.with_parameter ((uint)this.file.get_uint64 (group, "FREQUENCY"),
                (uint)this.file.get_uint64 (group, "SYMBOL_RATE"),
                getModulationEnum (this.file.get_string (group, "MODULATION")),
                getCodeRateEnum (this.file.get_string (group, "INNER_FEC")));

            c.Param = param;

            return c;
        }

    }

}
