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

public class Workspaces.Widgets.Welcome : Gtk.Grid {
    public Welcome () {
        Object ();
    }

    construct {
        var welcome = new Granite.Widgets.Welcome ("Workspaces", _ ("No Workspace selected"));
        welcome.append ("workspaces-new-workspace", _ ("Add Workspace"), _ ("Add a new workspace"));
        welcome.append ("workspaces-new-item", _ ("Add Item"), _ ("Add a new item"));
        add (welcome);

        welcome.activated.connect ((index) => {
            switch (index) {
            case 0 :
                Workspaces.Application.instance.preferences_window.show_add_workspace_dialog ();
                break;
            case 1 :
                Workspaces.Application.instance.preferences_window.show_add_item_dialog ();
                break;
            }
        });
    }
}