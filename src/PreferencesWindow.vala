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

using Gee;

public class Workspaces.PreferencesWindow : Gtk.ApplicationWindow {
    public GLib.Settings settings;
    public Gtk.Stack stack { get; set; }

    public Workspaces.Controllers.WorkspacesController workspaces_controller {get; set;}

    private Granite.Widgets.SourceList source_list;

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_ABOUT = "action_about";
    public const string ACTION_SETTINGS = "action_settings";
    public const string ACTION_QUICK_LAUNCHER = "action_quick_launcher";
    private signal void refresh_favourites ();

    private const ActionEntry[] ACTION_ENTRIES = {
        { ACTION_ABOUT, on_action_about },
        { ACTION_SETTINGS, on_action_settings },
        { ACTION_QUICK_LAUNCHER, on_action_quick_launcher },
    };

    public PreferencesWindow () {
        Object (application: Application.instance,
                height_request: 600,
                icon_name: "com.github.devalien.workspaces",
                resizable: true,
                title: _ ("Workspaces"),
                width_request: 700);

        //  var dark = new Theme ().is_theme_dark ();
        //  warning (@"Theme settings: $dark");
    }

    construct {
        add_action_entries (ACTION_ENTRIES, this);

        workspaces_controller = Application.instance.workspaces_controller;
        var provider = new Gtk.CssProvider ();

        window_position = Gtk.WindowPosition.CENTER;
        set_default_size (600, 700);
        settings = Application.instance.settings;

        //Define to move the windows to the last position or keep it centre
        var do_last_position = settings.get_boolean("save-last-window-position");
        if (do_last_position)
            move (settings.get_int ("pos-x"), settings.get_int ("pos-y"));

        set_geometry_hints (null, Gdk.Geometry () {
            min_height = 440, min_width = 900
        }, Gdk.WindowHints.MIN_SIZE);

        resize (settings.get_int ("window-width"), settings.get_int ("window-height"));

        key_press_event.connect(this.handle_key_events);

        delete_event.connect (e => {
            return before_destroy ();
        });

        var workspaces = load_data ();

        /* Start Stack Container */
        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        stack.get_style_context ().add_class ("right-stack");

        var welcome = new Workspaces.Widgets.Welcome ();
        stack.add_named (welcome, "welcome");
        var item_editor = new Workspaces.Views.ItemEditor ();
        stack.add_named (item_editor, "editor");
        /* End Stack Container */

        /* Start Sidebar SourceList */
        source_list = new Granite.Widgets.SourceList ();
        foreach (var workspace in workspaces) {
            set_source_list_workspace (workspace);
        }

        source_list.set_size_request (160, -1);

        source_list.item_selected.connect ((item) => {
            var i = item as Workspaces.Widgets.WorkspaceItem;
            item_editor.load_item (i);
            stack.set_visible_child_name ("editor");
        });

        workspaces_controller.workspace_added.connect ((workspace) => {
            set_source_list_workspace (workspace);
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
        add_workspace_button.get_style_context ().add_class ("ql-button");
        add_workspace_button.clicked.connect (() => {
            show_add_workspace_dialog ();
        });

        var add_item_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
        add_item_button.valign = Gtk.Align.CENTER;
        add_item_button.halign = Gtk.Align.START;
        add_item_button.always_show_image = true;
        add_item_button.can_focus = false;
        add_item_button.label = _ ("Add Item");
        add_item_button.get_style_context ().add_class ("flat");
        add_item_button.get_style_context ().add_class ("font-bold");
        add_item_button.get_style_context ().add_class ("add-button");
        add_item_button.clicked.connect (() => {
            show_add_item_dialog ();
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
        action_box.pack_start (add_item_button, false, false, 0);
        /* End Sidebar Bottom Actions */

        /* Start Sidebar */
        var sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sidebar.get_style_context ().add_class ("pane");
        sidebar.pack_start (source_list, true, true, 0);
        sidebar.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
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

        var settings_menuitem = new Gtk.ModelButton ();
        settings_menuitem.text = _ ("Settings");
        settings_menuitem.action_name = ACTION_PREFIX + ACTION_SETTINGS;

        var about_menuitem = new Gtk.ModelButton ();
        about_menuitem.text = _ ("About");
        about_menuitem.action_name = ACTION_PREFIX + ACTION_ABOUT;


        var gtk_settings = Gtk.Settings.get_default ();
        var mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
            );
        mode_switch.primary_icon_tooltip_text = _ ("Light mode");
        mode_switch.secondary_icon_tooltip_text = _ ("Dark mode");
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.bind_property ("active", gtk_settings, "gtk-application-prefer-dark-theme", GLib.BindingFlags.BIDIRECTIONAL);

        var accel = "";
        string ? accel_path = null;

        CustomShortcutSettings.init ();
        foreach (var shortcut in CustomShortcutSettings.list_custom_shortcuts ()) {
            if (is_flatpak ()) {
                if (shortcut.command == Workspaces.Application.FLATPAK_SHOW_WORKSPACES_CMD) {
                    accel = shortcut.shortcut;
                    accel_path = shortcut.relocatable_schema;
                }
            } else {
                if (shortcut.command == Workspaces.Application.SHOW_WORKSPACES_CMD) {
                    accel = shortcut.shortcut;
                    accel_path = shortcut.relocatable_schema;
                }
            }
        }

        var undo_menuitem = new Gtk.ModelButton ();
        undo_menuitem.get_child ().destroy ();
        undo_menuitem.add (new Granite.AccelLabel ("Open Quick Launcher", accel));
        undo_menuitem.action_name = ACTION_PREFIX + ACTION_QUICK_LAUNCHER;
        Application.instance.update_command.connect ((command) => {
            undo_menuitem.get_child ().destroy ();
            undo_menuitem.add (new Granite.AccelLabel ("Open Quick Launcher", command));
        });

        var menu_grid = new Gtk.Grid ();
        menu_grid.margin_bottom = 3;
        menu_grid.margin_top = 5;
        menu_grid.row_spacing = 3;
        menu_grid.orientation = Gtk.Orientation.VERTICAL;
        menu_grid.attach (undo_menuitem, 0,0, 3, 1);
        menu_grid.attach (new Gtk.SeparatorMenuItem (), 0, 1, 3, 1);
        menu_grid.attach (settings_menuitem, 0, 2, 3, 1);
        menu_grid.attach (new Gtk.SeparatorMenuItem (), 0, 3, 3, 1);
        menu_grid.attach (about_menuitem, 0, 4, 3, 1);
        menu_grid.show_all ();

        var menu = new Gtk.Popover (null);
        menu.add (menu_grid);


        var prefs_button = new Gtk.MenuButton ();
        prefs_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        prefs_button.valign = Gtk.Align.CENTER;
        prefs_button.sensitive = true;
        prefs_button.tooltip_text = _ ("Preferences");
        prefs_button.popover = menu;
        right_header.pack_end (prefs_button);

        //  var load_ql_button = new Gtk.Button.from_icon_name ("system-search-symbolic", Gtk.IconSize.MENU);
        //  load_ql_button.valign = Gtk.Align.CENTER;
        //  load_ql_button.halign = Gtk.Align.END;
        //  load_ql_button.always_show_image = true;
        //  load_ql_button.can_focus = false;
        //  load_ql_button.get_style_context ().add_class ("flat");
        //  load_ql_button.get_style_context ().add_class ("font-bold");
        //  load_ql_button.get_style_context ().add_class ("ql-button");
        //  load_ql_button.clicked.connect (() => {
        //      Application.instance.load_quick_launch ();
        //  });
        //  right_header.pack_end (load_ql_button);
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

    bool handle_key_events(Gtk.Widget widget , Gdk.EventKey event) {

        switch (event.keyval) {
            case Gdk.Key.Escape :
                close ();
                return true;
            default :
                return false;
            }
    }

    private void set_source_list_workspace (Workspaces.Models.Workspace workspace) {
        var w = new Workspaces.Widgets.ExpandableCategory (workspace);
        source_list.root.add (w);
        w.added_new_item.connect ((item) => {
            source_list.selected = item;
        });

        w.item_deleted.connect ((item) => {
            if (source_list.selected != null) {
                if (source_list.selected == item) {
                    stack.set_visible_child_name ("welcome");
                }
            }
        });
    }
    public void show_add_workspace_dialog () {
        var dialog = new Workspaces.Dialogs.AddWorkspace (this);

        dialog.show_all ();
        dialog.creation.connect ((workspace) => {
            workspaces_controller.add_workspace (workspace);
        });
    }

    public void show_add_item_dialog () {
        var data = load_data ();
        debug (data.size.to_string ());
        if (data == null || data.size == 0) {
            var dialogd = new Gtk.Dialog.with_buttons (_ ("Cannot create an item without a workspace"), this,
                                                       Gtk.DialogFlags.MODAL,
                                                       _ ("Ok"),
                                                       Gtk.ResponseType.OK, null);

            var content_area = dialogd.get_content_area ();
            var label = new Gtk.Label (_ ("To add an item you first need to create a workspace."));
            label.get_style_context ().add_class ("h4");
            label.get_style_context ().add_class ("dialog-label");
            content_area.add (label);

            dialogd.response.connect (on_response);

            dialogd.show_all ();
            return;
        }

        var dialog = new Workspaces.Dialogs.AddItem (this, data);

        dialog.show_all ();
        dialog.creation.connect ((item, workspace) => {
            workspaces_controller.add_item (item, workspace);
        });
    }

    private void on_response (Gtk.Dialog dialog, int response_id) {
        /* To see the int value of the ResponseType. This is only
         * for demonstration purposes.*/
        print ("response is %d\n", response_id);

/* This causes the dialog to be destroyed. */
        dialog.destroy ();
    }

    private ArrayList<Workspaces.Models.Workspace> load_data () {
        return workspaces_controller.get_all ();
    }

    private void on_action_about () {
        var dialog = new Workspaces.Dialogs.AboutDialog (this);
        dialog.present ();
    }

    private void on_action_settings () {
        var dialog = new Workspaces.Dialogs.Preferences (false, this);
        dialog.present ();
    }

    private void on_action_quick_launcher () {
        Application.instance.load_quick_launch ();
    }

    public bool before_destroy () {
        int width, height, x, y;

        get_size (out width, out height);
        get_position (out x, out y);

        settings.set_int ("pos-x", x);
        settings.set_int ("pos-y", y);
        settings.set_int ("window-height", height);
        settings.set_int ("window-width", width);
        Workspaces.Application.instance.close_preferences ();
        return false;
    }
}
