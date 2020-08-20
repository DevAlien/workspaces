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

public class Workspaces.Widgets.ExpandableCategory : Granite.Widgets.SourceList.ExpandableItem {
    public Workspaces.Models.Workspace workspace { get; set; }

    public signal void added_new_item (Workspaces.Widgets.WorkspaceItem item);
    public signal void item_deleted (Workspaces.Widgets.WorkspaceItem item);

    public ExpandableCategory (Workspaces.Models.Workspace workspace) {
        Object (name: workspace.name);

        this.workspace = workspace;
        load ();
    }

    void load () {
        collapsible = true;
        expanded = true;
        var default_icon = new ThemedIcon ("dialog-question");
        //  icon_image.gicon = default_icon;

        //  icon_image.pixel_size = 24;
        icon = default_icon;
        foreach ( var item in workspace.items ) {
            add_item (item, false);
        }

        workspace.item_added.connect ((item) => {
            add_item (item, true);
        });
    }
    public void remove_item (Workspaces.Widgets.WorkspaceItem item) {
        remove (item);
        item_deleted (item);
    }

    private void add_item (Workspaces.Models.Item item, bool to_open) {
        var it = new Workspaces.Widgets.WorkspaceItem (item);
        it.set_data<string>("stack_child", item.name);
        it.action_activated.connect ((i) => {
            i.selectable = false;
            it.item.execute_command ();
            GLib.Timeout.add (100, () => {
                i.selectable = true;
                return false;
            }, GLib.Priority.DEFAULT);
        });
        it.activated.connect ((i) => {
            warning (i.name);
        });
        add (it);

        if (to_open == true) {
            added_new_item (it);
        }
    }

    public override Gtk.Menu ? get_context_menu () {
        Gtk.Menu menu = new Gtk.Menu ();
        Gtk.MenuItem menu_item = new Gtk.MenuItem.with_label (_ ("Delete"));
        menu.add (menu_item);
        menu.show_all ();

        return menu;
    }
}