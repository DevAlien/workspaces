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

public class Workspaces.Application : Gtk.Application {
    public GLib.Settings settings;
    public Window window;
    public string ? data_dir;

    public const string APP_VERSION = "0.0.1";
    public const string APP_ID = "com.github.devalien.workspaces";

    public Application () {
        Object (
            application_id: APP_ID,
            flags : ApplicationFlags.FLAGS_NONE
            );

        settings = new GLib.Settings (this.application_id);

        data_dir = Path.build_filename (Environment.get_user_data_dir (), application_id);
        ensure_dir (data_dir);
    }

    public static Application _instance = null;

    public static Application instance {
        get {
            if (_instance == null) {
                _instance = new Application ();
            }
            return _instance;
        }
    }

    protected override void activate () {
        if (window == null) {
            window = new Window (this);
            add_window (window);
        } else {
            window.present ();
        }

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/devalien/workspaces/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});

        quit_action.activate.connect (() => {
            if (window != null) {
                window.destroy ();
            }
        });
    }

    private void ensure_dir (string path) {
        var dir = File.new_for_path (path);

        try {
            debug (@"Ensuring dir exists: $path");
            dir.make_directory ();
        } catch (Error e) {
            if (!(e is IOError.EXISTS)) {
                warning (@"dir couldn't be created: %s", e.message);
            }
        }
    }
}
