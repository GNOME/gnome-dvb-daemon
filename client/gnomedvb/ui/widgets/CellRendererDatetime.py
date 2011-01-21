# -*- coding: utf-8 -*-
# Copyright (C) 2010 Sebastian Pölsterl
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

import gobject
from gi.repository import Gtk 

class CellRendererDatetime(Gtk.CellRendererText):

    __gproperties__ = {
        'datetime' : (gobject.TYPE_PYOBJECT, 'datetime to display',
            'Must be a Python datetime.datetime object',
            gobject.PARAM_READWRITE),
        'format' : (gobject.TYPE_STRING,
            'Specifies in which format the datetime should be displayed.',
            'Accepts any strftime format string.',
            "%c", gobject.PARAM_READWRITE),
    }

    def __init__(self):
        gobject.GObject.__init__(self)
        self._datetime = None
        self._format = "%c"
        self.set_property("text", "")
        
    def do_get_property(self, property):
        if property.name == 'datetime':
            return self._datetime
        elif property.name == 'format':
            return self._format
        else:
            raise AttributeError, 'unknown property %s' % property.name

    def do_set_property(self, property, value):
        if property.name == 'datetime':
            self._datetime = value
            self._set_text()
        elif property.name == 'format':
            self._format = value
            self._set_text()
        else:
            raise AttributeError, 'unknown property %s' % property.name

    def _set_text(self):
        if self._datetime == None:
            self.set_property("text", "")
        else:
            timestr = self._datetime.strftime(self._format)
            self.set_property("text", timestr)
        
