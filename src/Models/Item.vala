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

public class Workspaces.Models.Item : Object {
    public string id { get; set; }
    public string name { get; set; }
    public string icon {get; set;}
    public string item_type {get; set;}
    public string command {get; set;}

    public Item (string id, string name) {
        Object ();

        this.id = id;
        this.name = name;
    }

    public string to_string () {
        return @"[$(this.id)] $(this.name)";
    }
}
