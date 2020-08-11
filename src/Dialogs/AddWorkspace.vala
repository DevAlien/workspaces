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
        public signal void creation (Workspaces.Models.Workspace workspace, Workspaces.Models.Category collection);

        public AddWorkspace (Gtk.Window parent, Gee.ArrayList<Workspaces.Models.Category> collections) {
            base (_ ("Add Workspace"), "document-import", parent);
            request_name_entry.text = _ ("My Workspace");

            add_button (_ ("Create"), Gtk.ResponseType.APPLY);
            var content = get_content_area () as Gtk.Box;

            var combo_box = new Gtk.ComboBoxText ();

            if (collections.size > 0) {
                var combo_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
                var collection_label = new Gtk.Label (_ ("Add to collection"));
                collection_label.halign = Gtk.Align.START;
                combo_container.pack_start (collection_label);
                foreach (var collection in collections) {
                    combo_box.append (collection.name, collection.name);
                }

                combo_container.pack_start (combo_box);
                combo_box.active = 0;
                combo_container.margin_bottom = 12;
                content.add (combo_container);
            }


            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY :
                    var collection = collections.get (combo_box.active);
                    create_workspace (collection);

                    break;
                case Gtk.ResponseType.CLOSE :
                    destroy ();
                    break;
                }
            });
        }

        private void create_workspace (Workspaces.Models.Category category) {
            var name = request_name_entry.text.strip ();

            if (name.length == 0) {
                show_warning (_ ("Workspace name must not be empty."));
            } else {
                debug ("AddWorkspace.create_workspace, creating: " + name);
                var workspace = new Workspaces.Models.Workspace (name, name);

                creation (workspace, category);
                destroy ();
            }
        }
    }
}