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

using Gee;

public class Workspaces.Controllers.WorkspacesController : Object {
    public signal void workspace_added (Workspaces.Models.Workspace workspace);
    public signal void item_added (Workspaces.Models.Item item);
    public signal void item_removed (Workspaces.Models.Item item);

    public Workspaces.Models.Store store { get; set; }

    public WorkspacesController (Workspaces.Models.Store store) {
        this.store = store;
    }

    //  public void add_category (Workspaces.Models.Category category) {
    //      store.add_category (category);
    //      category_added (category);
    //  }

    public void save () {
        store.persist ();
    }
    public void duplicate_item (Workspaces.Models.Item item, Workspaces.Models.Workspace workspace) {
        var new_item = new Workspaces.Models.Item (item.name);
        new_item.icon = item.icon;
        new_item.item_type = item.item_type;
        new_item.command = item.command;
        new_item.auto_start = item.auto_start;

        add_item (new_item, workspace);
    }
    public void add_workspace (Workspaces.Models.Workspace workspace) {
        store.add_workspace (workspace);
        workspace_added (workspace);
        var item = new Workspaces.Models.Item ("New item");
        store.add_item (item, workspace);
        item_added (item);
    }

    public void add_item (Workspaces.Models.Item item, Workspaces.Models.Workspace workspace) {
        store.add_item (item, workspace);
        item_added (item);
    }

    public bool remove_item (Workspaces.Models.Item item) {
        return store.remove_item (item);
    }

    public ArrayList<Workspaces.Models.Workspace> get_all () {
        return store.get_all ();
    }
}