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

public class Workspaces.Widgets.IconButton : Gtk.Button {
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

        var icon_chooser_popover = new Workspaces.Popovers.IconChooserPopover ();
        icon_chooser_popover.selected.connect ((icon_name) => {
            set_gicon (new ThemedIcon (icon_name));
            icon_chooser_popover.popdown ();
        });

        icon_chooser_popover.selected_file.connect ((file) => {
            set_gicon (new FileIcon (file));
            icon_chooser_popover.popdown ();
        });

        clicked.connect ( () => {
            icon_chooser_popover.set_relative_to (this);
            icon_chooser_popover.show_all ();
            icon_chooser_popover.popup ();
        });

        show_all ();
    }

    private void set_gicon (Icon icon) {
        icon_image.gicon = icon;
        changed (icon);
    }
}