# -*- coding: utf-8 -*-
import os
import os.path
import gtk
import gobject
from gettext import gettext as _
from BasePage import BasePage

DVB_APPS_DIRS = ("/usr/share/dvb",
				 "/usr/share/dvb-apps",
				 "/usr/share/doc/dvb-utils/examples/scan")

class InitialTuningDataPage(BasePage):
	
	__gsignals__ = {
		    "finished": (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, []),
	}

	def __init__(self):
		BasePage.__init__(self)
		
		self.__adapter_info = None
		self.__tuning_data = []
		
	def set_adapter_info(self, info):
		self.__adapter_info = info
		
		for widget in self.get_children():
			widget.destroy()
			
		if info["type"] == "DVB-T":
			self.setup_dvb_t()
		elif info["type"] == "DVB-S":
			self.setup_dvb_s()
		elif info["type"] == "DVB-C":
			self.setup_dvb_c()
			
	def get_tuning_data(self):
		return self.__tuning_data
		
	def _create_table(self):
		self.table = gtk.Table(rows=4, columns=2)
		self.table.set_row_spacings(6)
		self.table.set_col_spacings(3)
		self.table.show()
		self.pack_start(self.table)
		
	def setup_dvb_t(self):
		countries = { "at": _("Austria"), "au": _("Australia"), "be": _("Belgium"),
 	        "ch": _("Switzerland"), "cz": _("Czech Republic"), "de": _("Germany"),
 	        "dk": _("Denmark"), "es": _("Spain"), "fi": _("Finland"), "fr": _("France"),
 	        "gr": _("Greece"), "hr": _("Hungary"), "is": _("Iceland"), "it": _("Italy"),
 	        "lu": _("Luxemburg"), "nl": _("Netherlands"), "nz": _("New Zealand"),
 	        "pl": _("Poland"), "se": _("Sweden"), "sk": _("Slovakia"), "tw": _("Taiwan"),
 	        "uk": _("United Kingdom") }
	
		self._create_table()
		
		country = gtk.Label()
		country.set_markup(_("<b>Country:</b>"))
		country.show()
		self.table.attach(country, 0, 1, 0, 1, yoptions=0)
	
		self.countries = gtk.ListStore(str, str)
		self.countries.set_sort_column_id(0, gtk.SORT_ASCENDING)
		
		for code, name in countries.items():
			self.countries.append([name, code])
	
		self.country_combo = gtk.ComboBox(self.countries)
		self.country_combo.connect('changed', self.on_country_changed, "dvb-t")
		cell = gtk.CellRendererText()
		self.country_combo.pack_start(cell)
		self.country_combo.add_attribute(cell, "text", 0)
		self.country_combo.show()
		self.table.attach(self.country_combo, 1, 2, 0, 1, yoptions=0)
		
		self.providers_label = gtk.Label()
		self.providers_label.set_markup(_("<b>Antenna:</b>"))
		self.providers_label.hide()
		self.table.attach(self.providers_label, 0, 1, 1, 2, yoptions=0)
		
		self.providers = gtk.ListStore(str, str)
		self.providers.set_sort_column_id(0, gtk.SORT_ASCENDING)
		
		self.providers_combo = gtk.ComboBox(self.providers)
		self.providers_combo.connect('changed', self.on_providers_changed)
		cell = gtk.CellRendererText()
		self.providers_combo.pack_start(cell)
		self.providers_combo.add_attribute(cell, "text", 0)
		self.table.attach(self.providers_combo, 1, 2, 1, 2, yoptions=0)
		self.providers_combo.hide()
		
	def setup_dvb_s(self):
		hbox = gtk.HBox(spacing=6)
		hbox.show()
		self.pack_start(hbox, False)
		
		satellite = gtk.Label()
		satellite.set_markup(_("<b>Satellite:</b>"))
		satellite.show()
		hbox.pack_start(satellite, False, False, 0)
		
		self.satellites = gtk.ListStore(str, str)
		self.satellites.set_sort_column_id(0, gtk.SORT_ASCENDING)
		
		self.satellite_combo = gtk.ComboBox(self.satellites)
		self.satellite_combo.connect("changed", self.on_satellite_changed)
		cell = gtk.CellRendererText()
		self.satellite_combo.pack_start(cell)
		self.satellite_combo.add_attribute(cell, "text", 0)
		self.satellite_combo.show()
		hbox.pack_start(self.satellite_combo, False, False, 0)
		
		self.read_satellites()
		
	def setup_dvb_c(self):
		countries = { "at": _("Austria"), "be": _("Belgium"),
 	        "ch": _("Switzerland"), "de": _("Germany"), "fi": _("Finland"),
 	        "lu": _("Luxemburg"), "nl": _("Netherlands"), "se": _("Sweden"),
 	        "no": _("Norway")
 	        }
 	   	
		self._create_table()	
 	   	
		country = gtk.Label()
		country.set_markup(_("<b>Country:</b>"))
		country.show()
		self.table.attach(country, 0, 1, 0, 1, yoptions=0)
	
		self.countries = gtk.ListStore(str, str)
		self.countries.set_sort_column_id(0, gtk.SORT_ASCENDING)
		
		for code, name in countries.items():
			self.countries.append([name, code])
	
		self.country_combo = gtk.ComboBox(self.countries)
		self.country_combo.connect('changed', self.on_country_changed, "dvb-c")
		cell = gtk.CellRendererText()
		self.country_combo.pack_start(cell)
		self.country_combo.add_attribute(cell, "text", 0)
		self.country_combo.show()
		self.table.attach(self.country_combo, 1, 2, 0, 1, yoptions=0)
		
		self.providers_label = gtk.Label()
		self.providers_label.set_markup(_("<b>Providers:</b>"))
		self.providers_label.hide()
		self.table.attach(self.providers_label, 0, 1, 1, 2, yoptions=0)
		
		self.providers = gtk.ListStore(str, str)
		self.providers.set_sort_column_id(0, gtk.SORT_ASCENDING)
		
		self.providers_combo = gtk.ComboBox(self.providers)
		self.providers_combo.connect('changed', self.on_providers_changed)
		cell = gtk.CellRendererText()
		self.providers_combo.pack_start(cell)
		self.providers_combo.add_attribute(cell, "text", 0)
		self.table.attach(self.providers_combo, 1, 2, 1, 2, yoptions=0)
		self.providers_combo.hide()
	
	def on_country_changed(self, combo, directory):
		aiter = combo.get_active_iter()
		
		if aiter != None:
			selected_country = self.countries[aiter][1]
	
			self.providers.clear()
			for d in DVB_APPS_DIRS:
				if os.access(d, os.F_OK | os.R_OK):
					for f in os.listdir(os.path.join(d, directory)):
						country, city = f.split('-', 1)
					
						if country == selected_country:
							self.providers.append([city, os.path.join(d, directory, f)])
		
			self.providers_label.show()
			self.providers_combo.show()
		
	def on_providers_changed(self, combo):
		aiter = combo.get_active_iter()
		
		if aiter != None:
			self.__tuning_data = self.providers[aiter][1]
			self.emit("finished")
	
	def read_satellites(self):
		for d in DVB_APPS_DIRS:
				if os.access(d, os.F_OK | os.R_OK):
					for f in os.listdir(os.path.join(d, 'dvb-s')):
						self.satellites.append([f, os.path.join(d, 'dvb-s', f)])
						
	def on_satellite_changed(self, combo):
		aiter = combo.get_active_iter()
		
		if aiter != None:
			self.__tuning_data = self.satellites[aiter][1]
			self.emit("finished")

