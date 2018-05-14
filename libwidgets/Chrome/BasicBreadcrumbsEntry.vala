/*
* Copyright (c) 2018 elementary LLC (https://elementary.io)
*               2011 Lucas Baudin <xapantu@gmail.com>
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
*/

namespace Marlin.View.Chrome {
    public class BasicBreadcrumbsEntry : Gtk.Stack, Navigatable  {
        private Breadcrumbs breadcrumbs;
        private PathEntry pathentry;

        /* Deprecated */
        public string? action_icon_name {get; set;}

        construct {

            notify["action-icon-name"].connect (() => {
                warning ("action icon now %s", action_icon_name);
            });
        }


    /** Navigatable Interface **/
    /***************************/
        public void set_breadcrumbs_path (string path) {
            string protocol;
            string newpath;

            breadcrumbs.path = path;
        }

        public string get_breadcrumbs_path () {
            return breadcrumbs.path;
        }

        /* Deprecated */
        protected void set_action_icon_tooltip (string? tip) {
        }

        /* Deprecated */
        protected void hide_action_icon () {
        }

        public void set_entry_text (string? txt) {
            pathentry.set_text (txt);
        }

        public string get_entry_text () {
            return pathentry.text;
        }

        public virtual void reset () {
            pathentry.reset ();
        }

        public void set_animation_visible (bool visible) {
            breadcrumbs.animation_visible = visible;
        }

        public void set_placeholder (string txt) {
            pathentry.set_placeholder_text (txt);
        }

        /* Deprecated */
        public void show_default_action_icon () {

        }

        /* Deprecated */
        public void hide_default_action_icon () {

        }

        /* Deprecated */
        public void set_default_action_icon_tooltip () {
        }

        public int get_minimum_width () {
            return breadcrumbs.minimum_width;
        }

        private class Breadcrumbs : Gtk.Grid {
            public bool animation_visible {get; set; default = true;}
            public string path {get; set; default = "";}
            public int minimum_width {get; private set; default = 300;}
        }

        private class PathEntry : Gtk.Entry {
            public void reset () {

            }



        }
    }
}
