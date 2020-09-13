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

    public Gtk.ListBox workspaces_list;

    private Workspaces.Views.ItemEditor item_editor;
    private Workspaces.Views.WorkspaceEditor workspace_editor;
    public const string ACTION_PREFIX = "win.";
    public const string ACTION_ABOUT = "action_about";
    public const string ACTION_SETTINGS = "action_settings";
    public const string ACTION_QUICK_LAUNCHER = "action_quick_launcher";
    private signal void refresh_favourites ();
    private const Gtk.TargetEntry[] TARGET_WORKSPACES = {
        {"WORKSPACEROW", Gtk.TargetFlags.SAME_APP, 0}
    };
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
        var do_last_position = settings.get_boolean ("save-last-window-position");
        if (do_last_position)
            move (settings.get_int ("pos-x"), settings.get_int ("pos-y"));

        set_geometry_hints (null, Gdk.Geometry () {
            min_height = 440, min_width = 900
        }, Gdk.WindowHints.MIN_SIZE);

        resize (settings.get_int ("window-width"), settings.get_int ("window-height"));

        key_press_event.connect (this.handle_key_events);

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
        workspace_editor = new Workspaces.Views.WorkspaceEditor ();
        stack.add_named (workspace_editor, "workspace_editor");
        item_editor = new Workspaces.Views.ItemEditor ();
        stack.add_named (item_editor, "item_editor");
        /* End Stack Container */

        /* Start Sidebar workspaces */
        workspaces_list = new Gtk.ListBox ();
        workspaces_list.get_style_context ().add_class ("pane");
        workspaces_list.activate_on_single_click = true;
        workspaces_list.selection_mode = Gtk.SelectionMode.SINGLE;
        workspaces_list.hexpand = true;
        workspaces_list.vexpand = true;


        foreach (var workspace in workspaces) {
            add_workspace_to_list (workspace);
        }


        workspaces_controller.workspace_added.connect ((workspace) => {
            add_workspace_to_list (workspace);
        });
        /* End Sidebar workspaces */

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

        var drop_area_grid = new Gtk.Grid ();
        drop_area_grid.margin_start = 6;
        drop_area_grid.margin_end = 6;
        drop_area_grid.height_request = 12;

        var motion_area_grid = new Gtk.Grid ();
        motion_area_grid.margin_start = 6;
        motion_area_grid.margin_end = 6;
        motion_area_grid.margin_bottom = 12;
        motion_area_grid.height_request = 24;
        motion_area_grid.get_style_context ().add_class ("grid-motion");

        var motion_area_revealer = new Gtk.Revealer ();
        motion_area_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        motion_area_revealer.add (motion_area_grid);

        Gtk.drag_dest_set (workspaces_list, Gtk.DestDefaults.ALL, TARGET_WORKSPACES, Gdk.DragAction.MOVE);
        workspaces_list.drag_data_received.connect (on_drag_data_received_workspace);

        Gtk.drag_dest_set (drop_area_grid, Gtk.DestDefaults.ALL, TARGET_WORKSPACES, Gdk.DragAction.MOVE);
        drop_area_grid.drag_data_received.connect (on_drag_data_received_workspace_top);

        drop_area_grid.drag_motion.connect ((context, x, y, time) => {
            motion_area_revealer.reveal_child = true;
            return true;
        });

        drop_area_grid.drag_leave.connect ((context, time) => {
            motion_area_revealer.reveal_child = false;
        });

        var listbox_scrolled = new Gtk.ScrolledWindow (null, null);
        //  listbox_scrolled.width_request = 238;
        listbox_scrolled.hexpand = true;
        listbox_scrolled.margin_bottom = 6;
        listbox_scrolled.add (workspaces_list);

        /* Start Sidebar */
        var sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sidebar.get_style_context ().add_class ("pane");
        sidebar.add (drop_area_grid);
        sidebar.add (motion_area_revealer);

        sidebar.pack_start (listbox_scrolled, true, true, 0);
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
        undo_menuitem.add (new Granite.AccelLabel (_ ("Open Quick Launcher"), accel));
        undo_menuitem.action_name = ACTION_PREFIX + ACTION_QUICK_LAUNCHER;
        Application.instance.update_command.connect ((command) => {
            undo_menuitem.get_child ().destroy ();
            undo_menuitem.add (new Granite.AccelLabel (_ ("Open Quick Launcher"), command));
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
        prefs_button.get_style_context ().add_class ("flat");
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

        workspaces_list.row_selected.connect ((row) => {
            if (row != null) {
                var item = ((Workspaces.Widgets.WorkspaceRow)row);
                Application.instance.unselect_all_items (item);
            }
        });
        show_all ();
    }

    private void on_drag_data_received_workspace_top (Gdk.DragContext context, int x, int y,
                                                      Gtk.SelectionData selection_data, uint target_type, uint time) {
        Workspaces.Widgets.WorkspaceRow source;
        var row = ((Gtk.Widget[])selection_data.get_data ())[0];
        source = (Workspaces.Widgets.WorkspaceRow)row;


        source.get_parent ().remove (source);

        workspaces_list.insert (source, 0);
        Application.instance.workspaces_controller.move_workspace (source.workspace, 0);

        workspaces_list.show_all ();
    }

    private void on_drag_data_received_workspace (Gdk.DragContext context, int x, int y,
                                                  Gtk.SelectionData selection_data, uint target_type, uint time) {
        Workspaces.Widgets.WorkspaceRow target;
        Workspaces.Widgets.WorkspaceRow source;
        Gtk.Allocation alloc;

        target = (Workspaces.Widgets.WorkspaceRow)workspaces_list.get_row_at_y (y);
        target.get_allocation (out alloc);

        var row = ((Gtk.Widget[])selection_data.get_data ())[0];
        source = (Workspaces.Widgets.WorkspaceRow)row;

        if (target != null) {
            source.get_parent ().remove (source);

            workspaces_list.insert (source, target.get_index () + 1);
            Application.instance.workspaces_controller.move_workspace (source.workspace, target.get_index () + 1);

            workspaces_list.show_all ();
        }
    }

    public void load_item (Workspaces.Widgets.ItemRow item) {
        item_editor.load_item (item);
        stack.set_visible_child_name ("item_editor");
    }

    public void load_workspace (Workspaces.Widgets.WorkspaceRow workspace) {
        workspace_editor.load_workspace (workspace);
        stack.set_visible_child_name ("workspace_editor");
    }
    bool handle_key_events (Gtk.Widget widget, Gdk.EventKey event) {
        switch (event.keyval) {
        case Gdk.Key.Escape :
            close ();
            return true;
        default :
            return false;
        }
    }

    private void add_workspace_to_list (Workspaces.Models.Workspace workspace) {
        var w = new Workspaces.Widgets.WorkspaceRow (workspace);
        workspaces_list.add (w);
        //  w.added_new_item.connect ((item) => {
        //      debug ("DE");
        //  });
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

    public void delete_workspace_dialog (Workspaces.Widgets.WorkspaceRow workspace_row) {
        var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
            _ ("You are deleting %s").printf (workspace_row.workspace.name),
            _ ("Deleting a workspace is an irreversible action. Are you sure you want to delete it?"),
            "dialog-warning",
            Gtk.ButtonsType.CANCEL
            );

        var remove_button = new Gtk.Button.with_label (_ ("DELETE"));
        remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        message_dialog.add_action_widget (remove_button, Gtk.ResponseType.APPLY);
        message_dialog.show_all ();
        if (message_dialog.run () == Gtk.ResponseType.APPLY) {
            var is_removed = workspaces_controller.remove_workspace (workspace_row.workspace);
            if (is_removed) {
                workspaces_list.remove (workspace_row);
            }
        }
        message_dialog.destroy ();
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
