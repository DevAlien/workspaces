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

using Json;
using Gee;

public class Workspaces.Models.Workspace : GLib.Object, Json.Serializable {
    public string id { get; set; }
    public string name { get; set; }
    public string icon { get; set; }
    public ArrayList<Workspaces.Models.Item> items { get; set; }

    public Workspace (string id, string name) {
        GLib.Object ();

        this.id = id;
        this.name = name;
    }

    public string to_string () {
        return @"[$(this.id)] $(this.name)";
    }

    public virtual Json.Node serialize_property (string property_name, Value @value, ParamSpec pspec) {
        if ( @value.type ().is_a (typeof (Gee.ArrayList))) {
            unowned Gee.ArrayList<GLib.Object> list_value = @value as Gee.ArrayList<GLib.Object>;
            if ( list_value != null || property_name == "data" ) {
                var array = new Json.Array.sized (list_value.size);
                foreach ( var item in list_value ) {
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
        if ( property_name == "items" ) {
            var node_arr = property_node.get_array ().get_elements ();
            var ws = new ArrayList<Workspaces.Models.Item> ();
            foreach ( var n in node_arr ) {
                if ( n.get_node_type () == Json.NodeType.OBJECT ) {
                    var asd = Json.gobject_deserialize (typeof (Workspaces.Models.Item), n) as Workspaces.Models.Item;
                    ws.add (asd);
                }
            }

            @value = ws;
            return true;
        }

        if ( property_node.get_node_type () == Json.NodeType.VALUE ) {
            @value = property_node.get_value ();
            return true;
        }
        return default_deserialize_property (property_name, out @value, pspec, property_node);
    }
}

