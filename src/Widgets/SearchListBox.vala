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

public class Workspaces.Widgets.SearchListBox : Gtk.ListBox {
    private string search_text = "";
    public SearchListBox () {
        set_selection_mode (Gtk.SelectionMode.SINGLE);
        set_filter_func (do_filter_list);
    }

    public void set_search_text (string search_text) {
        this.search_text = search_text;
        invalidate_filter ();
    }

    protected bool do_filter_list (Gtk.ListBoxRow row) {
        SearchListBoxItem child = row as SearchListBoxItem;

        if (search_text.length > 0) {
            return child.item.contains_text (search_text.down ());
        }

        return true;
    }
}