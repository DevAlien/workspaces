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

public class Workspaces.Widgets.ItemRow : Gtk.ListBoxRow {
    //  public Workspaces.Models.Item item {get; set;}
    public Workspaces.Models.Item item { get; construct; }
    public Gtk.ScrolledWindow scrolled { get; set; }

    private Gtk.Image area_image;
    private Gtk.Button submit_button;
    private Gtk.Label name_label;
    private Widgets.Entry name_entry;
    private Gtk.Stack name_stack;
    private Gtk.EventBox handle;
    private Workspaces.Widgets.Dot auto_start_dot;

    private Gtk.Revealer motion_revealer;
    private Gtk.Revealer motion_area_revealer;
    private Gtk.Grid drop_grid;
    private Gtk.Revealer action_revealer;
    public Gtk.Revealer main_revealer;

    public bool is_open {get; set; default = true;}

    private const Gtk.TargetEntry[] TARGET_ITEMS = {
        {"ITEMROW", Gtk.TargetFlags.SAME_APP, 0}
    };


    public bool set_focus {
        set {
            submit_button.sensitive = true;
            action_revealer.reveal_child = true;
            name_stack.visible_child_name = "name_entry";

            name_entry.grab_focus_without_selecting ();
            if (name_entry.cursor_position < name_entry.text_length) {
                name_entry.move_cursor (Gtk.MovementStep.BUFFER_ENDS, (int32)name_entry.text_length, false);
            }
        }
    }
    public bool reveal_drag_motion {
        set {
            motion_revealer.reveal_child = value;
        }
        get {
            return motion_revealer.reveal_child;
        }
    }

    public ItemRow (Workspaces.Models.Item item) {
        Object (item: item

                );
    }


    construct {
        can_focus = false;
        get_style_context ().add_class ("item-row");

        area_image = new Gtk.Image ();
        area_image.halign = Gtk.Align.CENTER;
        area_image.valign = Gtk.Align.CENTER;
        if (item.icon != null) {
            try {
                area_image.gicon = Icon.new_for_string (item.icon);
            } catch (Error e) {
                debug (e.message);
            }
        }
        area_image.pixel_size = 20;
        area_image.margin_end = 4;

        var executor_icon = new Gtk.Image ();
        executor_icon.gicon = new ThemedIcon ("media-playback-start");
        executor_icon.pixel_size = 14;
        var executor_button = new Gtk.Button ();
        executor_button.valign = Gtk.Align.CENTER;
        executor_button.can_focus = false;
        executor_button.image = executor_icon;
        executor_button.tooltip_text = _ ("Execute command");
        executor_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        executor_button.get_style_context ().add_class ("executor-button");

        executor_button.clicked.connect (() => {
            item.execute_command ();
        });

        name_label = new Gtk.Label (item.name);
        name_label.halign = Gtk.Align.START;
        name_label.get_style_context ().add_class ("left-list-label");
        name_label.valign = Gtk.Align.CENTER;
        name_label.set_ellipsize (Pango.EllipsizeMode.END);

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.pack_start (area_image, false, false, 0);
        top_box.pack_start (name_label, false, true, 0);
        top_box.pack_end (executor_button, false, false, 0);
        auto_start_dot = new Workspaces.Widgets.Dot ();

        top_box.pack_end (auto_start_dot, false, false, 4);

        top_box.get_style_context ().add_class ("item-row2");
        var motion_grid = new Gtk.Grid ();
        motion_grid.margin_start = 6;
        motion_grid.margin_end = 6;
        motion_grid.height_request = 24;
        motion_grid.get_style_context ().add_class ("grid-motion");

        motion_revealer = new Gtk.Revealer ();
        motion_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        motion_revealer.add (motion_grid);

        drop_grid = new Gtk.Grid ();
        drop_grid.margin_start = 6;
        drop_grid.margin_end = 6;
        drop_grid.height_request = 12;


        var motion_area_grid = new Gtk.Grid ();
        motion_area_grid.margin_start = 6;
        motion_area_grid.margin_end = 6;
        motion_area_grid.height_request = 24;
        motion_area_grid.margin_bottom = 12;
        motion_area_grid.get_style_context ().add_class ("grid-motion");

        motion_area_revealer = new Gtk.Revealer ();
        motion_area_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        motion_area_revealer.add (motion_area_grid);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.hexpand = true;
        main_box.pack_start (top_box, false, false, 0);
        //  main_box.pack_start (action_revealer, false, false, 0);
        main_revealer = new Gtk.Revealer ();
        main_revealer.reveal_child = true;
        main_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        main_revealer.add (main_box);

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.margin_top = grid.margin_bottom = 2;
        grid.add (main_revealer);
        grid.add (motion_revealer);



        handle = new Gtk.EventBox ();
        handle.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        handle.expand = true;
        handle.above_child = false;
        handle.add (grid);

        var aain_revealer = new Gtk.Revealer ();
        aain_revealer.reveal_child = true;
        aain_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        aain_revealer.add (handle);

        add (aain_revealer);
        Gtk.drag_source_set (this, Gdk.ModifierType.BUTTON1_MASK, TARGET_ITEMS, Gdk.DragAction.MOVE);
        drag_begin.connect (on_drag_begin);
        drag_data_get.connect (on_drag_data_get);
        build_drag_and_drop ();
        update_auto_start_dot ();
        show_all ();
    }

