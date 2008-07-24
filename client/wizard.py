#!/usr/bin/env python
# -*- coding: utf-8 -*-
import gtk
import gobject
import gnomedvb
import dbus
import re

HAL_MANAGER_IFACE = "org.freedesktop.Hal.Manager"
HAL_DEVICE_IFACE = "org.freedesktop.Hal.Device"
HAL_MANAGER_PATH = "/org/freedesktop/Hal/Manager"
HAL_SERVICE = "org.freedesktop.Hal"

SUPPORTED_DVB_TYPES = ("DVB-C", "DVB-S", "DVB-T")

class BasePage(gtk.VBox):

	def __init__(self):
		gtk.VBox.__init__(self, False, 5)
		self.set_border_width(5)

class IntroPage(BasePage):
	
	def __init__(self):
		BasePage.__init__(self)
		self.set_border_width(5)
		
		text = "This wizard will guide you through the process of setting up your DVB cards."
		label = gtk.Label(text)
		label.set_line_wrap(True)
		self.pack_start(label)
		
class AdaptersPage(BasePage):
	
	def __init__(self):
		BasePage.__init__(self)
		
		self.adapter_pattern = re.compile("adapter(\d+?)/frontend(\d+?)")
		
		text = "Select device you want to scan channels."
		label = gtk.Label(text)
		label.set_line_wrap(True)
		self.pack_start(label)
		
		self.deviceslist = gtk.ListStore(str, str, int, int)
		self.get_dvb_devices()
		
		self.devicesview = gtk.TreeView(self.deviceslist)
		
		cell_name = gtk.CellRendererText()
		col_name = gtk.TreeViewColumn("Name")
		col_name.pack_start(cell_name)
		col_name.add_attribute(cell_name, "text", 0)
		self.devicesview.append_column(col_name)
		
		cell_type = gtk.CellRendererText()
		col_type = gtk.TreeViewColumn("Type")
		col_type.pack_start(cell_type)
		col_type.add_attribute(cell_type, "text", 1)
		self.devicesview.append_column(col_type)
		
		scrolledview = gtk.ScrolledWindow()
		scrolledview.set_shadow_type(gtk.SHADOW_ETCHED_IN)
		scrolledview.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		scrolledview.add(self.devicesview)
		
		self.pack_start(scrolledview)
		
	def get_selected_device(self):
		model, aiter = self.devicesview.get_selection().get_selected()
		if aiter != None:
			return None
		else:
			return model[aiter]
		
	def get_dvb_devices(self):
		bus = dbus.SystemBus()
		# Get proxy object
		proxy = bus.get_object(HAL_SERVICE, HAL_MANAGER_PATH)
		# Apply the correct interace to the proxy object
		halmanager = dbus.Interface(proxy, HAL_MANAGER_IFACE)
		objects = halmanager.FindDeviceByCapability("dvb")

		for o in objects:
			proxy = bus.get_object(HAL_SERVICE, o)
			dev = dbus.Interface(proxy, HAL_DEVICE_IFACE)
			#for key, val in dev.GetAllProperties().items():
			#	print key, " - ", val
			dev_file = dev.GetProperty("linux.device_file")
			
			match = self.adapter_pattern.search(dev_file)
			if match != None:
				adapter = int(match.group(1))
				frontend = int(match.group(2))
				info = gnomedvb.get_adapter_info(adapter)
				if info["type"] in SUPPORTED_DVB_TYPES:
					self.deviceslist.append([info["name"], info["type"], adapter, frontend])

