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

namespace Workspaces.Dialogs {
    public class AddWorkspace : Dialog {
        public signal void creation (Workspaces.Models.Workspace workspace);

        public AddWorkspace (Gtk.Window parent) {
            base (_ ("Add Workspace"), "workspaces-new-workspace", parent);
            request_name_entry.text = _ ("My Workspace");

            add_button (_ ("Create"), Gtk.ResponseType.APPLY);

            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY :

                    create_workspace ();

                    break;
                case Gtk.ResponseType.CLOSE :
                    destroy ();
                    break;
                }
            });
        }

        private void create_workspace () {
            var name = request_name_entry.text.strip ();

            if (name.length == 0) {
                show_warning (_ ("Workspace name must not be empty."));
            } else {
                debug ("AddWorkspace.create_workspace, creating: " + name);
                var workspace = new Workspaces.Models.Workspace (name);

                creation (workspace);
                destroy ();
            }
        }
    }
}