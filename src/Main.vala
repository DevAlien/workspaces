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

public static void set_widget_visible (Gtk.Widget widget, bool visible) {
    if (visible) {
        widget.no_show_all = false;
        widget.show_all ();
    } else {
        widget.no_show_all = true;
        widget.hide ();
    }
}

public static bool is_flatpak () {
    var is_flatpak = Environment.get_variable ("FLATPAK_ID");
    if (is_flatpak != null) {
        return true;
    }

    return false;
}
public static int main (string[] args) {
    var app = Workspaces.Application.instance;
    return app.run (args);
}