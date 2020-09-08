/*
 * Copyright (c) 2020 - Today Goncalo Margalho (https://github.com/devalien)
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
    private ArrayList<Workspaces.Models.Workspace> _store;
    private File _data_file;

    public Store (string data_path) {
        Object ();

        _store = new ArrayList<Workspaces.Models.Workspace> ();
        _data_file = File.new_for_path (data_path);
        debug (@"store initialized in path $data_path");
        ensure ();
        load ();
    }

    public void add_workspace (Workspaces.Models.Workspace workspace) {
        _add_workspace (workspace);
        persist ();
    }

    private void _add_workspace (Workspaces.Models.Workspace workspace) {
        debug (workspace.items.size.to_string ());
        _store.add (workspace);
    }

    public void add_item (Workspaces.Models.Item item, Workspaces.Models.Workspace workspace) {
        foreach ( var w in _store ) {
            if ( w.id == workspace.id ) {
                w.add_item (item);
            }
        }
        persist ();
    }

    public void add_item_at (Workspaces.Models.Item item, Workspaces.Models.Workspace workspace, int position) {
        foreach ( var w in _store ) {
            if ( w.id == workspace.id ) {
                w.insert_item (position, item);
            }
        }
        persist ();
    }

    public bool remove_item (Workspaces.Models.Item item) {
        var has_deleted = false;
        foreach ( var w in _store ) {
            var index = w.items.index_of (item);
            if (index != -1) {
                w.items.remove_at (index);
                has_deleted = true;
                break;
            }
        }

        persist ();

        return has_deleted;
    }

    public void remove (Workspaces.Models.Workspace workspace) {
        _store.remove (workspace);
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

        Json.Node ? node = parser.get_root ();
        Json.Array array = node.get_array ();
        array.foreach_element ((a, i, elem) => {
            Workspaces.Models.Workspace workspace = Json.gobject_deserialize (typeof (Workspaces.Models.Workspace), elem) as Workspaces.Models.Workspace;
            _add_workspace (workspace);
        });

        debug (@"loaded store size: $(_store.size)");
    }

    public void persist () {
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
            df.write ("[]".data);
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

    public ArrayList<Workspaces.Models.Workspace> get_all () {
        return _store;
    }
}