class ChannelScanPage(BasePage):

	__gsignals__ = {
        "finished": (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, []),
    }

	def __init__(self):
		BasePage.__init__(self)
		
		self.label = gtk.Label()
		self.label.set_line_wrap(True)
		self.pack_start(self.label)
		
		hbox = gtk.HBox(spacing=12)
		hbox.set_border_width(6)
		self.pack_start(hbox)
		
		# TV
		self.tvchannels = gtk.ListStore(str, int)
		self.tvchannelsview = gtk.TreeView(self.tvchannels)
		
		cell_name = gtk.CellRendererText()
		col_name = gtk.TreeViewColumn("Name")
		col_name.pack_start(cell_name)
		col_name.add_attribute(cell_name, "markup", 0)
		self.tvchannelsview.append_column (col_name)
		
		cell_freq = gtk.CellRendererText()
		col_freq = gtk.TreeViewColumn("Frequency")
		col_freq.pack_start(cell_freq, False)
		col_freq.add_attribute(cell_freq, "text", 1)
		self.tvchannelsview.append_column (col_freq)
		
		scrolledtvview = gtk.ScrolledWindow()
		scrolledtvview.set_border_width(6)
		scrolledtvview.add(self.tvchannelsview)
		scrolledtvview.set_shadow_type(gtk.SHADOW_ETCHED_IN)
		scrolledtvview.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)

		tvframe = gtk.Frame("TV channels")
		tvframe.add(scrolledtvview)
		
		hbox.pack_start(tvframe)
		
		# Radio
		self.radiochannels = gtk.ListStore(str, int)
		self.radiochannelsview = gtk.TreeView(self.radiochannels)
		
		cell_name = gtk.CellRendererText()
		col_name = gtk.TreeViewColumn("Name")
		col_name.pack_start(cell_name)
		col_name.add_attribute(cell_name, "markup", 0)
		self.radiochannelsview.append_column (col_name)
		
		cell_freq = gtk.CellRendererText()
		col_freq = gtk.TreeViewColumn("Frequency")
		col_freq.pack_start(cell_freq, False)
		col_freq.add_attribute(cell_freq, "text", 1)
		self.radiochannelsview.append_column (col_freq)
		
		scrolledradioview = gtk.ScrolledWindow()
		scrolledradioview.set_border_width(6)
		scrolledradioview.add(self.radiochannelsview)
		scrolledradioview.set_shadow_type(gtk.SHADOW_ETCHED_IN)
		scrolledradioview.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
		
		radioframe = gtk.Frame("Radio channels")
		radioframe.add(scrolledradioview)
		
		hbox.pack_start(radioframe)
		
		
		self.progressbar = gtk.ProgressBar()
		self.pack_start(self.progressbar, False)
		
	def set_name(self, name):
		self.label.set_text("Scanning for channels on device %s" % name)
		
	def start_scanning(self, adapter, frontend):
		manager = gnomedvb.DVBManagerClient()
		
		scanner = manager.get_scanner_for_device(adapter, frontend)
		
		# FIXME
		a = [586000000, 0, 8, "8k", "2/3", "1/4", "QAM16", 4]
		scanner.add_scanning_data(a)
		
		#scanner.connect ("frequency-scanned", self.__on_freq_scanned)
		scanner.connect ("channel-added", self.__on_channel_added)
		scanner.connect ("finished", self.__on_finished)
		scanner.run()
		
		return scanner
		
	def __on_channel_added(self, scanner, freq, sid, name, network, channeltype):
		if channeltype == "TV":
			self.tvchannels.append([name, freq])
		elif channeltype == "Radio":
			self.radiochannels.append([name, freq])
		
	def __on_finished(self, scanner):
		self.emit("finished")
		
class SaveChannelListPage(BasePage):

	__gsignals__ = {
        "finished": (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, []),
    }

	def __init__(self):
		BasePage.__init__(self)
		self.__scanner = None
		
		text = "Choose a location where you want to save the list of channels."
		label = gtk.Label(text)
		self.pack_start(label)

		button_box = gtk.HButtonBox()
		self.pack_start(button_box)
	
		save_button = gtk.Button(stock=gtk.STOCK_SAVE)
		save_button.connect("clicked", self.__on_save_button_clicked)
		button_box.pack_start(save_button)
		
	def set_scanner(self, scanner):
		self.__scanner = scanner
		
	def __on_save_button_clicked(self, button):
		filechooser = gtk.FileChooserDialog(action=gtk.FILE_CHOOSER_ACTION_SAVE,
			buttons=(gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL,
			gtk.STOCK_SAVE, gtk.RESPONSE_OK))
		filechooser.set_do_overwrite_confirmation(True)
		if (filechooser.run() == gtk.RESPONSE_OK):
			self.__scanner.write_channels_to_file(filechooser.get_filename())
			self.emit("finished")
		filechooser.destroy()

