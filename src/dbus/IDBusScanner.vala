/*
 * Copyright (C) 2008-2011 Sebastian Pölsterl
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

namespace DVB {

    [DBus (name = "org.gnome.DVB.Scanner")]
    public interface IDBusScanner : GLib.Object {

        public abstract signal void frequency_scanned (uint frequency, uint freq_left);
        public abstract signal void finished ();
        public abstract signal void channel_added (uint frequency, uint sid,
            string name, string network, string type, bool scrambled);
        public abstract signal void frontend_stats (double signal_strength,
            double signal_noise_ratio);

        public abstract void Run () throws DBusError;
        public abstract void Destroy () throws DBusError;
        public abstract bool WriteAllChannelsToFile (string path) throws DBusError;
        public abstract bool WriteChannelsToFile (uint[] channel_sids, string path) throws DBusError;
        public abstract bool AddScanningData (GLib.HashTable<string, Variant> data) throws DBusError;

        /**
         * @path: Path to file containing scanning data
         * @returns: TRUE when the file has been parsed successfully
         *
         * Parses initial tuning data from a file as provided by dtv-scan-tables
         */
        public abstract bool AddScanningDataFromFile (string path) throws DBusError;
    }
}
