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

public class Workspaces.QuickLaunchWindow : Gtk.Window {
    public signal void search_changed (string search_term);
    public signal void paste_item (int id);
    public signal void delete_item (int id);

    private Workspaces.Widgets.SearchListBox list_box;
    private Gtk.Stack stack;
    private Workspaces.Views.AlertView empty_alert;
    private Gtk.SearchEntry search_headerbar;
    public Workspaces.Controllers.WorkspacesController workspaces_controller;

    public QuickLaunchWindow (bool first_run) {
        Object (application: Application.instance,
                height_request: 700,
                icon_name: "com.github.devalien.workspaces",
                resizable: true,
                title: _ ("Workspaces"),
                width_request: 500);

        workspaces_controller = Application.instance.workspaces_controller;
        set_keep_above (true);
        window_position = Gtk.WindowPosition.CENTER;

        search_headerbar = new Gtk.SearchEntry ();
        search_headerbar.placeholder_text = _ ("Search Workspaces\u2026");
        search_headerbar.hexpand = true;

        search_headerbar.key_press_event.connect ((event) => {
            switch (event.keyval) {
            case Gdk.Key.Escape :
                close ();
                return true;
            default :
                return false;
            }
        });

        search_headerbar.search_changed.connect (() => {
            list_box.set_search_text (search_headerbar.text);
        });


        var style_context = search_headerbar.get_style_context ();
        style_context.add_class ("large-search-entry");


        var list_box_scroll = new Gtk.ScrolledWindow (null, null);
        list_box_scroll.vexpand = true;
        list_box = new Workspaces.Widgets.SearchListBox ();
        search_headerbar.search_changed.connect (() => {
            list_box.set_search_text (search_headerbar.text);
        });
        list_box_scroll.add (list_box);
        list_box_scroll.show_all ();

        list_box.row_activated.connect ((row) => {
            var search_item = row as Workspaces.Widgets.SearchListBoxItem;
            search_item.item.launch ();
        });

        empty_alert = new Workspaces.Views.AlertView (_ ("No Workspaces or Items Found"), "", "edit-find-symbolic");
        empty_alert.show_all ();

        var welcome = new Workspaces.Widgets.QuickWelcome ();

        stack = new Gtk.Stack ();
        stack.add_named (list_box_scroll, "listbox");
        stack.add_named (empty_alert, "empty");
        stack.add_named (welcome, "welcome");

        foreach (var item in workspaces_controller.get_all ()) {
            var entry = new Workspaces.Models.SearchItem ();
            entry.workspace = item;
            add_entry (entry);
            foreach (var it in item.items) {
                var item_entry = new Workspaces.Models.SearchItem ();
                item_entry.item = it;
                add_entry (item_entry);
            }
        }

        var add_workspace_button = new Gtk.Button.from_icon_name ("emblem-system-symbolic", Gtk.IconSize.MENU);
        add_workspace_button.valign = Gtk.Align.CENTER;
        add_workspace_button.halign = Gtk.Align.START;
        add_workspace_button.always_show_image = true;
        add_workspace_button.can_focus = false;
        add_workspace_button.label = _ ("Preferences");
        add_workspace_button.get_style_context ().add_class ("flat");
        add_workspace_button.get_style_context ().add_class ("font-bold");
        add_workspace_button.get_style_context ().add_class ("add-button");
        add_workspace_button.clicked.connect (() => {
            Application.instance.load_preferences ();
        });
        var add_revealer = new Gtk.Revealer ();
        add_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        add_revealer.reveal_child = true;
        add_revealer.add (add_workspace_button);

        var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        action_box.get_style_context ().add_class ("bottom-buttons");
        action_box.margin_end = 9;
        action_box.margin_top = 6;
        action_box.margin_bottom = 6;
        action_box.margin_start = 9;
        action_box.hexpand = true;
        action_box.pack_start (add_revealer, false, false, 0);
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.add (stack);
        main_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        main_box.add (action_box);

        add (main_box);

        key_press_event.connect ((event) => {
            switch (event.keyval) {
            case Gdk.Key.Down :
            case Gdk.Key.Up :
                bool has_selection = list_box.get_selected_rows ().length () > 0;
                if (!has_selection) {
                    list_box.select_row (list_box.get_row_at_index (0));
                }
                var rows = list_box.get_selected_rows ();
                if (rows.length () > 0) {
                    rows.nth_data (0).grab_focus ();
                }
                if (has_selection) {
                    list_box.key_press_event (event);
                }
                return true;
            case Gdk.Key.Return :
                return false;
            case Gdk.Key.Escape :
                close ();
                return true;
            default :
                break;
            }

            if (event.keyval != Gdk.Key.Escape && !search_headerbar.is_focus) {
                search_headerbar.grab_focus ();
                search_headerbar.key_press_event (event);
                return true;
            }

            return false;
        });

        set_titlebar (search_headerbar);
        search_headerbar.get_style_context ().remove_class ("titlebar");
        search_headerbar.get_style_context ().add_class ("ql-entry");
        show_all ();
        update_stack_visibility ();
        search_headerbar.grab_focus ();
        if (first_run) {
            var dialog = new Workspaces.Dialogs.Preferences (first_run, this);
            dialog.present ();
        }
    }

    public void add_entry (Workspaces.Models.SearchItem entry) {
        list_box.add (new Workspaces.Widgets.SearchListBoxItem (entry));
        update_stack_visibility ();
    }

    private void update_stack_visibility () {
        if (list_box.get_children ().length () > 0) {
            stack.visible_child_name = "listbox";
        } else if (search_headerbar.text.length == 0) {
            stack.visible_child_name = "welcome";
        } else {
            stack.visible_child_name = "empty";
            empty_alert.description = _ ("Try changing search terms.");
        }
    }
}