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

public class Workspaces.Widgets.Dot : Gtk.DrawingArea {
    public bool is_hidden = false;
    public Dot () {
        // Set favored widget size
        set_size_request (10, 10);
        set_vexpand (true);
        set_valign (Gtk.Align.CENTER);
    }

    public void set_is_hidden (bool hidden) {
        is_hidden = hidden;
        queue_draw ();
    }
    /* Widget is asked to draw itself */
    public override bool draw (Cairo.Context cr) {
        if (!is_hidden) {
            cr.set_source_rgb (0.258, 0.56, 0.96);
            cr.translate (5, 5);
            cr.arc (0, 0, 5, 0, 2.0 * 3.14);
            cr.fill ();
            cr.stroke ();
        }

        return false;
    }
}