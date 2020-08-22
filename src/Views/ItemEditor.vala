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

public class Workspaces.Widgets.FieldEntry : Gtk.Box {
    public Gtk.Entry entry { get; construct; }

    private Gtk.Revealer revealer;

    construct {
        orientation = Gtk.Orientation.VERTICAL;

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
    private Gtk.Switch auto_start_switch;

    private Gtk.Button delete_button;
    private Granite.Widgets.Toast toast;
    private Gtk.Grid settings_grid;
    private Gtk.InfoBar error_info_bar;
    private Gtk.Label error_label;
    private Workspaces.Widgets.TypeComboBox type_combo;

    private Workspaces.Widgets.SettingsGrid settings_sg;

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
        name_entry.changed.connect (() => {
            item.item.name = name_entry.get_text ();
            item.name = name_entry.get_text ();
            Workspaces.Application.instance.preferences_window.workspaces_controller.save ();
        });
        header_box.add (header_label);
        header_box.add (name_entry);
        name_box.add (header_box);
        type_combo = new Workspaces.Widgets.TypeComboBox ();
        type_combo.set_current_selection ("");
        type_combo.changed.connect ((asd) => {
            var item_id = type_combo.get_selected_category_id ();
            if (item_id != "" && item.item.item_type != item_id) {
                item.item.item_type = item_id;
                Workspaces.Application.instance.preferences_window.workspaces_controller.save ();

                load_widgets_by_type (item_id);
            }
        });
        name_box.add (type_combo);

        var header_grid = new Gtk.Grid ();
        header_grid.column_spacing = 12;
        header_grid.row_spacing = 6;
        header_grid.margin_start = 24;
        header_grid.margin_end = 24;
        header_grid.margin_top = 24;
        header_grid.attach (icon_button, 0, 0, 1, 1);
        header_grid.attach (name_box, 1, 0, 1, 1);

        settings_sg = new Workspaces.Widgets.SettingsGrid (_ ("Settings"));
        auto_start_switch = new Gtk.Switch ();
        auto_start_switch.notify["active"].connect (() => {
            item.item.auto_start = auto_start_switch.state;
            Workspaces.Application.instance.workspaces_controller.save ();
        });
        var auto_box = new Workspaces.Widgets.SettingBox (_ ("Auto Launch with workspace"), auto_start_switch, false);
        settings_sg.add_widget (auto_box);

        settings_grid = new Gtk.Grid ();
        settings_grid.row_spacing = 12;
        settings_grid.margin_start = 24;
        settings_grid.margin_end = 24;
        settings_grid.attach (settings_sg, 0, 2, 1, 1);


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

        var test_button = new Gtk.Button.with_label (_ ("Test"));
        test_button.clicked.connect (() => {
            item.item.execute_command ();
        });

        var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        button_box.margin = 6;

        button_box.pack_start (duplicate_button, false, false);
        button_box.pack_start (test_button, false, false);
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

    private void load_widgets_by_type (string type) {
        switch (type) {
        case "Application" :
            load_widgets_application ();
            break;
        case "ApplicationDirectory" :
            load_widgets_application_directory ();
            break;
        case "Directory" :
            load_widgets_directory ();
            break;
        case "URL" :
            load_widgets_url ();
            break;
        case "Custom" :
            load_widgets_custom ();
            break;
        }
    }

    private void load_widgets_custom () {
        var custom_command_entry = new Workspaces.Widgets.Entry ();
        custom_command_entry.margin_start = 8;
        custom_command_entry.margin_end = 8;
        custom_command_entry.hexpand = true;
        custom_command_entry.placeholder_text = _ ("Program to execute along with it's arguments");
        custom_command_entry.changed.connect (() => {
            item.item.command = custom_command_entry.get_text ();
            Workspaces.Application.instance.workspaces_controller.save ();
        });

        var executable_box = new Workspaces.Widgets.SettingBox (_ ("Command Line"), custom_command_entry, false);
        //  var terminal_box = new Workspaces.Widgets.SettingBox (_ ("Auto Launch with workspace"), auto_start_switch, true);
        var custom_settings_grid = new Workspaces.Widgets.SettingsGrid (_ ("Custom Settings"));
        custom_settings_grid.add_widget (executable_box);

        name_entry.set_text (item.item.name);
        if (item.item.command == null) {
            custom_command_entry.set_text ("");
        } else {
            custom_command_entry.set_text (item.item.command);
        }

        settings_grid.foreach ((element) => settings_grid.remove (element));
        settings_grid.attach (custom_settings_grid, 0, 0, 1, 1);
        settings_grid.attach (settings_sg, 0, 1, 1, 1);
        settings_grid.show_all ();
    }

    private void load_widgets_url () {
        var website_url_entry = new Workspaces.Widgets.Entry ();
        website_url_entry.margin_start = 8;
        website_url_entry.margin_end = 8;
        website_url_entry.hexpand = true;
        //  website_url_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        website_url_entry.placeholder_text = _ ("Url that will be opened when lauched");
        website_url_entry.changed.connect (() => {
            item.item.command = website_url_entry.get_text ();
            Workspaces.Application.instance.workspaces_controller.save ();
        });

        var website_box = new Workspaces.Widgets.SettingBox (_ ("Website URL"), website_url_entry, false);

        var url_settings_grid = new Workspaces.Widgets.SettingsGrid (_ ("URL Settings"));
        url_settings_grid.add_widget (website_box);

        name_entry.set_text (item.item.name);
        if (item.item.command == null) {
            website_url_entry.set_text ("");
        } else {
            website_url_entry.set_text (item.item.command);
        }

        settings_grid.foreach ((element) => settings_grid.remove (element));
        settings_grid.attach (url_settings_grid, 0, 0, 1, 1);
        settings_grid.show_all ();
    }

    private void load_widgets_application () {
        var icon = new Gtk.Image ();
        icon.set_pixel_size (24);
        icon.set_from_icon_name (item.item.app_info.icon_name, Gtk.IconSize.SMALL_TOOLBAR);

        var text = new Gtk.Label ("");
        text.halign = Gtk.Align.START;
        //  text.get_style_context ().add_class ("h3");
        text.lines = 1;
        text.single_line_mode = true;

        var app_chooser_popover = new Workspaces.Popovers.AppChooserPopover ();
        app_chooser_popover.selected.connect ((app_info) => {
            item.item.app_info = app_info;
            if (item.item.app_info.icon_name != null) {
                icon.set_from_icon_name (item.item.app_info.icon_name, Gtk.IconSize.SMALL_TOOLBAR);
            }
            if (app_info.name != null) {
                text.set_text (app_info.name);
            }
            Workspaces.Application.instance.workspaces_controller.save ();
            app_chooser_popover.popdown ();
        });
        var application_button = new Gtk.Button.with_label (_ ("Select Application"));
        application_button.clicked.connect ( () => {
            app_chooser_popover.set_relative_to (application_button);
            app_chooser_popover.show_all ();
            app_chooser_popover.popup ();
        });

        var application_entry_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,8);
        application_entry_box.margin_start = 8;
        application_entry_box.margin_end = 8;
        application_entry_box.hexpand = true;
        if (item.item.app_info != null) {
            var app_info = item.item.app_info;
            if (item.item.app_info.icon_name != null) {
                icon.set_from_icon_name (item.item.app_info.icon_name, Gtk.IconSize.SMALL_TOOLBAR);
            }
            if (app_info.name != null) {
                text.set_text (app_info.name);
            }
        }
        var application_entry_pack = new Gtk.Box (Gtk.Orientation.HORIZONTAL,8);

        application_entry_pack.pack_start (icon, false, false);
        application_entry_pack.pack_start (text);
        application_entry_box.pack_start (application_entry_pack);
        application_entry_box.pack_end (application_button, false, false);

        var application_box = new Workspaces.Widgets.SettingBox (_ ("Application to launch"), application_entry_box, false);

        var app_settings_grid = new Workspaces.Widgets.SettingsGrid (_ ("Application Settings"));
        app_settings_grid.add_widget (application_box);

        settings_grid.foreach ((element) => settings_grid.remove (element));
        settings_grid.attach (app_settings_grid, 0, 0, 1, 1);
        settings_grid.attach (settings_sg, 0, 1, 1, 1);
        settings_grid.show_all ();
    }

