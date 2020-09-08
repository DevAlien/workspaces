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
    private Gtk.ListBox listbox;
    private Gtk.Revealer listbox_revealer;
    private Gtk.Revealer motion_revealer;
    private Gtk.Revealer motion_area_revealer;
    private Gtk.Grid drop_grid;
    private Gtk.Revealer action_revealer;
    public Gtk.Revealer main_revealer;
    private Gtk.Menu menu = null;
    private bool menu_visible = false;
    private Gtk.Label count_label;
    public bool is_open {get; set; default = true;}
    private uint timeout;
    private uint timeout_id = 0;
    private uint toggle_timeout = 0;
    //  public Gee.ArrayList<Widgets.ProjectRow?> projects_list;
    private bool entry_menu_opened = false;

    private const Gtk.TargetEntry[] TARGET_ENTRIES = {
        {"ITEMROW", Gtk.TargetFlags.SAME_APP, 0}
    };

    private const Gtk.TargetEntry[] TARGET_AREAS = {
        {"AREAROW", Gtk.TargetFlags.SAME_APP, 0}
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
        //  projects_list = new Gee.ArrayList<Widgets.ProjectRow?> ();

        area_image = new Gtk.Image ();
        area_image.halign = Gtk.Align.CENTER;
        area_image.valign = Gtk.Align.CENTER;
        //  area_image.gicon = new ThemedIcon ("folder-outline");
        if (item.icon != null) {
            try {
                area_image.gicon = Icon.new_for_string (item.icon);
            } catch (Error e) {
                debug (e.message);
            }
        }
        area_image.pixel_size = 20;
        area_image.margin_end = 4;
        //  if (area.collapsed == 1) {
        //      area_image.gicon = new ThemedIcon ("folder-open-outline");
        //  }

        var menu_image = new Gtk.Image ();
        menu_image.gicon = new ThemedIcon ("media-playback-start");
        menu_image.pixel_size = 14;
        menu_image.margin_end = 12;
        //  var menu_button = new Gtk.Button ();
        //  menu_button.can_focus = false;
        //  menu_button.valign = Gtk.Align.CENTER;
        //  menu_button.tooltip_text = _ ("Section Menu");
        //  menu_button.image = menu_image;
        //  menu_button.get_style_context ().remove_class ("button");
        //  menu_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        //  menu_button.get_style_context ().add_class ("hidden-button");

        //  count_label = new Gtk.Label (Planner.database.get_project_count_by_area (area.id).to_string ());
        //  count_label.valign = Gtk.Align.CENTER;
        //  count_label.opacity = 0;
        //  count_label.use_markup = true;
        //  count_label.width_chars = 3;

        //  var menu_stack = new Gtk.Stack ();
        //  menu_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        //  menu_stack.add_named (count_label, "count_label");
        //  menu_stack.add_named (menu_button, "menu_button");

        name_label = new Gtk.Label (item.name);
        name_label.halign = Gtk.Align.START;
        name_label.get_style_context ().add_class ("left-list-label");
        name_label.valign = Gtk.Align.CENTER;
        name_label.set_ellipsize (Pango.EllipsizeMode.END);

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.margin_start = 5;
        top_box.margin_top = 1;
        top_box.margin_bottom = 1;
        top_box.pack_start (area_image, false, false, 0);
        top_box.pack_start (name_label, false, true, 0);
        top_box.pack_end (menu_image, false, false, 0);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_start = 6;
        separator.margin_end = 6;

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
        Gtk.drag_source_set (this, Gdk.ModifierType.BUTTON1_MASK, TARGET_ENTRIES, Gdk.DragAction.MOVE);
        drag_begin.connect (on_drag_begin);
        drag_data_get.connect (on_drag_data_get);
        build_drag_and_drop ();
        //  handle.enter_notify_event.connect ((event) => {
        //      menu_stack.visible_child_name = "menu_button";
        //      source_revealer.reveal_child = true;

        //      return true;
        //  });

        //  handle.leave_notify_event.connect ((event) => {
        //      if (event.detail == Gdk.NotifyType.INFERIOR) {
        //          return false;
        //      }

        //      menu_stack.visible_child_name = "count_revealer";
        //      source_revealer.reveal_child = false;

        //      return true;
        //  });

        show_all ();
    }

    private void on_drag_begin (Gtk.Widget widget, Gdk.DragContext context) {
        debug ("BEGIN");
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
        debug ("HERE");
        uchar[] data = new uchar[(sizeof (Workspaces.Widgets.ItemRow))];
        ((Gtk.Widget[])data)[0] = widget;

        selection_data.set (
            Gdk.Atom.intern_static_string ("ITEMROW"), 32, data
            );
    }

    private void build_drag_and_drop () {
        Gtk.drag_dest_set (this, Gtk.DestDefaults.MOTION, TARGET_ENTRIES, Gdk.DragAction.MOVE);
        drag_motion.connect (on_drag_motion);
        drag_leave.connect (on_drag_leave);
        drag_end.connect (clear_indicator);
    }

    //  private void on_drag_item_received (Gdk.DragContext context, int x, int y,
    //      Gtk.SelectionData selection_data, uint target_type) {
    //      Widgets.ItemRow source;
    //      var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
    //      source = (Widgets.ItemRow) row;

    //      if (source.item.is_todoist == project.is_todoist) {
    //          Planner.database.move_item (source.item, project.id);
    //          if (source.item.is_todoist == 1) {
    //              Planner.todoist.move_item (source.item, project.id);
    //          }

    //          string move_template = _("Task moved to <b>%s</b>");
    //          Planner.notifications.send_notification (
    //              move_template.printf (
    //                  Planner.database.get_project_by_id (project.id).name
    //              )
    //          );
    //      } else {
    //          Planner.notifications.send_notification (
    //              _("Unable to move task")
    //          );
    //      }
    //  }

    //  private void on_drag_begin (Gtk.Widget widget, Gdk.DragContext context) {
    //      var row = ((ProjectRow) widget).handle;

    //      Gtk.Allocation alloc;
    //      row.get_allocation (out alloc);

    //      var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, alloc.width, alloc.height);
    //      var cr = new Cairo.Context (surface);
    //      cr.set_source_rgba (0, 0, 0, 0);
    //      cr.set_line_width (1);

    //      cr.move_to (0, 0);
    //      cr.line_to (alloc.width, 0);
    //      cr.line_to (alloc.width, alloc.height);
    //      cr.line_to (0, alloc.height);
    //      cr.line_to (0, 0);
    //      cr.stroke ();

    //      cr.set_source_rgba (255, 255, 255, 0);
    //      cr.rectangle (0, 0, alloc.width, alloc.height);
    //      cr.fill ();

    //      row.get_style_context ().add_class ("drag-begin");
    //      row.draw (cr);
    //      row.get_style_context ().remove_class ("drag-begin");

    //      Gtk.drag_set_icon_surface (context, surface);
    //      main_revealer.reveal_child = false;
    //  }

    //  private void on_drag_data_get (Gtk.Widget widget, Gdk.DragContext context,
    //      Gtk.SelectionData selection_data, uint target_type, uint time) {
    //      uchar[] data = new uchar[(sizeof (ProjectRow))];
    //      ((Gtk.Widget[])data)[0] = widget;

    //      selection_data.set (
    //          Gdk.Atom.intern_static_string ("PROJECTROW"), 32, data
    //      );
    //  }

    public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
        reveal_drag_motion = true;

        int index = get_index ();
        Gtk.Allocation alloc;
        get_allocation (out alloc);

        int real_y = (index * alloc.height) - alloc.height + y;
        //  check_scroll (real_y);

        //  if (should_scroll && !scrolling) {
        //      scrolling = true;
        //      Timeout.add (SCROLL_DELAY, scroll);
        //  }

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

    //  private void add_item (Workspaces.Models.Item item, bool to_open) {
    //      var it = new Workspaces.Widgets.WorkspaceItem (item);
    //      it.set_data<string>("stack_child", item.name);
    //      it.action_activated.connect ((i) => {
    //          i.selectable = false;
    //          it.item.execute_command ();
    //          GLib.Timeout.add (100, () => {
    //              i.selectable = true;
    //              return false;
    //          }, GLib.Priority.DEFAULT);
    //      });
    //      it.activated.connect ((i) => {
    //          warning (i.name);
    //      });
    //      add (it);

    //      if (to_open == true) {
    //          added_new_item (it);
    //      }
    //  }
    //  public WorkspaceItem (Workspaces.Models.Item item) {
    //      Object (name: item.name);

    //      this.item = item;
    //      //  var icon_image = new GLib.Icon ();
    //      if (item.icon != null) {
    //          try {
    //              icon = Icon.new_for_string (item.icon);
    //          } catch (Error e) {
    //              debug (e.message);
    //          }
    //      }

    //      var default_icon = new ThemedIcon ("media-playback-start");
    //      //  icon_image.gicon = default_icon;

    //      this.activatable = default_icon;
    //  }

    //  public void remove_itself () {
    //      var has_deleted = Application.instance.workspaces_controller.remove_item (item);
    //      if (has_deleted) {
    //          var workspace_parent = this.parent as Workspaces.Widgets.ExpandableCategory;
    //          if (workspace_parent != null) {
    //              workspace_parent.remove_item (this);
    //          }
    //      }
    //  }
    //  public override Gtk.Menu ? get_context_menu () {
    //      Gtk.Menu menu = new Gtk.Menu ();
    //      Gtk.MenuItem menu_item = new Gtk.MenuItem.with_label (_ ("Delete"));
    //      menu_item.activate.connect (() => {
    //          remove_itself ();
    //      });
    //      menu.add (menu_item);
    //      menu.show_all ();

    //      return menu;
    //  }
}