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

public class Workspaces.Models.Store : Object {
    private ArrayList<Workspaces.Models.Category> _store;
    private File _data_file;

    public Store (string data_path) {
        Object ();

        _store = new ArrayList<Workspaces.Models.Category> ();
        _data_file = File.new_for_path (data_path);
        debug (@"store initialized in path $data_path");
        ensure ();
        load ();
    }

    public void add_category (Workspaces.Models.Category category) {
        _add_category (category);
        persist ();
    }

    private void _add_category (Workspaces.Models.Category category) {
        _store.add (category);
    }

    public void add_workspace (Workspaces.Models.Workspace workspace, Workspaces.Models.Category category) {
        foreach ( var c in _store ) {
            if ( c.id == category.id ) {
                c.add_workspace (workspace);
            }
        }
        persist ();
    }

    public void remove (Workspaces.Models.Category category) {
        _store.remove (category);
        persist ();
    }

    private void load () {
        debug ("loading store");
        Json.Parser parser = new Json.Parser ();

        try {
            var stream = _data_file.read ();
            parser.load_from_stream (stream);
            stream.close ();
        } catch ( Error e ) {
            warning (@"store: unable to load data, does it exist? $(e.message)");
        }

        Json.Node node = parser.get_root ();
        Json.Array array = node.get_array ();
        array.foreach_element ((a, i, elem) => {
            Workspaces.Models.Category category = Json.gobject_deserialize (typeof (Workspaces.Models.Category), elem) as Workspaces.Models.Category;

            _add_category (category);
        });

        debug (@"loaded store size: $(_store.size)");
    }

    private void persist () {
        debug ("persisting store");
        var data = serialize ();

        try {
            _data_file.delete ();
            var stream = _data_file.create (
                FileCreateFlags.REPLACE_DESTINATION | FileCreateFlags.PRIVATE
                );
            var s = new DataOutputStream (stream);
            s.put_string (data);
            s.flush ();
            s.close ();  // closes base stream also
        } catch ( Error e ) {
            warning (@"store: unable to persist store: $(e.message)");
        }
    }

    private void ensure () {
        try {
            var df = _data_file.create (FileCreateFlags.PRIVATE);
            df.close ();
            debug (@"store created");
        } catch ( Error e ) {
            // Ignore, file already existed, which is good
        }
    }

    public string serialize () {
        Json.Builder builder = new Json.Builder ();
        builder.begin_array ();
        foreach ( var category in _store ) {
            var node = Json.gobject_serialize (category);
            builder.add_value (node);
        }
        builder.end_array ();

        Json.Generator generator = new Json.Generator ();
        generator.set_root (builder.get_root ());
        string data = generator.to_data (null);
        return data;
    }

    public ArrayList<Workspaces.Models.Category> get_all () {
        return _store;
    }
}

