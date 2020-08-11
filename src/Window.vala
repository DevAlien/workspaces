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

using Gee;

public class Workspaces.Window : Gtk.Window {
    public GLib.Settings settings;
    public Gtk.Stack stack { get; set; }
    private Workspaces.Controllers.WorkspacesController _workspaces;
    private Granite.Widgets.SourceList source_list;

    public Window (Application app) {
        Object (application: app,
                height_request: 600,
                icon_name: "document-new",
                resizable: true,
                title: _ ("Workspaces"),
                width_request: 700);
    }

    construct {
        var provider = new Gtk.CssProvider ();

        window_position = Gtk.WindowPosition.CENTER;
        set_default_size (600, 700);
        settings = Application.instance.settings;
        move (settings.get_int ("pos-x"), settings.get_int ("pos-y"));

        set_geometry_hints (null, Gdk.Geometry () {
            min_height = 440, min_width = 400
        }, Gdk.WindowHints.MIN_SIZE);

        resize (settings.get_int ("window-width"), settings.get_int ("window-height"));

        delete_event.connect (e => {
            return before_destroy ();
        });

        var categories = load_data ();

        /* Start Stack Container */
        var stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        stack.get_style_context ().add_class ("right-stack");

        var welcome = new Workspaces.Widgets.Welcome (categories);
        stack.add_named (welcome, "welcome");
        /* End Stack Container */

        /* Start Sidebar SourceList */
        source_list = new Granite.Widgets.SourceList ();
        foreach (var c in categories) {
            var cat = new Workspaces.Widgets.ExpandableCategory (c);
            source_list.root.add (cat);
        }
        source_list.set_size_request (160, -1);

        source_list.item_selected.connect ((item) => {
            debug (item.name);
        });

        _workspaces.category_added.connect ((category) => {
            var cat = new Workspaces.Widgets.ExpandableCategory (category);
            source_list.root.add (cat);
        });
        /* End Sidebar SourceList */

        /* Start Sidebar Bottom Actions */
        var add_workspace_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
        add_workspace_button.valign = Gtk.Align.CENTER;
        add_workspace_button.halign = Gtk.Align.START;
        add_workspace_button.always_show_image = true;
        add_workspace_button.can_focus = false;
        add_workspace_button.label = _ ("Add Workspace");
        add_workspace_button.get_style_context ().add_class ("flat");
        add_workspace_button.get_style_context ().add_class ("font-bold");
        add_workspace_button.get_style_context ().add_class ("add-button");
        add_workspace_button.clicked.connect (() => {
            show_add_workspace_dialog (categories);
        });
        var add_revealer = new Gtk.Revealer ();
        add_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        add_revealer.reveal_child = true;
        add_revealer.add (add_workspace_button);

        var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        action_box.get_style_context ().add_class ("bottom-buttons");
        action_box.margin_end = 9;
        action_box.margin_bottom = 6;
        action_box.margin_top = 6;
        action_box.margin_start = 9;
        action_box.hexpand = true;
        action_box.pack_start (add_revealer, false, false, 0);
        /* End Sidebar Bottom Actions */

        /* Start Sidebar */
        var sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sidebar.get_style_context ().add_class ("pane");
        sidebar.pack_start (source_list, true, true, 0);
        sidebar.pack_end (action_box, false, false, 0);
        /* End Sidebar */

        /* Start Main Pane */
        var pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        pane.get_style_context ().add_class ("pane");
        pane.pack1 (sidebar, false, false);
        pane.pack2 (stack, true, false);
        /* End Main Pane */

        /* Start Header */
        var left_header = new Gtk.HeaderBar ();
        left_header.decoration_layout = "close:";
        left_header.show_close_button = true;

        var left_header_context = left_header.get_style_context ();
        left_header_context.add_class ("left-header");
        left_header_context.add_class ("titlebar");
        left_header_context.add_class ("default-decoration");
        left_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var right_header = new Gtk.HeaderBar ();
        right_header.hexpand = true;

        var right_header_context = right_header.get_style_context ();
        right_header_context.add_class ("right-header");
        right_header_context.add_class ("titlebar");
        right_header_context.add_class ("default-decoration");
        right_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var header_paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        header_paned.pack1 (left_header, false, false);
        header_paned.pack2 (right_header, true, false);
        /* End Header */

        get_style_context ().add_class ("rounded");
        set_titlebar (header_paned);
        header_paned.get_style_context ().remove_class ("titlebar");
        add (pane);

        Workspaces.Application.instance.settings.bind ("pane-position", header_paned, "position", GLib.SettingsBindFlags.DEFAULT);
        Workspaces.Application.instance.settings.bind ("pane-position", pane, "position", GLib.SettingsBindFlags.DEFAULT);


        show_all ();
    }

    public void show_add_workspace_dialog (ArrayList<Workspaces.Models.Category> collections) {
        var dialog = new Workspaces.Dialogs.AddWorkspace (this, collections);

        dialog.show_all ();
        dialog.creation.connect ((workspace, category) => {
            _workspaces.add_workspace (workspace, category);
        });
    }

    public void show_add_category_dialog (ArrayList<Workspaces.Models.Category> collections) {
        var dialog = new Workspaces.Dialogs.AddCategory (this, collections);

        dialog.show_all ();
        dialog.creation.connect ((category) => {
            _workspaces.add_category (category);
        });
    }

    private ArrayList<Workspaces.Models.Category> load_data () {
        var data_file = Path.build_filename (Application.instance.data_dir, "data.json");

        var store = new Workspaces.Models.Store (data_file);
        _workspaces = new Workspaces.Controllers.WorkspacesController (store);

        return store.get_all ();
    }

    public bool before_destroy () {
        int width, height, x, y;

        get_size (out width, out height);
        get_position (out x, out y);

        settings.set_int ("pos-x", x);
        settings.set_int ("pos-y", y);
        settings.set_int ("window-height", height);
        settings.set_int ("window-width", width);

        return false;
    }
}