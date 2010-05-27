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

import gnomedvb
import gtk
import gobject
import glib
from gettext import gettext as _
from gnomedvb.ui.wizard.pages.BasePage import BasePage
from gnomedvb.ui.widgets.Frame import TextFieldLabel
from gnomedvb import global_error_handler

class ChannelScanPage(BasePage):

    __gsignals__ = {
        "finished": (gobject.SIGNAL_RUN_LAST, gobject.TYPE_NONE, [bool]),
    }
    
    (COL_LOGO,
     COL_NAME,
     COL_ACTIVE,
     COL_SID,
     COL_SCRAMBLED) = range(5)
     
    MENU = '''<ui>
    <popup name="channels-popup">
        <menuitem name="channels-select-all" action="channels-select-all" />
        <menuitem name="channels-deselect-all" action="channels-deselect-all" />
    </popup></ui>'''

    def __init__(self, model):
        BasePage.__init__(self)
        
        self._model = model
        self._scanner = None
        self._max_freqs = 0
        self._scanned_freqs = 0
        self._last_qsize = 0
        self._progressbar_timer = 0
        
        self.set_spacing(12)
        self._theme = gtk.icon_theme_get_default()

        text = "%s\n%s" % (
            _("This process can take some time."),
            _("You can select the channels you want to have in your list of channels.")
        )
        self._label.set_markup (text)
        
        actiongroup = gtk.ActionGroup('channels')
        actiongroup.add_actions([
            ('channels-select-all', None, _('Select all'), None, None,
                lambda x: self.__set_all_checked(True)),
            ('channels-deselect-all', None, _('Deselect all'), None, None,
                lambda x: self.__set_all_checked(False)),
        ])
        
        uimanager = gtk.UIManager()
        uimanager.add_ui_from_string(self.MENU)
        uimanager.insert_action_group(actiongroup)
        
        self.popup_menu = uimanager.get_widget("/channels-popup")

        topbox = gtk.VBox(spacing=6)
        self.pack_start(topbox)

        ali = TextFieldLabel()
        label = ali.get_label()
        label.set_markup_with_mnemonic(_("_Channels:"))
        topbox.pack_start(ali, False)
        
        # Logo, Name, active, SID, scrambled
        self.tvchannels = gtk.ListStore(gtk.gdk.Pixbuf, str, bool, int, bool)
        self.tvchannelsview = gtk.TreeView(self.tvchannels)
        self.tvchannelsview.connect("button-press-event",
            self.__on_treeview_button_press_event)
        self.tvchannelsview.set_reorderable(True)
        self.tvchannelsview.set_headers_visible(False)
        label.set_mnemonic_widget(self.tvchannelsview)
        
        col_name = gtk.TreeViewColumn(_("Channel"))
        
        cell_active = gtk.CellRendererToggle()
        cell_active.connect("toggled", self.__on_active_toggled)
        col_name.pack_start(cell_active, False)
        col_name.add_attribute(cell_active, "active", self.COL_ACTIVE)
        
        cell_icon = gtk.CellRendererPixbuf()
        col_name.pack_start(cell_icon, False)
        col_name.add_attribute(cell_icon, "pixbuf", self.COL_LOGO)
        
        cell_name = gtk.CellRendererText()
        col_name.pack_start(cell_name)
        col_name.add_attribute(cell_name, "markup", self.COL_NAME)
        self.tvchannelsview.append_column (col_name)

        scrolledtvview = gtk.ScrolledWindow()
        scrolledtvview.add(self.tvchannelsview)
        scrolledtvview.set_shadow_type(gtk.SHADOW_ETCHED_IN)
        scrolledtvview.set_policy(gtk.POLICY_NEVER, gtk.POLICY_AUTOMATIC)
        
        topbox.pack_start(scrolledtvview)

        self.scrambledbutton = gtk.CheckButton(_("Select _scrambled channels"))
        self.scrambledbutton.set_active(True)
        self.scrambledbutton.connect("toggled", self.__on_select_encrypted_toggled)
        topbox.pack_start(self.scrambledbutton, False)
        
        self.progressbar = gtk.ProgressBar()
        self.pack_start(self.progressbar, False)
        
    def get_scanner(self):
        return self._scanner
        
    def get_page_title(self):
        return _("Scanning for channels")
   
    def get_selected_channel_sids(self):
        return [row[self.COL_SID] for row in self.tvchannels if row[self.COL_ACTIVE]]
        
    def start_scanning(self, adapter, frontend, tuning_data):
        def data_loaded(success):
            if success:
                self._scanner.run()
            else:
                self._scanner.destroy()
        
        self._scanner = self._model.get_scanner_for_device(adapter, frontend)
        
        self._scanner.connect ("frequency-scanned", self.__on_freq_scanned)
        self._scanner.connect ("channel-added", self.__on_channel_added)
        self._scanner.connect ("finished", self.__on_finished)

        self.progressbar.set_pulse_step(0.1)
        self._progressbar_timer = glib.timeout_add(100, self._progressbar_pulse)
        self.progressbar.show()

        if isinstance(tuning_data, str):
            self._scanner.add_scanning_data_from_file (tuning_data,
                reply_handler=data_loaded, error_handler=global_error_handler)
        elif isinstance(tuning_data, list):
            for data in tuning_data:
                self._scanner.add_scanning_data(data)
            self._scanner.run()
        else:
            self._scanner.destroy()
            
    def _progressbar_pulse(self):
        self.progressbar.pulse()
        return True
        
    def __on_channel_added(self, scanner, freq, sid, name, network, channeltype, scrambled):
        try:
            if scrambled:
                icon = self._theme.load_icon("emblem-readonly", 16,
                    gtk.ICON_LOOKUP_USE_BUILTIN)
            else:
                if channeltype == "TV":
                    icon = self._theme.load_icon("video-x-generic", 16,
                        gtk.ICON_LOOKUP_USE_BUILTIN)
                elif channeltype == "Radio":
                    icon = self._theme.load_icon("audio-x-generic", 16,
                        gtk.ICON_LOOKUP_USE_BUILTIN)
        except glib.GError:
            icon = None
        
        name = name.replace("&", "&amp;")
        if scrambled and not self.scrambledbutton.get_active():
            active = False
        else:
            active = True
        self.tvchannels.append([icon, name, active, sid, scrambled])
        
    def __on_finished(self, scanner):
        self.progressbar.hide()
        
        self.emit("finished", True)
        
    def __on_freq_scanned(self, scanner, freq, qsize):
        if qsize >= self._last_qsize:
            self._max_freqs += qsize - self._last_qsize + 1
        self._scanned_freqs += 1
        fraction = float(self._scanned_freqs) / self._max_freqs
        # Stop progressbar from pulsing
        if self._progressbar_timer > 0:
            glib.source_remove(self._progressbar_timer)
            self._progressbar_timer = 0

        self.progressbar.set_fraction(fraction)
        self._last_qsize = qsize
        
    def __on_active_toggled(self, renderer, path):
        aiter = self.tvchannels.get_iter(path)
        self.tvchannels[aiter][self.COL_ACTIVE] = \
            not self.tvchannels[aiter][self.COL_ACTIVE]
        
    def __on_select_encrypted_toggled(self, checkbutton):
        val = checkbutton.get_active()
        for row in self.tvchannels:
            if row[self.COL_SCRAMBLED]:
                row[self.COL_ACTIVE] = val
                
    def __on_treeview_button_press_event(self, treeview, event):
        if event.button == 3:
            x = int(event.x)
            y = int(event.y)
            time = event.time
            pthinfo = treeview.get_path_at_pos(x, y)
            if pthinfo is not None:
                path, col, cellx, celly = pthinfo
                treeview.grab_focus()
                treeview.set_cursor( path, col, 0)
                self.popup_menu.popup(None, None, None, event.button, time)
            return True

    def __set_all_checked(self, val):
        for row in self.tvchannels:
            row[self.COL_ACTIVE] = val