    public void set_icon (GLib.Icon icon) {
        area_image.gicon = icon;
    }

    public void set_label (string label) {
        name_label.set_label (label);
    }

    public void update_auto_start_dot () {
        if (item.auto_start) {
            auto_start_dot.set_is_hidden (false);
        } else {
            auto_start_dot.set_is_hidden (true);
        }
    }

    private void on_drag_begin (Gtk.Widget widget, Gdk.DragContext context) {
        var row = ((Workspaces.Widgets.ItemRow)widget).handle;

        Gtk.Allocation alloc;
        row.get_allocation (out alloc);

        var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, alloc.width, alloc.height);
        var cr = new Cairo.Context (surface);
        cr.set_source_rgba (0, 0, 0, 0);
        cr.set_line_width (1);

        cr.move_to (0, 0);
        cr.line_to (alloc.width, 0);
        cr.line_to (alloc.width, alloc.height);
        cr.line_to (0, alloc.height);
        cr.line_to (0, 0);
        cr.stroke ();

        cr.set_source_rgba (255, 255, 255, 0);
        cr.rectangle (0, 0, alloc.width, alloc.height);
        cr.fill ();

        row.get_style_context ().add_class ("drag-begin");
        row.draw (cr);
        row.get_style_context ().remove_class ("drag-begin");

        Gtk.drag_set_icon_surface (context, surface);
        main_revealer.reveal_child = false;
    }

    private void on_drag_data_get (Gtk.Widget widget, Gdk.DragContext context,
                                   Gtk.SelectionData selection_data, uint target_type, uint time) {
        uchar[] data = new uchar[(sizeof (Workspaces.Widgets.ItemRow))];
        ((Gtk.Widget[])data)[0] = widget;

        selection_data.set (
            Gdk.Atom.intern_static_string ("ITEMROW"), 32, data
            );
    }

    private void build_drag_and_drop () {
        Gtk.drag_dest_set (this, Gtk.DestDefaults.MOTION, TARGET_ITEMS, Gdk.DragAction.MOVE);
        drag_motion.connect (on_drag_motion);
        drag_leave.connect (on_drag_leave);
        drag_end.connect (clear_indicator);
    }

    public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
        reveal_drag_motion = true;
        return true;
    }

    public void on_drag_leave (Gdk.DragContext context, uint time) {
        reveal_drag_motion = false;
    }

    public bool on_drag_item_motion (Gdk.DragContext context, int x, int y, uint time) {
        get_style_context ().add_class ("highlight");
        return true;
    }

    public void on_drag_item_leave (Gdk.DragContext context, uint time) {
        get_style_context ().remove_class ("highlight");
    }

    public void clear_indicator (Gdk.DragContext context) {
        //  reveal_drag_motion = false;
        main_revealer.reveal_child = true;
    }

    public void remove_itself () {
        var has_deleted = Application.instance.workspaces_controller.remove_item (item);
        if (has_deleted) {
            get_parent ().remove (this);
            Application.instance.preferences_window.stack.set_visible_child_name ("welcome");
        }
    }
}