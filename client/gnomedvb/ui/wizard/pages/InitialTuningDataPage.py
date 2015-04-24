# -*- coding: utf-8 -*-
# Copyright (C) 2008,2009 Sebastian Pölsterl
#
# This file is part of GNOME DVB Daemon.
#
# GNOME DVB Daemon is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GNOME DVB Daemon is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNOME DVB Daemon.  If not, see <http://www.gnu.org/licenses/>.

import os
import os.path
from gi.repository import Gdk
from gi.repository import Gtk
from gi.repository import GLib
from gi.repository import GObject
import gettext
import locale
from gnomedvb import _
from gnomedvb.ui.wizard.pages.BasePage import BasePage
from gnomedvb import GROUP_TERRESTRIAL
from gnomedvb import GROUP_SATELLITE
from gnomedvb import GROUP_CABLE

DVB_APPS_DIRS = ("/usr/share/dvbv5",)

COUNTRIES = {
    "ad": "Andorra",
    "at": "Austria",
    "az": "Azerbaijan",
    "au": "Australia",
    "be": "Belgium",
    "br": "Brazil",
    "ch": "Switzerland",
    "cz": "Czech Republic",
    "de": "Germany",
    "dk": "Denmark",
    "es": "Spain",
    "fi": "Finland",
    "fr": "France",
    "gr": "Greece",
    "hk": "Hong Kong",
    "hr": "Croatia",
    "hu": "Hungary",
    "ie": "Ireland",
    "il": "Israel",
    "ir": "Iran, Islamic Republic of",
    "is": "Iceland",
    "it": "Italy",
    "lt": "Lithuania",
    "lu": "Luxemburg",
    "lv": "Latvia",
    "nl": "Netherlands",
    "no": "Norway",
    "nz": "New Zealand",
    "pl": "Poland",
    "ro": "Romania",
    "ru": "Russia",
    "se": "Sweden",
    "si": "Slovenia",
    "sk": "Slovakia",
    "tw": "Taiwan",
    "uk": "United Kingdom",
    "vn": "Viet Nam",
}

COUNTRIES_DVB_T = (
    "ad",
    "at",
    "az",
    "au",
    "be",
    "ch",
    "cz",
    "de",
    "dk",
    "es",
    "fi",
    "fr",
    "gr",
    "hk",
    "hr",
    "hu",
    "ie",
    "il",
    "ir",
    "is",
    "it",
    "lt",
    "lu",
    "lv",
    "nl",
    "no",
    "nz",
    "pl",
    "ro",
    "ru",
    "se",
    "si",
    "sk",
    "tw",
    "uk",
    "vn",
)

COUNTRIES_DVB_C = (
    "at",
    "be",
    "br",
    "ch",
    "cz",
    "de",
    "dk",
    "es",
    "fi",
    "fr",
    "hu",
    "lu",
    "nl",
    "no",
    "se",
)

