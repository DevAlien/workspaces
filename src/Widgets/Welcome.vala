/*
 * Copyright (c) 2020 - Today Goncalo Margalho ()
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
    private Gee.ArrayList<Workspaces.Models.Category> collections;
    public Welcome (Gee.ArrayList<Workspaces.Models.Category> collections) {
        Object ();
        this.collections = collections;
    }

    construct {
        var welcome = new Granite.Widgets.Welcome ("Workspaces", _ ("No Workspace selected"));
        welcome.append ("document-new", _ ("Add Category"), _ ("Create a category"));
        welcome.append ("document-import", _ ("Add Workspace"), _ ("Add a new workspace"));

        add (welcome);

        welcome.activated.connect ((index) => {
            switch (index) {
            case 0 :
                Workspaces.Application.instance.window.show_add_category_dialog (collections);
                break;
            case 1 :
                Workspaces.Application.instance.window.show_add_workspace_dialog (collections);
                break;
            }
        });
    }
}