    private void load_widgets_application_directory () {
        var icon = new Gtk.Image ();
        icon.set_pixel_size (24);
        icon.set_from_icon_name (item.item.app_info.icon_name, Gtk.IconSize.SMALL_TOOLBAR);

        var text = new Gtk.Label ("");
        text.halign = Gtk.Align.START;
        //  text.get_style_context ().add_class ("h3");
        text.lines = 1;
        text.single_line_mode = true;


        var app_chooser_popover = new Workspaces.Popovers.AppChooserPopover ();
        app_chooser_popover.selected.connect ((app_info) => {
            item.item.app_info = app_info;
            if (item.item.app_info.icon_name != null) {
                icon.set_from_icon_name (item.item.app_info.icon_name, Gtk.IconSize.SMALL_TOOLBAR);
            }
            if (app_info.name != null) {
                text.set_text (app_info.name);
            }
            Workspaces.Application.instance.workspaces_controller.save ();
            app_chooser_popover.popdown ();
        });
        var application_button = new Gtk.Button.with_label (_ ("Select Application"));
        application_button.clicked.connect ( () => {
            app_chooser_popover.set_relative_to (application_button);
            app_chooser_popover.show_all ();
            app_chooser_popover.popup ();
        });

        var application_entry_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,8);
        application_entry_box.margin_start = 8;
        application_entry_box.margin_end = 8;
        application_entry_box.hexpand = true;
        if (item.item.app_info != null) {
            var app_info = item.item.app_info;
            if (item.item.app_info.icon_name != null) {
                icon.set_from_icon_name (item.item.app_info.icon_name, Gtk.IconSize.SMALL_TOOLBAR);
            }
            if (app_info.name != null) {
                text.set_text (app_info.name);
            }
        }
        var application_entry_pack = new Gtk.Box (Gtk.Orientation.HORIZONTAL,8);