class SummaryPage(BasePage):

	def __init__(self):
		BasePage.__init__(self)
		
		text = "Your DVB cards are now setup."
		label = gtk.Label(text)
		label.set_line_wrap(True)
		self.pack_start(label)

class SetupWizard(gtk.Assistant):

	def __init__(self):
		gtk.Assistant.__init__(self)
		self.__ask_on_exit = True
		self.__device_name = None
		self.__adapter = None
		self.__frontend = None
		self.__scanner = None
		
		self.connect ('delete-event', self.confirm_quit)
		self.connect ('cancel', self.confirm_quit)
		self.connect ('close', self.confirm_quit)
		self.connect ('prepare', self.on_prepare)
		self.set_default_size(500, 400)
		
		intro_page = IntroPage()
		self.append_page(intro_page)
		self.set_page_title(intro_page, "Welcome")
		self.set_page_type(intro_page, gtk.ASSISTANT_PAGE_INTRO)
		self.set_page_complete(intro_page, True)
		
		self.adapters_page = AdaptersPage()
		self.append_page(self.adapters_page)
		self.set_page_title(self.adapters_page, "Setup adapter")
		self.set_page_type(self.adapters_page, gtk.ASSISTANT_PAGE_CONTENT)
		
		self.adapters_page.devicesview.get_selection().connect('changed',
			self.on_device_selection_changed)
		
		scan_page = ChannelScanPage()
		scan_page.connect("finished", self.on_scan_finished)
		self.append_page(scan_page)
		self.set_page_title(scan_page, "Scanning for channels")
		self.set_page_type(scan_page, gtk.ASSISTANT_PAGE_PROGRESS)
		
		save_channels_page = SaveChannelListPage()
		save_channels_page.connect("finished", self.on_scan_finished)
		self.append_page(save_channels_page)
		self.set_page_title(save_channels_page, "Save channels")
		self.set_page_type(save_channels_page, gtk.ASSISTANT_PAGE_CONTENT)
		
		summary_page = SummaryPage()
		self.append_page(summary_page)
		self.set_page_title(summary_page, "Setup finished")
		self.set_page_type(summary_page, gtk.ASSISTANT_PAGE_SUMMARY)
		
	def on_prepare(self, assistant, page):
		if isinstance(page, ChannelScanPage):
			if self.__device_name != None:
				page.set_name(self.__device_name)
				self.__scanner = page.start_scanning(self.__adapter, self.__frontend)
		elif isinstance(page, SaveChannelListPage):
			page.set_scanner(self.__scanner)
		elif isinstance(page, SummaryPage):
			self.__ask_on_exit = False
		
	def on_device_selection_changed(self, treeselection):
		model, aiter = treeselection.get_selected()
		if aiter != None:
			self.__device_name = model[aiter][0]
			self.__adapter = model[aiter][2]
			self.__frontend = model[aiter][3]
			self.set_page_complete(self.adapters_page, True)
		else:
			self.set_page_complete(self.adapters_page, False)
			
	def on_scan_finished(self, page):
		self.set_page_complete(page, True)
			
	def confirm_quit(self, *args):
		if self.__ask_on_exit:
			dialog = gtk.MessageDialog(parent=self,
				flags=gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
				type=gtk.MESSAGE_QUESTION,
				buttons=gtk.BUTTONS_YES_NO,
				message_format="Are you sure you want to abort?\nAll process will be lost.")
			
			response = dialog.run()
			if response == gtk.RESPONSE_YES:
				if self.__scanner != None:
					self.__scanner.destroy()
				gtk.main_quit()
			elif response == gtk.RESPONSE_NO:
				dialog.destroy()
		
			return True
		else:
			if self.__scanner != None:
				self.__scanner.destroy()
			gtk.main_quit()
		
if __name__ == '__main__':
	w = SetupWizard()
	w.show_all()
	gtk.main ()
	
