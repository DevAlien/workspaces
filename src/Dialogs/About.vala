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

public class Workspaces.Dialogs.AboutDialog : Gtk.AboutDialog {
    public AboutDialog (Gtk.Window window) {
        Object ();
        set_destroy_with_parent (true);
        set_transient_for (window);
        set_modal (true);

        authors = {"Goncalo Margalho"};
        documenters = null;
        logo_icon_name = Application.APP_ID;
        program_name = "Workspaces";
        comments = "Workspaces to be always ready to work";
        copyright = "Copyright © 2020 Goncalo Margalho";
        version = @"v$(Application.APP_VERSION)";

        license = """Copyright (c) 2020 - Today Goncalo Margalho (https://github.com/devalien)
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.
You should have received a copy of the GNU General Public
License along with this program; if not, write to the
Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301 USA
Authored by: Goncalo Margalho <g@margalho.info>""";
        wrap_license = true;

        website = "https://github.com/devalien/workspaces";
        website_label = "Visit us on github.com";

        //Forcng to use xdg-open instead of GTK default browser due to some distro crashing the app
        activate_link.connect((url) => {
                this.open_link(url);
                return true;
            }
        );

        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
                hide_on_delete ();
            }
        });
    }

    void open_link(string url) {
        var to_run_command = "xdg-open "+ url;
        if (is_flatpak () == true) {
            to_run_command = "flatpak-spawn --host " + to_run_command;
        }
        try {
            string[] ? argvp = null;
            Shell.parse_argv (to_run_command, out argvp);
            info ("Command to launch: %s".printf (to_run_command));
            string[] env = Environ.get ();

            string cdir = GLib.Environment.get_home_dir ();
            Process.spawn_async (cdir,
                                 argvp,
                                 env,
                                 SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD | SpawnFlags.STDOUT_TO_DEV_NULL | SpawnFlags.STDERR_TO_DEV_NULL,
                                 null,
                                 null
                                 );
        } catch (SpawnError e) {
            warning ("Error: %s\n", e.message);
        } catch (ShellError e) {
            warning ("Error: %s\n", e.message);
        }
    }
}
