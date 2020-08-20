/*
 * Copyright (c) 2020 - Today Goncalo Margalho (https://github.com/devalien)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Goncalo Margalho <g@margalho.info>
 */

public class Workspaces.Widgets.TypeComboBox : Gtk.ComboBox {
    private Gtk.ListStore list_store;
    private Gtk.TreeIter ? active_iter;

    private static Gee.ArrayList<Workspaces.Models.ItemType ? > types;

    static construct {
        types = new Gee.ArrayList<Workspaces.Models.ItemType ? > ();
        types.add ({ "URL", _ ("URL"), "applications-internet" });
        types.add ({ "Directory", _ ("Directory"), "document-open" });
        types.add ({ "Application", _ ("Application"), "applications-interfacedesign" });
        types.add ({ "ApplicationDirectory", _ ("Application + Directory"), "applications-development" });
        types.add ({ "Custom", _ ("Custom command"), "applications-other" });
    }

    construct {
        list_store = new Gtk.ListStore (3, typeof (string), typeof (unowned string), typeof (string));
        model = list_store;

        Gtk.TreeIter iter;
        foreach (var type in types) {
            list_store.append (out iter);
            list_store.@set (iter, 0, type.id, 1, type.name, 2, type.icon_name);
        }

        var pixbuf_cell = new Gtk.CellRendererPixbuf ();
        pack_start (pixbuf_cell, false);
        add_attribute (pixbuf_cell, "icon-name", 2);

        var text_cell = new Gtk.CellRendererText ();
        pack_start (text_cell, true);
        add_attribute (text_cell, "text", 1);
    }

    public void set_current_selection (string selected_id) {
        Gtk.TreeIter iter;
        for (bool next = list_store.get_iter_first (out iter); next; next = list_store.iter_next (ref iter)) {
            Value id;
            list_store.get_value (iter, 0, out id);

            if (((string)id) == selected_id) {
                active_iter = iter;
            }
        }

        set_active_iter (active_iter);
    }

    public string ? get_selected_category_id () {
        Gtk.TreeIter iter;
        if (!get_active_iter (out iter)) {
            return null;
        }

        Value id;
        list_store.get_value (iter, 0, out id);

        return (string)id;
    }
}