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
    public class AddCategory : Dialog {
        public signal void creation (Workspaces.Models.Category request);

        public AddCategory (Gtk.Window parent, Gee.ArrayList<Workspaces.Models.Category> collections) {
            base (_ ("Add Collection"), "document-new", parent);
            request_name_entry.text = _ ("My Collection");

            add_button (_ ("Create"), Gtk.ResponseType.APPLY);

            response.connect ((source, id) => {
                switch (id) {
                case Gtk.ResponseType.APPLY :
                    var name = request_name_entry.text;
                    create_category (name.strip ());
                    break;
                case Gtk.ResponseType.CLOSE :
                    destroy ();
                    break;
                }
            });
        }

        private void create_category (string category_name) {
            if (category_name.length == 0) {
                show_warning (_ ("Request name must not be empty."));
            } else {
                debug ("AddCategory.create_category, creating: " + name);
                var category = new Workspaces.Models.Category (category_name, category_name);
                creation (category);
                destroy ();
            }
        }
    }
}