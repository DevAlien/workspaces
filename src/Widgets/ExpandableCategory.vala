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

public class Workspaces.Widgets.ExpandableCategory : Granite.Widgets.SourceList.ExpandableItem {
    private Workspaces.Models.Category category;

    public ExpandableCategory (Workspaces.Models.Category category) {
        Object (name: category.name);

        this.category = category;
        load ();
    }

    void load () {
        collapsible = true;
        expanded = true;

        foreach ( var workspace in category.workspaces ) {
            add_item (workspace);
        }

        category.workspace_added.connect ((workspace) => {
            add_item (workspace);
        });
    }

    private void add_item (Workspaces.Models.Workspace workspace) {
        var item = new Workspaces.Widgets.WorkspaceItem (workspace);
        item.set_data<string>("stack_child", workspace.name);
        add (item);
    }
}