        application_entry_pack.pack_start (icon, false, false);
        application_entry_pack.pack_start (text);
        application_entry_box.pack_start (application_entry_pack);
        application_entry_box.pack_end (application_button, false, false);

        var application_box = new Workspaces.Widgets.SettingBox (_ ("Application to launch"), application_entry_box, false);

        var directory_entry_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
        directory_entry_box.margin_start = 8;
        directory_entry_box.margin_end = 8;
        directory_entry_box.hexpand = true;

        var directory_entry = new Workspaces.Widgets.Entry ();
        directory_entry.placeholder_text = _ ("Path to the directory");
        directory_entry.hexpand = true;
        directory_entry.changed.connect (() => {
            item.item.directory = directory_entry.get_text ();
            Workspaces.Application.instance.workspaces_controller.save ();
        });

        var directory_button = new Gtk.Button.with_label (_ ("Choose Directory"));
        directory_button.clicked.connect ( () => {
            var file_chooser = new Gtk.FileChooserDialog (
                _ ("Select an image"), Application.instance.preferences_window, Gtk.FileChooserAction.SELECT_FOLDER,
                "_Cancel",
                Gtk.ResponseType.CANCEL,
                "_Open",
                Gtk.ResponseType.ACCEPT
                );
            file_chooser.response.connect ((response) => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    string uri = file_chooser.get_filename ();
                    item.item.directory = uri;
                    directory_entry.text = uri;
                    Workspaces.Application.instance.workspaces_controller.save ();
                }

                file_chooser.destroy ();
            });

            file_chooser.run ();
        });
        directory_entry_box.add (directory_entry);
        directory_entry_box.add (directory_button);
        var directory_box = new Workspaces.Widgets.SettingBox (_ ("Directory to open"), directory_entry_box, false);
        //  url_settings_grid.add_widget (application_box);

        var directory_settings_grid = new Workspaces.Widgets.SettingsGrid (_ ("Application Directory Settings"));
        directory_settings_grid.add_widget (application_box);
        directory_settings_grid.add_widget (directory_box);

        if (item.item.directory == null) {
            directory_entry.set_text ("");
        } else {
            directory_entry.set_text (item.item.directory);
        }

        settings_grid.foreach ((element) => settings_grid.remove (element));
        settings_grid.attach (directory_settings_grid, 0, 0, 1, 1);
        settings_grid.attach (settings_sg, 0, 1, 1, 1);
        settings_grid.show_all ();
    }

    private void load_widgets_directory () {
        // directory
        var directory_entry_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
        directory_entry_box.margin_start = 8;
        directory_entry_box.margin_end = 8;
        directory_entry_box.hexpand = true;

        var directory_entry = new Workspaces.Widgets.Entry ();
        directory_entry.placeholder_text = _ ("Path to the directory");
        directory_entry.hexpand = true;
        directory_entry.changed.connect (() => {
            item.item.directory = directory_entry.get_text ();
            Workspaces.Application.instance.workspaces_controller.save ();
        });

        var directory_button = new Gtk.Button.with_label (_ ("Choose Directory"));
        directory_button.clicked.connect ( () => {
            var file_chooser = new Gtk.FileChooserDialog (
                _ ("Select an image"), Application.instance.preferences_window, Gtk.FileChooserAction.SELECT_FOLDER,
                "_Cancel",
                Gtk.ResponseType.CANCEL,
                "_Open",
                Gtk.ResponseType.ACCEPT
                );
            file_chooser.response.connect ((response) => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    string uri = file_chooser.get_filename ();
                    item.item.directory = uri;
                    directory_entry.text = uri;
                    Workspaces.Application.instance.workspaces_controller.save ();
                }

                file_chooser.destroy ();
            });

            file_chooser.run ();
        });
        directory_entry_box.add (directory_entry);
        directory_entry_box.add (directory_button);
        var directory_box = new Workspaces.Widgets.SettingBox (_ ("Directory to open"), directory_entry_box, false);
        //  url_settings_grid.add_widget (application_box);

        var directory_settings_grid = new Workspaces.Widgets.SettingsGrid (_ ("Directory Settings"));
        directory_settings_grid.add_widget (directory_box);

        if (item.item.directory == null) {
            directory_entry.set_text ("");
        } else {
            directory_entry.set_text (item.item.directory);
        }
        settings_grid.foreach ((element) => settings_grid.remove (element));
        settings_grid.attach (directory_settings_grid, 0, 0, 1, 1);
        settings_grid.show_all ();
    }

    public void load_item (Workspaces.Widgets.WorkspaceItem item) {
        this.item = item;

        if (item.icon == null) {
            icon_button.icon = Workspaces.Widgets.IconButton.default_icon;
        } else {
            icon_button.icon = item.icon;
        }

        name_entry.set_text (item.item.name);

        type_combo.set_current_selection ("");
        if (item.item.item_type != null) {
            type_combo.set_current_selection (item.item.item_type);
        } else {
            type_combo.set_current_selection ("Custom");
        }

        auto_start_switch.set_state (item.item.auto_start);
        load_widgets_by_type (item.item.item_type);
    }
}