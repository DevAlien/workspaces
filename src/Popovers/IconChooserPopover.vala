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

public class Workspaces.Popovers.IconChooserPopover : Gtk.Popover {
    public signal void selected (string icon_name);
    public signal void selected_file (File file);

    private Workspaces.Widgets.IconListBox icon_list_box;
    private Gtk.SearchEntry search_entry;
    private Gtk.Button choose_button;

    construct {
        choose_button = new Gtk.Button.with_label (_ ("Choose"));
        choose_button.clicked.connect (() => {
            send_selected ();
        });
        choose_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        choose_button.sensitive = false;

        var from_file_button = new Gtk.Button.with_label (_ ("From file"));
        from_file_button.clicked.connect (choose_from_file_clicked);

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        button_box.margin = 6;
        button_box.pack_start (from_file_button);
        button_box.pack_end (choose_button);

        icon_list_box = new Workspaces.Widgets.IconListBox ();
        icon_list_box.row_selected.connect (on_row_selected);
        icon_list_box.row_activated.connect (on_row_activated);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.expand = true;
        scrolled.height_request = 300;
        scrolled.width_request = 220;
        scrolled.add (icon_list_box);
        scrolled.edge_overshot.connect (on_edge_overshot);

        search_entry = new Gtk.SearchEntry ();
        search_entry.placeholder_text = _ ("Search icons…");
        search_entry.margin_bottom = search_entry.margin_top = search_entry.margin_start = search_entry.margin_end = 12;
        search_entry.hexpand = true;
        search_entry.search_changed.connect (on_search_entry_changed);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.add (search_entry);
        box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        box.add (scrolled);
        box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        box.add (button_box);
        add (box);
    }

    public IconChooserPopover () {
        Object ();
    }

    private void choose_from_file_clicked () {
        var all_filter = new Gtk.FileFilter ();
        all_filter.set_filter_name (_ ("All Files"));
        all_filter.add_pattern ("*");

        var image_filter = new Gtk.FileFilter ();
        image_filter.set_filter_name (_ ("Images"));
        image_filter.add_mime_type ("image/*");

        var file_chooser = new Gtk.FileChooserDialog (
            _ ("Select an image"), Application.instance.preferences_window, Gtk.FileChooserAction.OPEN,
            "_Cancel",
            Gtk.ResponseType.CANCEL,
            "_Open",
            Gtk.ResponseType.ACCEPT
            );

        file_chooser.add_filter (image_filter);
        file_chooser.add_filter (all_filter);

        file_chooser.response.connect ((response) => {
            if (response == Gtk.ResponseType.ACCEPT) {
                string uri = file_chooser.get_uri ();
                var file = File.new_for_uri (uri);

                selected_file (file);
            }

            file_chooser.destroy ();
        });

        file_chooser.run ();
    }

    private void on_row_selected (Gtk.ListBoxRow ? row) {
        choose_button.sensitive = row != null;
    }

    private void on_row_activated (Gtk.ListBoxRow row) {
        send_selected ();
    }

    private void send_selected () {
        string ? icon_name = icon_list_box.get_selected_icon_name ();
        if (icon_name != null) {
            selected (icon_name);
        }
    }

    private void on_edge_overshot (Gtk.PositionType position) {
        if (position == Gtk.PositionType.BOTTOM) {
            icon_list_box.load_next_icons ();
        }
    }

    private void on_search_entry_changed () {
        icon_list_box.search (search_entry.text);
        icon_list_box.invalidate_filter ();
    }
}