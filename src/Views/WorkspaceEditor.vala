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

public class Workspaces.Views.WorkspaceEditor : Gtk.Box {
    public signal void removed ();

    private Workspaces.Widgets.WorkspaceRow workspace;
    //  private Workspaces.Widgets.Workspace workspace;
    private Workspaces.Widgets.IconButton icon_button;
    private Gtk.Button delete_button;

    private Gtk.Entry name_entry;

    construct {
        get_style_context ().add_class ("item-editor");
        icon_button = new Workspaces.Widgets.IconButton ();
        icon_button.valign = Gtk.Align.START;
        icon_button.changed.connect ((icon) => {
            workspace.workspace.icon = icon.to_string ();
            Workspaces.Application.instance.preferences_window.workspaces_controller.save ();
            workspace.set_icon (icon);
        });

        var name_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        name_box.hexpand = true;

        var header_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
        var header_label = new Gtk.Label (_ ("Display name"));
        header_label.get_style_context ().add_class ("h4");
        header_label.halign = Gtk.Align.START;

        name_entry = new Workspaces.Widgets.Entry ();
        name_entry.placeholder_text = _ ("Display name");
        name_entry.get_style_context ().add_class ("h2");
        name_entry.valign = Gtk.Align.START;
        name_entry.changed.connect (() => {
            workspace.workspace.name = name_entry.get_text ();
            workspace.set_label (name_entry.get_text ());
            Workspaces.Application.instance.preferences_window.workspaces_controller.save ();
        });
        header_box.add (header_label);
        header_box.add (name_entry);
        name_box.add (header_box);

        var header_grid = new Gtk.Grid ();
        header_grid.column_spacing = 12;
        header_grid.row_spacing = 6;
        header_grid.margin_start = 24;
        header_grid.margin_end = 24;
        header_grid.margin_top = 24;
        header_grid.attach (icon_button, 0, 0, 1, 1);
        header_grid.attach (name_box, 1, 0, 1, 1);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.expand = true;


        delete_button = new Gtk.Button.with_label (_ ("Delete"));
        delete_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        delete_button.clicked.connect (() => {
            Application.instance.preferences_window.delete_workspace_dialog (workspace);
        });

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        button_box.margin = 6;


        button_box.pack_end (delete_button, false, false);

        var bottom_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        bottom_box.hexpand = true;
        bottom_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        bottom_box.add (button_box);

        var overlay = new Gtk.Overlay ();
        overlay.add (header_grid);

        pack_start (overlay, false, false);

        pack_end (bottom_box, false, false);
    }

    public WorkspaceEditor () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 12
            );
    }

    public void load_workspace (Workspaces.Widgets.WorkspaceRow workspace) {
        this.workspace = workspace;

        if (workspace.workspace.icon == null) {
            icon_button.icon = Workspaces.Widgets.IconButton.default_icon;
        } else {
            try {
                icon_button.icon = Icon.new_for_string (workspace.workspace.icon);
            } catch (Error e) {
                debug (e.message);
            }
        }

        name_entry.set_text (workspace.workspace.name);
    }
}