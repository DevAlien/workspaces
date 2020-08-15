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
using Json;

namespace Workspaces.Models {
    public class Category : GLib.Object, Json.Serializable {
        public string id { get; set; }
        public string name { get; set; }
        public ArrayList<Workspace> workspaces { get; set; }
        public signal void changed (Workspaces.Models.Category request);
        public signal void workspace_added (Workspaces.Models.Workspace workspace);

        public Category (string id, string name) {
            GLib.Object ();

            this.id = id;
            this.name = name;
            workspaces = new ArrayList<Workspace> ();
        }

        public void add_workspace (Workspaces.Models.Workspace workspace) {
            stdout.printf ("name: %s\n", workspace.name);
            workspaces.add (workspace);
            workspace_added (workspace);
            stdout.printf ("SIZE: %d\n", workspaces.size);
        }

        public string to_string () {
            return @"[$(this.id)] $(this.name)";
        }

        public virtual Json.Node serialize_property (string property_name, Value @value, ParamSpec pspec) {
            if (@value.type ().is_a (typeof (Gee.ArrayList))) {
                unowned Gee.ArrayList<GLib.Object> list_value = @value as Gee.ArrayList<GLib.Object>;
                if (list_value != null || property_name == "data") {
                    var array = new Json.Array.sized (list_value.size);
                    foreach (var item in list_value)
                    {
                        array.add_element (gobject_serialize (item));
                    }

                    var node = new Json.Node (NodeType.ARRAY);
                    node.set_array (array);
                    return node;
                }
            }

            return default_serialize_property (property_name, @value, pspec);
        }

        public virtual bool deserialize_property (string property_name, out Value @value, ParamSpec pspec, Json.Node property_node) {
            if (property_name == "workspaces") {
                var node_arr = property_node.get_array ().get_elements ();
                var ws = new ArrayList<Workspace> ();
                foreach (var n in node_arr) {
                    if (n.get_node_type () == Json.NodeType.OBJECT) {
                        var asd = Json.gobject_deserialize (typeof (Workspace), n) as Workspace;
                        ws.add (asd);
                    }
                }

                @value = ws;
                return true;
            }

            if (property_node.get_node_type () == Json.NodeType.VALUE) {
                @value = property_node.get_value ();
                return true;
            }
            return default_deserialize_property (property_name, out @value, pspec, property_node);
        }

        public virtual unowned ParamSpec ? find_property (string name) {
            return get_class ().find_property (name);
        }
    }
}
