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

public class Workspaces.Widgets.IconButton : Gtk.MenuButton {
    public signal void changed (Icon icon);

    public Icon icon {
        set {
            icon_image.gicon = value;
        }

        owned get {
            return icon_image.gicon;
        }
    }

    private Gtk.Image icon_image;
    private Gtk.Menu method_menu;
    private Gtk.MenuItem file_menu_item;
    private Gtk.MenuItem name_menu_item;

    public static Icon default_icon;

    static construct {
        default_icon = new ThemedIcon ("dialog-question");
    }

    construct {
        get_style_context ().add_class ("icon-selector-button");

        icon_image = new Gtk.Image ();
        icon_image.gicon = default_icon;
        icon_image.pixel_size = 64;
        image = icon_image;

        file_menu_item = new Gtk.MenuItem.with_label (_ ("Choose from file"));
        file_menu_item.activate.connect (on_file_menu_item_activate);
        file_menu_item.show_all ();

        name_menu_item = new Gtk.MenuItem.with_label (_ ("Choose from available icons"));
        name_menu_item.activate.connect (on_name_menu_item_activate);
        name_menu_item.show_all ();

        method_menu = new Gtk.Menu ();
        method_menu.add (file_menu_item);
        method_menu.add (name_menu_item);

        set_popup (method_menu);
    }

    private void on_file_menu_item_activate () {
        var all_filter = new Gtk.FileFilter ();
        all_filter.set_filter_name (_ ("All Files"));
        all_filter.add_pattern ("*");

        var image_filter = new Gtk.FileFilter ();
        image_filter.set_filter_name (_ ("Images"));
        image_filter.add_mime_type ("image/*");

        var file_chooser = new Gtk.FileChooserDialog (
            _ ("Select an image"), null, Gtk.FileChooserAction.OPEN,
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
                set_gicon (new FileIcon (file));
            }

            file_chooser.destroy ();
        });

        file_chooser.run ();
    }

    private void on_name_menu_item_activate () {
        var icon_chooser_dialog = new Workspaces.Widgets.IconChooserDialog ();
        icon_chooser_dialog.selected.connect ((icon_name) => set_gicon (new ThemedIcon (icon_name)));

        icon_chooser_dialog.show_all ();
    }

    private void set_gicon (Icon icon) {
        icon_image.gicon = icon;
        changed (icon);
    }
}