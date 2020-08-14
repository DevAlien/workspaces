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

public class Workspaces.Models.SearchItem : GLib.Object {
    public Workspaces.Models.Item item { get; set; }
    public Workspaces.Models.Workspace workspace { get; set; }

    public SearchItem () {
        GLib.Object ();
    }
    public void launch () {
        if (item != null) {
            item.execute_command ();
        } else if (workspace != null) {
            workspace.launch ();
        }
    }

    public bool contains_text (string search_text) {
        if (item != null) {
            string name, command;


            if (item.name != null) {
                name = item.name.down ();
            } else {
                name = "";
            }

            if (item.command != null) {
                command = item.command.down ();
            } else {
                command = "";
            }


            return (search_text in name || search_text in command);
        } else if (workspace != null) {
            string name;


            if (workspace.name != null) {
                name = workspace.name.down ();
            } else {
                name = "";
            }


            return (search_text in name);
        }

        return false;
    }
}

