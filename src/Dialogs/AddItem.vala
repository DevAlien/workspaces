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
    public class AddItem : Dialog {
        public signal void creation (Workspaces.Models.Item item, Workspaces.Models.Workspace workspaces);

        public AddItem (Gtk.Window parent, Gee.ArrayList<Workspaces.Models.Workspace> workspaces) {
            base (_ ("Add Item"), "workspaces-new-item", parent);
            request_name_entry.text = _ ("New Item");

            add_button (_ ("Create"), Gtk.ResponseType.APPLY);
            var content = get_content_area () as Gtk.Box;

            var combo_box = new Gtk.ComboBoxText ();

            if (workspaces.size > 0) {
                var combo_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
                var workspace_label = new Gtk.Label (_ ("Add to workspace"));
                workspace_label.halign = Gtk.Align.START;
                combo_container.pack_start (workspace_label);
                foreach (var workspace in workspaces) {
                    combo_box.append (workspace.name, workspace.name);
                }

                combo_container.pack_start (combo_box);
                combo_box.active = 0;
                combo_container.margin_bottom = 12;
                content.add (combo_container);
            }


            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY :
                    var workspace = workspaces.get (combo_box.active);
                    create_item (workspace);

                    break;
                case Gtk.ResponseType.CLOSE :
                    destroy ();
                    break;
                }
            });
        }

        private void create_item (Workspaces.Models.Workspace workspace) {
            var name = request_name_entry.text.strip ();

            if (name.length == 0) {
                show_warning (_ ("Item name must not be empty."));
            } else {
                debug ("AddItem.create_item, creating: " + name);
                var item = new Workspaces.Models.Item (name);

                creation (item, workspace);
                destroy ();
            }
        }
    }
}