class InitialTuningDataPage(BasePage):

    __gsignals__ = {
            "finished": (GObject.SIGNAL_RUN_LAST, GObject.TYPE_NONE, [bool]),
    }
    NOT_LISTED = "00"

    def __init__(self):
        BasePage.__init__(self)

        self.__adapter_info = None
        self.__page_title = None
        self.__tuning_data = self.NOT_LISTED
        self.__data_dir = None

    def get_page_title(self):
        return self.__page_title

    def set_adapter_info(self, info):
        self.__adapter_info = info
        # skip label
        for widget in self.get_children()[1:]:
            widget.destroy()

        if not self.is_dvb_apps_installed():
            self.__page_title = _("Missing requirements")
            self.setup_dvb_apps_missing()
            return

        if info["type"] == GROUP_TERRESTRIAL:
            self.setup_dvb_t()
            self.__page_title = _("Country and antenna selection")
        elif info["type"] == GROUP_SATELLITE:
            self.setup_dvb_s()
            self.__page_title = _("Satellite selection")
        elif info["type"] == GROUP_CABLE:
            self.setup_dvb_c()
            self.__page_title = _("Country and provider selection")
        else:
            self.__page_title = _("Unsupported adapter")
            self.setup_unknown(info["type"])

    def get_tuning_data(self):
        if self.__tuning_data == self.NOT_LISTED:
            self.add_brute_force_scan()
        return self.__tuning_data

    def _create_table(self):
        self.table = Gtk.Grid(orientation=Gtk.Orientation.VERTICAL)
        self.table.set_row_spacing(6)
        self.table.set_column_spacing(18)
        self.table.show()
        self.pack_start(self.table, True, True, 0)

    def is_dvb_apps_installed(self):
        val = False
        for d in DVB_APPS_DIRS:
            if os.path.exists(d):
                val = True
                break
        return val

    def setup_unknown(self, devtype):
        # translators: first %s is the DVB type, e.g. DVB-S
        text = _("Sorry, but '%s' cards aren't supported.") % devtype
        self._label.set_markup(text)

    def setup_dvb_apps_missing(self):
        text = "<big><b>%s</b></big>\n%s" % (_("Could not find initial tuning data."),
            _("Please make sure that the dvb-apps package is installed."))
        self._label.set_markup(text)

    def setup_dvb_t(self):
        text = "%s %s %s" %(_('Please choose a country and the antenna that is closest to your location.'),
            _("If you don't know which antenna to choose select \"Don't know\" from the list of providers."),
            _("However, searching for channels will take considerably longer this way."))
        self._label.set_markup(text)

        self.providers_view = None

        countries = {self.NOT_LISTED: _("Not listed")}
        t = gettext.translation("iso_3166", fallback=True)
        for lang in COUNTRIES_DVB_T:
            countries[lang] = t.gettext(COUNTRIES[lang])

        self._create_table()

        country = Gtk.Label(halign=Gtk.Align.START)
        country.set_markup_with_mnemonic(_("_Country:"))
        country.show()
        self.table.add(country)

        # name, code
        self.countries = Gtk.ListStore(str, str)
        self.countries.set_sort_column_id(0, Gtk.SortType.ASCENDING)
        self.countries.set_sort_func(0, self.combobox_sort_func)

        for code, name in list(countries.items()):
            self.countries.append([name, code])

        self.country_combo = Gtk.ComboBox.new_with_model_and_entry(self.countries)
        self.country_combo.set_hexpand(True)
        self.country_combo.connect('changed', self.on_country_changed)
        self.__data_dir = "dvb-t"
        cell = Gtk.CellRendererText()
        self.country_combo.pack_start(cell, True)
        self.country_combo.set_entry_text_column(0)
        self.country_combo.show()
        self.table.attach_next_to(self.country_combo, country,
            Gtk.PositionType.RIGHT, 1, 1)
        self.country_combo.set_active(0)
        country.set_mnemonic_widget(self.country_combo)

        providers = Gtk.Label()
        providers.set_markup_with_mnemonic(_("_Antenna:"))
        providers.show()
        self.table.add(providers)

        self.providers = Gtk.ListStore(str, str)
        self.providers.set_sort_column_id(0, Gtk.SortType.ASCENDING)
        self.providers.set_sort_func(0, self.combobox_sort_func, None)

        self.providers_view, scrolledview = self._create_providers_treeview(
            self.providers, _("Antenna"))
        self.providers_view.get_selection().connect('changed',
            self.on_providers_changed)
        providers.set_mnemonic_widget(self.providers_view)

        scrolledview.set_property("expand", True)
        self.table.attach_next_to(scrolledview, providers,
            Gtk.PositionType.BOTTOM, 2, 1)

        self.providers_view.set_sensitive(False)

    def setup_dvb_s(self):

        satellite = Gtk.Label()
        satellite.set_markup_with_mnemonic(_("_Satellite:"))
        satellite.show()
        self.pack_start(satellite, False, False, 0)

        self.satellites = Gtk.ListStore(str, str)
        self.satellites.set_sort_column_id(0, Gtk.SortType.ASCENDING)

        self.satellite_view, scrolledview = self._create_providers_treeview(
            self.satellites, _("Satellite"))
        self.satellite_view.get_selection().connect("changed",
            self.on_satellite_changed)
        satellite.set_mnemonic_widget(self.satellite_view)
        self.pack_start(scrolledview, True, True, 0)

        self.read_satellites()

    def setup_dvb_c(self):
        countries = {}
        t = gettext.translation("iso_3166", fallback=True)
        for lang in COUNTRIES_DVB_C:
            countries[lang] = t.gettext(COUNTRIES[lang])

        self._create_table()

        country = Gtk.Label(halign=Gtk.Align.START)
        country.set_markup_with_mnemonic(_("_Country:"))
        country.show()
        self.table.add(country)

        self.countries = Gtk.ListStore(str, str)
        self.countries.set_sort_column_id(0, Gtk.SortType.ASCENDING)
        self.countries.set_sort_func(0, self.combobox_sort_func, None)

        for code, name in list(countries.items()):
            self.countries.append([name, code])

        self.country_combo = Gtk.ComboBox.new_with_model_and_entry(self.countries)
        self.country_combo.set_hexpand(True)
        self.country_combo.connect('changed', self.on_country_changed)
        self.__data_dir = "dvb-c"
        cell = Gtk.CellRendererText()
        self.country_combo.pack_start(cell, True)
        self.country_combo.set_entry_text_column(0)
        self.country_combo.show()
        self.table.attach_next_to(self.country_combo, country,
            Gtk.PositionType.RIGHT, 1, 1)
        country.set_mnemonic_widget(self.country_combo)

        providers = Gtk.Label()
        providers.set_markup_with_mnemonic(_("_Providers:"))
        providers.show()
        self.table.add(providers)

        self.providers = Gtk.ListStore(str, str)
        self.providers.set_sort_column_id(0, Gtk.SortType.ASCENDING)

        self.providers_view, scrolledview = self._create_providers_treeview(
            self.providers, _("Provider"))
        self.providers_view.get_selection().connect('changed',
            self.on_providers_changed)
        providers.set_mnemonic_widget(self.providers_view)

        scrolledview.set_property("expand", True)
        self.table.attach_next_to(scrolledview, providers,
            Gtk.PositionType.BOTTOM, 2, 1)
        self.providers_view.set_sensitive(False)

    def _create_providers_treeview(self, providers, col_name):
        providers_view = Gtk.TreeView.new_with_model(providers)
        providers_view.set_headers_visible(False)
        col = Gtk.TreeViewColumn(col_name)
        cell = Gtk.CellRendererText()
        col.pack_start(cell, True)
        col.add_attribute(cell, "markup", 0)
        providers_view.append_column(col)
        providers_view.show()

        scrolledview= Gtk.ScrolledWindow()
        scrolledview.add(providers_view)
        scrolledview.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scrolledview.set_shadow_type(Gtk.ShadowType.ETCHED_IN)
        scrolledview.show()

        return providers_view, scrolledview

    def on_country_changed(self, combo):
        aiter = combo.get_active_iter()

        if aiter != None:
            selected_country = self.countries[aiter][1]

            if selected_country == self.NOT_LISTED:
                if self.providers_view:
                    self.providers_view.set_sensitive(False)
                self.emit("finished", True)
            else:
                self.emit("finished", False)
                self.providers.clear()

                toplevel_window = self.get_toplevel().get_window()
                toplevel_window.set_cursor(Gdk.Cursor.new(Gdk.CursorType.WATCH))

                # Fill list async
                GObject.idle_add(self._fill_providers, selected_country)

    def _fill_providers(self, selected_country):
        # Only DVB-T has bruteforce scan
        if self.__adapter_info["type"] == GROUP_TERRESTRIAL:
            self.providers.append([_("Don't know"), self.NOT_LISTED])

        for d in DVB_APPS_DIRS:
            if os.access(d, os.F_OK | os.R_OK):
                for f in os.listdir(os.path.join(d, self.__data_dir)):
                    values = f.split('-', 1)
                    if len(values) != 2:
                        continue
                    country, city = values

                    if country == selected_country:
                        self.providers.append([city,
                            os.path.join(d, self.__data_dir, f)])

        self.providers_view.set_sensitive(True)
        first_iter = self.providers.get_iter_first()
        self.providers_view.get_selection().select_iter(first_iter)

        self.get_toplevel().get_window().set_cursor(None)
        self.emit("finished", True)

        return False

    def on_providers_changed(self, selection):
        model, aiter = selection.get_selected()

        if aiter != None:
            self.__tuning_data = self.providers[aiter][1]
            self.emit("finished", True)

    def read_satellites(self):
        for d in DVB_APPS_DIRS:
            if os.access(d, os.F_OK | os.R_OK):
                for f in os.listdir(os.path.join(d, 'dvb-s')):
                    self.satellites.append([f, os.path.join(d, 'dvb-s', f)])

    def on_satellite_changed(self, selection):
        model, aiter = selection.get_selected()

        if aiter != None:
            self.__tuning_data = self.satellites[aiter][1]
            self.emit("finished", True)

    def on_scan_all_toggled(self, checkbutton):
        state = not checkbutton.get_active()
        self.country_combo.set_sensitive(state)
        self.providers_view.set_sensitive(state)
        self.add_brute_force_scan()
        self.emit("finished", not state)

    def add_brute_force_scan(self):
        self.__tuning_data = []
        for chan in range(5, 13):
            freq = 142500000 + chan * 7000000
            self.__tuning_data.append(self.create_parameters_dict(freq, 7))

        for chan in range(21, 70):
            freq = 306000000 + chan * 8000000
            self.__tuning_data.append(self.create_parameters_dict(freq, 8))

    def create_parameters_dict(self, freq, bandwidth):
        return {"frequency": GLib.Variant('u', freq),
            "delsys": GLib.Variant('s', "DVBT"),
            "hierarchy": GLib.Variant('s', "AUTO"),
            "bandwidth": GLib.Variant('u', bandwidth),
            "transmission-mode": GLib.Variant('s', "QAM/AUTO"),
            "code-rate-hp": GLib.Variant('s', "AUTO"),
            "code-rate-lp": GLib.Variant('s', "AUTO"),
            "constellation": GLib.Variant('s', "AUTO"),
            "guard-interval": GLib.Variant('s', "AUTO")}

    def combobox_sort_func(self, model, iter1, iter2, user_data):
        name1, code1 = model[iter1]
        name2, code2 = model[iter2]

        if code1 == self.NOT_LISTED:
            return -1
        elif code2 == self.NOT_LISTED:
            return 1
        else:
            return locale.strcoll(name1, name2)
