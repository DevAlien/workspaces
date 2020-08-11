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

using Gee;

public class Workspaces.Controllers.WorkspacesController : Object {
    public signal void category_added (Workspaces.Models.Category category);

    public Workspaces.Models.Store store { get; set; }

    public WorkspacesController (Workspaces.Models.Store store) {
        this.store = store;
    }

    public void add_category (Workspaces.Models.Category category) {
        store.add_category (category);
        category_added (category);
    }

    public void add_workspace (Workspaces.Models.Workspace workspace, Workspaces.Models.Category category) {
        store.add_workspace (workspace, category);
    }
}