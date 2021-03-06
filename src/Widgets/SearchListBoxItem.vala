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

public class Workspaces.Widgets.SearchListBoxItem : Gtk.ListBoxRow {
    public Workspaces.Models.SearchItem item {get; set;}

    public SearchListBoxItem (Workspaces.Models.SearchItem entry) {
        Object ();

        item = entry;

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 3;
        grid.margin = 12;
        grid.margin_bottom = grid.margin_top = 6;

        add (grid);

        var name = "";
        if (entry.workspace != null) {
            name = entry.workspace.name;
            if (entry.workspace.icon != null) {
                try {
                    var gicon = Icon.new_for_string (entry.workspace.icon);
                    var icon = new Gtk.Image.from_gicon (gicon, Gtk.IconSize.SMALL_TOOLBAR);
                    icon.set_pixel_size (32);
                    grid.attach (icon, 0, 0, 1, 1);
                } catch (Error e) {
                    debug (e.message);
                }
            }

            var sanitised_text = name.replace ("\n", "");
            var text = new Gtk.Label (sanitised_text);
            text.get_style_context ().add_class ("h3");
            text.get_style_context ().add_class ("bold-label");
            text.ellipsize = Pango.EllipsizeMode.MIDDLE;
            text.lines = 1;
            text.single_line_mode = true;
            text.max_width_chars = 60;

            grid.attach (text, 1, 0, 1, 1);
            grid.attach (new Workspaces.Widgets.Dot (), 2, 0, 1, 1);
        } else if (entry.item != null) {
            get_style_context ().add_class ("search-list-item-item");
            name = entry.item.name;
            if (entry.item.icon != null) {
                try {
                    var gicon = Icon.new_for_string (entry.item.icon);
                    var icon = new Gtk.Image.from_gicon (gicon, Gtk.IconSize.SMALL_TOOLBAR);
                    icon.set_pixel_size (32);
                    grid.attach (icon, 0, 0, 1, 1);
                } catch (Error e) {
                    debug (e.message);
                }
            }
            var sanitised_text = name.replace ("\n", "");
            var text = new Gtk.Label (sanitised_text);
            text.get_style_context ().add_class ("h3");
            text.ellipsize = Pango.EllipsizeMode.MIDDLE;
            text.lines = 1;
            text.single_line_mode = true;
            text.max_width_chars = 60;
            grid.attach (text, 1, 0, 1, 1);

            if (entry.item.auto_start == true) {
                var dot = new Workspaces.Widgets.Dot ();
                dot.set_hexpand (true);
                grid.attach (dot, 2, 0, 1, 1);
            }
        }


        show_all ();
    }
}