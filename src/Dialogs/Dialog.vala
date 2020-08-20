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

namespace Workspaces.Dialogs {
    public abstract class Dialog : Gtk.Dialog {
        protected Gtk.Entry request_name_entry;
        private DialogTitle dialog_title;
        private bool warning_active;

        protected Dialog (string titl, string icon, Gtk.Window parent) {
            title = titl;
            border_width = 5;
            set_size_request (425, 100);
            deletable = false;
            resizable = false;
            transient_for = parent;
            modal = true;
            warning_active = false;

            var request_name_label = new Gtk.Label (_ ("Name:"));
            request_name_entry = new Gtk.Entry ();
            dialog_title = new DialogTitle (title, icon);

            add_button (_ ("Close"), Gtk.ResponseType.CLOSE);

            Gtk.Box hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 15);
            hbox.pack_start (request_name_label, false, true, 0);
            hbox.pack_start (request_name_entry, true, true, 0);
            hbox.margin_bottom = 20;

            var content = get_content_area () as Gtk.Box;

            content.margin = 15;
            content.margin_top = 0;

            content.add (dialog_title);
            content.add (hbox);
        }

        protected void show_warning (string warning) {
            if ( !warning_active ) {
                var content = get_content_area () as Gtk.Box;

                var warning_label = new Gtk.Label ("<span color=\"#a10705\">" + warning + "</span>");
                warning_label.use_markup = true;
                warning_label.margin = 5;
                content.pack_start (warning_label, false, true, 0);
                show_all ();
                request_name_entry.get_style_context ().add_class ("error");
                warning_active = true;
            }
        }

        private class DialogTitle : Gtk.Box {
            private Gtk.Image icon;
            private Gtk.Label label;

            public string title {
                get {
                    return label.label;
                }
                set {
                    label.label = value;
                }
            }

            public DialogTitle (string text, string icon_name) {
                icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
                label = new Gtk.Label ("<b>" + text + "</b>");
                label.use_markup = true;
                label.get_style_context ().add_class ("dialog-title");
                label.xalign = 0;
                label.get_style_context ().add_class ("h2");

                pack_start (icon, false, true, 0);
                pack_start (label, true, true, 0);

                margin_bottom = 15;
            }
        }
    }
}