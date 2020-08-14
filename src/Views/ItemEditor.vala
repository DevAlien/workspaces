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


public class Workspaces.Widgets.FieldEntry : Gtk.Box {
    private const string ENTRY_CSS = """
        .entry.flat {
            background-color: rgba(0,0,0,0);
        }
        .entry.flat:selected,
        .entry.flat:selected:focus {
            background-color: @colorAccent;
        }
    """;

    private const string ENTRY_CSS_322 = """
        entry.flat {
            background-color: rgba(0,0,0,0);
        }
        entry.flat:selected,
        entry.flat:selected:focus {
            background-color: @colorAccent;
        }
    """;

    public Gtk.Entry entry { get; construct; }

    private Gtk.Revealer revealer;

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        //  string css;
        //  css = ENTRY_CSS;


        //  Granite.Widgets.Utils.set_theming (entry, css, Gtk.STYLE_CLASS_FLAT, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        entry.changed.connect (update_header_visibility);
        entry.focus_in_event.connect (on_entry_focus_in_event);
        entry.focus_out_event.connect (on_entry_focus_out_event);

        var header_label = new Gtk.Label (entry.placeholder_text);
        header_label.get_style_context ().add_class ("h4");

        revealer = new Gtk.Revealer ();
        revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        revealer.halign = Gtk.Align.START;
        revealer.valign = Gtk.Align.START;
        revealer.add (header_label);

        add (revealer);
        add (entry);
    }

    public FieldEntry (Gtk.Entry entry) {
        Object (entry: entry);
    }

    private void update_header_visibility () {
        revealer.reveal_child = entry.text_length > 0 && entry.has_focus;
    }

    private bool on_entry_focus_in_event (Gdk.EventFocus event) {
        update_header_visibility ();
        return Gdk.EVENT_PROPAGATE;
    }

    private bool on_entry_focus_out_event (Gdk.EventFocus event) {
        update_header_visibility ();
        return Gdk.EVENT_PROPAGATE;
    }
}

public class Workspaces.Views.ItemEditor : Gtk.Box {
    public signal void removed ();

    private Workspaces.Widgets.WorkspaceItem item;
    //  private Workspaces.Widgets.Workspace workspace;
    private Workspaces.Widgets.IconButton icon_button;
    private Gtk.Entry name_entry;
    private Gtk.Entry cmdline_entry;
    private Gtk.Switch auto_start_switch;

    private Gtk.Button delete_button;
    private Granite.Widgets.Toast toast;

    private Gtk.InfoBar error_info_bar;
    private Gtk.Label error_label;

    construct {
        get_style_context ().add_class ("item-editor");
        icon_button = new Workspaces.Widgets.IconButton ();
        icon_button.valign = Gtk.Align.START;
        icon_button.changed.connect ((icon) => {
            item.item.icon = icon.to_string ();
            Workspaces.Application.instance.preferences_window.workspaces_controller.save ();
            item.icon = icon;
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
        name_entry.margin_end = 60;
        name_entry.changed.connect (() => {
            item.item.name = name_entry.get_text ();
            item.name = name_entry.get_text ();
            Workspaces.Application.instance.preferences_window.workspaces_controller.save ();
        });
        header_box.add (header_label);
        header_box.add (name_entry);
        name_box.add (header_box);

        cmdline_entry = new Workspaces.Widgets.Entry ();
        cmdline_entry.width_request = 300;
        cmdline_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        cmdline_entry.placeholder_text = _ ("Program to execute along with it's arguments");
        cmdline_entry.changed.connect (() => {
            item.item.command = cmdline_entry.get_text ();
            Workspaces.Application.instance.workspaces_controller.save ();
        });

        auto_start_switch = new Gtk.Switch ();
        auto_start_switch.notify["active"].connect (() => {
            item.item.auto_start = auto_start_switch.state;
            Workspaces.Application.instance.workspaces_controller.save ();
        });

        var executable_box = new Workspaces.Widgets.SettingBox (_ ("Command Line"), cmdline_entry, false);
        var terminal_box = new Workspaces.Widgets.SettingBox (_ ("Auto Launch with workspace"), auto_start_switch, true);

        var launch_settings_grid = new Workspaces.Widgets.SettingsGrid (_ ("Settings"));
        launch_settings_grid.add_widget (executable_box);
        launch_settings_grid.add_widget (terminal_box);

        var header_grid = new Gtk.Grid ();
        header_grid.column_spacing = 12;
        header_grid.row_spacing = 6;
        header_grid.margin_start = 24;
        header_grid.margin_end = 24;
        header_grid.margin_top = 24;
        header_grid.attach (icon_button, 0, 0, 1, 1);
        header_grid.attach (name_box, 1, 0, 1, 1);

        var settings_grid = new Gtk.Grid ();
        settings_grid.row_spacing = 12;
        settings_grid.margin_start = 24;
        settings_grid.margin_end = 24;
        settings_grid.attach (launch_settings_grid, 0, 1, 1, 1);


        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.expand = true;
        scrolled.add (settings_grid);

        delete_button = new Gtk.Button.with_label (_ ("Delete"));
        delete_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        delete_button.clicked.connect (() => {
            item.remove_itself ();
        });

        var duplicate_button = new Gtk.Button.with_label (_ ("Duplicate"));
        duplicate_button.clicked.connect (() => {
            var workspace_parent = item.parent as Workspaces.Widgets.ExpandableCategory;
            if (workspace_parent != null) {
                Workspaces.Application.instance.workspaces_controller.duplicate_item (item.item, workspace_parent.workspace);
            }
        });

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        button_box.margin = 6;

        button_box.pack_start (duplicate_button, false, false);
        button_box.pack_end (delete_button, false, false);

        var bottom_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        bottom_box.hexpand = true;
        bottom_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        bottom_box.add (button_box);

        toast = new Granite.Widgets.Toast ("");
        toast.halign = Gtk.Align.END;

        var overlay = new Gtk.Overlay ();
        overlay.add (header_grid);
        overlay.add_overlay (toast);

        error_label = new Gtk.Label (null);
        error_label.wrap = true;
        error_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
        error_label.show_all ();

        error_info_bar = new Gtk.InfoBar ();
        error_info_bar.message_type = Gtk.MessageType.ERROR;
        error_info_bar.show_close_button = true;
        error_info_bar.response.connect (() => set_widget_visible (error_info_bar, false));
        set_widget_visible (error_info_bar, false);

        unowned Gtk.Container content = error_info_bar.get_content_area ();
        content.add (error_label);

        pack_start (error_info_bar, false, false);
        pack_start (overlay, false, false);
        add (scrolled);
        pack_end (bottom_box, false, false);
    }

    public ItemEditor () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 12
            );
    }

    public void load_item (Workspaces.Widgets.WorkspaceItem item) {
        this.item = item;

        if (item.icon == null) {
            icon_button.icon = Workspaces.Widgets.IconButton.default_icon;
        } else {
            icon_button.icon = item.icon;
        }

        name_entry.set_text (item.item.name);
        if (item.item.command == null) {
            cmdline_entry.set_text ("");
        } else {
            cmdline_entry.set_text (item.item.command);
        }

        auto_start_switch.set_state (item.item.auto_start);
    }
}