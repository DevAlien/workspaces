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

public class Workspaces.Widgets.AppRow : Gtk.ListBoxRow {
    public Workspaces.Models.AppInfo app_info {get; set;}

    public AppRow (Workspaces.Models.AppInfo app_info) {
        Object (app_info: app_info);
        var image = new Gtk.Image.from_icon_name (app_info.icon_name, Gtk.IconSize.LARGE_TOOLBAR);
        image.pixel_size = 24;

        var label = new Gtk.Label (app_info.name);

        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.column_spacing = 12;
        grid.attach (image, 0, 0, 1, 1);
        grid.attach (label, 1, 0, 1, 1);

        add (grid);
    }

    construct {
    }
}

public class Workspaces.Widgets.AppListBox : Gtk.ListBox {
    private const int LOAD_BATCH = 20;

    private static Gee.ArrayList<Workspaces.Models.AppInfo> apps;
    private static int max_index = -1;

    private Gee.ArrayList<Workspaces.Models.AppInfo> added;
    private int current_index = 0;
    private string search_query = "";
    private Cancellable ? search_cancellable = null;

    static construct {
        apps = new Gee.ArrayList<Workspaces.Models.AppInfo> ();

        var list = AppInfo.get_all ();
        list.@foreach ((app) => {
            if (app is DesktopAppInfo) {
                var icon = app.get_icon ();
                var icon_name = "applications-other";
                if (icon != null) {
                    icon_name = icon.to_string ();
                }
                if (app.get_executable () == null) {
                    return;
                }
                apps.add (new Workspaces.Models.AppInfo (app.get_name (), icon_name, app.get_executable ()));
            }
        });

        max_index = apps.size - 1;
        apps.sort ((a, b) => strcmp (a.name, b.name));
    }

    construct {
        added = new Gee.ArrayList<Workspaces.Models.AppInfo> ();

        set_sort_func (sort_func);
        set_filter_func (filter_func);
        load_next_apps ();
    }

    public AppListBox () {
        selection_mode = Gtk.SelectionMode.BROWSE;
        activate_on_single_click = false;
    }

    public Workspaces.Widgets.AppRow ? get_selected_app () {
        var row = get_selected_row ();
        if (row == null) {
            return null;
        }

        var app_row = row as Workspaces.Widgets.AppRow;
        if (app_row == null) {
            return null;
        }

        return app_row;
    }

    public void add_app (Workspaces.Models.AppInfo app) {
        var row = new Workspaces.Widgets.AppRow (app);
        add (row);

        added.add (app);
    }

    public void load_next_apps () {
        int new_index = current_index + LOAD_BATCH;
        int bound = new_index.clamp (0, max_index);

        if (current_index >= bound) {
            return;
        }
        var slice = apps.slice (current_index, bound);
        foreach (var app in slice) {
            add_app (app);
        }

        current_index = new_index;
        show_all ();
    }

    public void search (string query) {
        if (search_cancellable != null) {
            search_cancellable.cancel ();
        }

        search_cancellable = new Cancellable ();

        search_query = query;
        search_internal.begin (search_query);
    }

    private async void search_internal (string query) {
        new Thread<void*> ("search-internal", () => {
            Workspaces.Models.AppInfo[] matched = search_apps (query);
            if (search_cancellable.is_cancelled ()) {
                return null;
            }

            Idle.add (() => {
                foreach (Workspaces.Models.AppInfo app in matched) {
                    add_app (app);
                }

                show_all ();
                invalidate_filter ();
                return false;
            });

            return null;
        });
    }

    private Workspaces.Models.AppInfo[] search_apps (string query) {
        Workspaces.Models.AppInfo[] matched = { };
        for (int i = 0; i < apps.size; i++) {
            Workspaces.Models.AppInfo app = apps[i];
            if (!added.contains (app) && query_matches_name (query, app.name)) {
                matched += app;
            }
        }

        return matched;
    }

    private int sort_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var icon_row1 = row1 as Workspaces.Widgets.AppRow;
        if (icon_row1 == null) {
            return 0;
        }

        var icon_row2 = row2 as Workspaces.Widgets.AppRow;
        if (icon_row2 == null) {
            return 0;
        }

        return strcmp (icon_row1.app_info.name, icon_row2.app_info.name);
    }

    private bool filter_func (Gtk.ListBoxRow row) {
        if (search_query.strip () == "") {
            return true;
        }
        var icon_row = row as Workspaces.Widgets.AppRow;

        if (icon_row == null) {
            return true;
        }
        return query_matches_name (search_query, icon_row.app_info.name);
    }

    private static bool query_matches_name (string query, string name) {
        return query.down () in name.down ();
    }
}