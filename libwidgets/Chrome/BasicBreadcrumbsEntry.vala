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
        private PathEntry path_entry;

        /* Deprecated */
        public string? action_icon_name {get; set;}

        construct {

            breadcrumbs = new Breadcrumbs ();
            path_entry = new PathEntry ();

            add (breadcrumbs);
            add (path_entry);
            set_visible_child (breadcrumbs);

            breadcrumbs.edit_request.connect (() => {
                set_visible_child (path_entry);
            });

            path_entry.activate.connect (() => {
                set_visible_child (breadcrumbs);
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
            path_entry.set_text (txt);
            set_visible_child (path_entry);
        }

        public string get_entry_text () {
            return path_entry.text;
        }

        public virtual void reset () {
            path_entry.reset ();
            set_visible_child (breadcrumbs);
        }

        public void set_animation_visible (bool visible) {
            breadcrumbs.animation_visible = visible;
        }

        public void set_placeholder (string txt) {
            path_entry.set_placeholder_text (txt);
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

            public signal void edit_request ();
            public signal void refresh_request ();

            private const string BREADCRUMB = """
                breadcrumb {
                    padding: 0;
                }
                breadcrumb button:not(:last-child) .no-end-button {
                    border-right-width: 0;
                    border-top-right-radius: 0;
                    border-bottom-right-radius: 0;
                }
                breadcrumb button:not(:first-child) > * {
                    padding: 6px;
                    padding-left: 22px;
                    padding-right: 0;
                }
                breadcrumb button:first-child > * {
                    padding:6px;
                    padding-right: 0;
                }
                breadcrumb button:not(:first-child) .no-end-button {
                    border-left-width: 0;
                    border-top-left-radius: 0;
                    border-bottom-left-radius: 0;
                }
                breadcrumb button .arrow-button {
                    border-radius: 0;
                    border-left-width: 0;
                    border-bottom-width: 0;
                }
                breadcrumb button {
                    outline-width: 0;
                    box-shadow: 0px 0px;
                }
            """;

            class construct {
                set_css_name ("breadcrumb");
                var arrow_provider = new Gtk.CssProvider ();
                try {
                    arrow_provider.load_from_data (BREADCRUMB);
                } catch (Error e) {
                    critical (e.message);
                }

                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), arrow_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            }

            construct {
                hexpand = true;
                var ele1 = new BreadcrumbElement ();
                var home_image = new Gtk.Image.from_icon_name ("user-home-symbolic", Gtk.IconSize.MENU);
                var home = new Gtk.Label ("home");
                var home_grid = new Gtk.Grid ();
                home_grid.add (home_image);
                home_grid.add (home);
                ele1.add (home_grid);

                var ele2 = new BreadcrumbElement ();
                var tintou = new Gtk.Label ("tintou");
                ele2.add (tintou);

                var ele3 = new BreadcrumbElement ();
                var est = new Gtk.Label ("est");
                ele3.add (est);

                add (ele1);
                add (ele2);
                add (ele3);

                var edit_click_area = new Gtk.Button ();
                edit_click_area.set_size_request (50, -1);
                edit_click_area.hexpand = true;
                edit_click_area.clicked.connect (() => {
                    edit_request ();
                });

                var refresh_button = new Gtk.Button.from_icon_name (Marlin.ICON_PATHBAR_SECONDARY_REFRESH_SYMBOLIC);
                refresh_button.clicked.connect (() => {
                    refresh_request ();
                });

                add (edit_click_area);
                add (refresh_button);

            }

            public override bool draw (Cairo.Context cr) {
                int width = get_allocated_width ();
                int height = get_allocated_height ();
                var style_context = get_style_context ();

                Gtk.StateFlags state = style_context.get_state ();
                style_context.render_background (cr, 0, 0, width, height);
                style_context.render_frame (cr, 0, 0, width, height);

                Gtk.Border padding = style_context.get_padding (state);
                Gtk.Border margin = style_context.get_margin (state);

                cr.translate (margin.left, margin.top);
                cr.translate (padding.left, padding.top);
                var children = get_children ();
                cr.translate (width, 0);
                children.foreach ((child) => {
                    cr.translate (-child.get_allocated_width (), 0);
                    cr.save ();
                    child.draw (cr);
                    cr.restore ();
                });
                return true;
            }

            private class BreadcrumbElement : Gtk.EventBox {

                class construct {
                    if (Gtk.Settings.get_default ().gtk_theme_name == "elementary"){
                        set_css_name ("breadcrumb-entry");
                    } else {
                        set_css_name ("button");
                    }
                }

                construct {
                    can_focus = true;
                    focus_out_event.connect (() => {
                        queue_redraw ();
                    });
                }

                public override bool draw (Cairo.Context cr) {
                    int width = get_allocated_width ();
                    int height = get_allocated_height ();

                    weak Gtk.StyleContext style_context = get_style_context ();
                    var state = style_context.get_state ();
                    Gtk.Border margin = style_context.get_margin (state);
                    cr.translate (margin.left, margin.top);
                    width -= margin.left + margin.right;
                    height -= margin.top + margin.bottom;

                    var parent_style_context = get_parent ().get_style_context ();
                    Gtk.Border parent_padding = parent_style_context.get_padding (parent_style_context.get_state ());
                    cr.translate (-parent_padding.left, -parent_padding.top);
                    width += parent_padding.left + parent_padding.right;
                    height += parent_padding.top + parent_padding.bottom;

                    var border = style_context.get_border (state);

                    var arrow_width = (height + border.left + border.right)/GLib.Math.SQRT2;
                    var arrow_height = (height + border.top + border.bottom)/GLib.Math.SQRT2;
                    var arrow_x = (height/2 + border.left + border.right)/GLib.Math.SQRT2;
                    var arrow_y = (height/2 + border.top + border.bottom)/GLib.Math.SQRT2;

                    style_context.save ();
                    style_context.add_class ("no-end-button");
                    style_context.render_background (cr, 0, 0, width, height);
                    style_context.render_frame (cr, 0, 0, width, height);
                    style_context.render_focus (cr, 0, 0, width, height);
                    style_context.restore ();

                    cr.save ();
                    cr.translate (width, height / 2 + border.top);
                    cr.rectangle (0, -height / 2, height - border.top - border.bottom, height - border.left - border.right);
                    cr.clip ();
                    cr.rotate (Math.PI_4);

                    style_context.save ();
                    style_context.add_class ("arrow-button");
                    style_context.render_background (cr, -arrow_x, -arrow_y, arrow_width, arrow_height);
                    style_context.render_frame (cr, -arrow_x, -arrow_y, arrow_width, arrow_height);
                    style_context.render_focus (cr, -arrow_x, -arrow_y, arrow_width, arrow_height);
                    style_context.restore ();

                    cr.restore ();

                    var children = get_children ();
                    children.reverse ();
                    children.foreach ((child) => {
                        cr.save ();
                        child.draw (cr);
                        cr.restore ();
                        cr.translate (child.get_allocated_width (), 0);
                    });

                    return true;
                }

                public int get_arrow_width () {
                    int height = get_allocated_height ();
                    var parent_style_context = get_parent ().get_style_context ();
                    Gtk.Border parent_padding = parent_style_context.get_padding (parent_style_context.get_state ());
                    height += parent_padding.top + parent_padding.bottom;

                    return height/2;
                }

                public override bool button_press_event (Gdk.EventButton event) {
                    set_state_flags (Gtk.StateFlags.ACTIVE, false);
                    queue_redraw ();
                    return base.button_press_event (event);
                }

                public override bool button_release_event (Gdk.EventButton event) {
                    unset_state_flags (Gtk.StateFlags.ACTIVE);
                    grab_focus ();
                    queue_redraw ();
                    return base.button_release_event (event);
                }

                public override bool key_press_event (Gdk.EventKey event) {
                    if (event.keyval == Gdk.Key.Return) {
                        set_state_flags (Gtk.StateFlags.ACTIVE, false);
                        queue_redraw ();
                    }

                    return base.key_press_event (event);
                }

                public override bool key_release_event (Gdk.EventKey event) {
                    if (event.keyval == Gdk.Key.Return) {
                        unset_state_flags (Gtk.StateFlags.ACTIVE);
                        queue_redraw ();
                    }

                    return base.key_release_event (event);
                }

                public override void get_preferred_width (out int minimum_width, out int natural_width) {
                    base.get_preferred_width (out minimum_width, out natural_width);
                    var arrow_width = get_arrow_width ();
                    minimum_width += arrow_width;
                    natural_width += arrow_width;
                }

                private void queue_redraw () {
                    get_parent ().queue_draw ();
                }

                /*
                 * This method gets called by Gtk+ when the actual size is known
                 * and the widget is told how much space could actually be allocated.
                 * It is called every time the widget size changes, for example when the
                 * user resizes the window.
                 */
                public override void size_allocate (Gtk.Allocation allocation) {
                    // The base method will save the allocation and move/resize the
                    // widget's GDK window if the widget is already realized.
                    base.size_allocate (allocation);

                    // Move/resize other realized windows if necessary
                }
            }
        }

        private class PathEntry : Gtk.Entry {
            public void reset () {

            }



        }
    }
}
