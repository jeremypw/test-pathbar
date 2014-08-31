/*
 Copyright (C) 2014 ELementary Developers

 This program is free software: you can redistribute it and/or modify it
 under the terms of the GNU Lesser General Public License version 3, as published
 by the Free Software Foundation.

 This program is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranties of
 MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along
 with this program. If not, see <http://www.gnu.org/licenses/>.

 Authors : Jeremy Wootten <jeremy@elementary.org>
*/

namespace FM {
    public class IconView : DirectoryView {
        /* Golden ratio used */
        const double ITEM_WIDTH_TO_ICON_SIZE_RATIO = 1.62;
        protected new Gtk.IconView tree;

        public IconView (Marlin.View.Slot _slot) {
//message ("New IconView");
            base (_slot);
            slot.directory.load ();
        }

        protected override Gtk.Widget? create_view () {
//message ("IV create view");
            tree = new Gtk.IconView ();
            set_up_view ();
            set_up_name_renderer ();
            set_up_icon_renderer ();

            tree.add_events (Gdk.EventMask.POINTER_MOTION_MASK);
            tree.motion_notify_event.connect (on_motion_notify_event);

            return tree as Gtk.Widget;
        }

        private void set_up_view () {
//message ("IV tree view set up view");
            tree.set_model (model);
            tree.set_selection_mode (Gtk.SelectionMode.MULTIPLE);
            tree.set_columns (-1);
            (tree as Gtk.CellLayout).pack_start (icon_renderer, false);
            (tree as Gtk.CellLayout).pack_end (name_renderer, false);
            (tree as Gtk.CellLayout).add_attribute (name_renderer, "text", FM.ListModel.ColumnID.FILENAME);
            (tree as Gtk.CellLayout).add_attribute (name_renderer, "background", FM.ListModel.ColumnID.COLOR);
            (tree as Gtk.CellLayout).add_attribute (icon_renderer, "file", FM.ListModel.ColumnID.FILE_COLUMN);
            connect_tree_signals ();
            Preferences.settings.bind ("single-click", tree, "activate-on-single-click", GLib.SettingsBindFlags.GET);
            //tree.activate_on_single_click = false;
        }

        protected void set_up_name_renderer () {
//message ("IV set up name renderer");
            name_renderer.wrap_width = 12;
            name_renderer.wrap_mode = Pango.WrapMode.WORD_CHAR;
            name_renderer.xalign = 0.5f;
            name_renderer.editable_set = true;
            name_renderer.editable = true;
            name_renderer.edited.connect (on_name_edited);
            name_renderer.editing_canceled.connect (on_name_editing_canceled);
            name_renderer.editing_started.connect (on_name_editing_started);
        }
        protected void set_up_icon_renderer () {
//message ("IV set up icon renderer");
            icon_renderer.set_property ("follow-state",  true);
            icon_renderer.set_property ("selection-helpers",  true); /* do we always want helpers for accessibility? */
            //Preferences.settings.bind ("single-click", icon_renderer, "selection-helpers", GLib.SettingsBindFlags.DEFAULT);
        }


        private void connect_tree_signals () {
//message ("IV connect tree_signals");
            tree.selection_changed.connect (on_view_selection_changed);
            tree.button_press_event.connect (on_view_button_press_event); /* Abstract */
            tree.button_release_event.connect (on_view_button_release_event); /* Abstract */
            tree.draw.connect (on_view_draw);
            tree.key_press_event.connect (on_view_key_press_event);
            tree.item_activated.connect (on_view_items_activated);
        }

        
/** Override parents virtual methods as required*/
        protected override Marlin.ZoomLevel get_set_up_zoom_level () {
//message ("CV setup zoom_level");
            var zoom = Preferences.marlin_icon_view_settings.get_enum ("zoom-level");
            Preferences.marlin_icon_view_settings.bind ("zoom-level", this, "zoom-level", GLib.SettingsBindFlags.SET);
            return (Marlin.ZoomLevel)zoom;
        }

        public override Marlin.ZoomLevel get_normal_zoom_level () {
            var zoom = Preferences.marlin_icon_view_settings.get_enum ("default-zoom-level");
            Preferences.marlin_icon_view_settings.set_enum ("zoom-level", zoom);
            return (Marlin.ZoomLevel)zoom;
        }

/** Override DirectoryView virtual methods as required, where common to IconView and MillerColumnView*/

        public override void zoom_level_changed () {
            if (tree != null) {
//message ("IV zoom level changed");
                int icon_size = (int) (Marlin.zoom_level_to_icon_size (zoom_level));
                tree.set_item_width ((int)((double) icon_size * ITEM_WIDTH_TO_ICON_SIZE_RATIO));
                base.zoom_level_changed ();
            }
        }

        public override GLib.List<Gtk.TreePath> get_selected_paths () {
            return tree.get_selected_items ();
        }

        public override void highlight_path (Gtk.TreePath? path) {
//message ("IconView highlight path");
            tree.set_drag_dest_item (path, Gtk.IconViewDropPosition.DROP_INTO);
        }

        public override Gtk.TreePath? get_path_at_pos (int x, int y) {
            unowned Gtk.TreePath? path = null;
            Gtk.IconViewDropPosition pos; 
            if (x >= 0 && y >= 0 && tree.get_dest_item_at_pos  (x, y, out path, out pos))
                return path;
            else
                return null;
        }

        public override void select_all () {
            tree.select_all ();
        }

        public override void unselect_all () {
//message ("IV unselect all");
            tree.unselect_all ();
        }

        public override void select_path (Gtk.TreePath? path) {
//message ("IV select path");
            if (path != null)
                tree.select_path (path);
        }
        public override void unselect_path (Gtk.TreePath? path) {
            if (path != null)
                tree.unselect_path (path);
        }
        public override bool path_is_selected (Gtk.TreePath? path) {
            if (path != null)
                return tree.path_is_selected (path);
            else
                return false;
        }

        public override void set_cursor (Gtk.TreePath? path, bool start_editing, bool select) {
//message ("IV set cursor");
            if (path == null)
                return;

            if (!select)
                GLib.SignalHandler.block_by_func (tree, (void*) on_view_selection_changed, null);

            tree.set_cursor (path, null, start_editing);

            if (!select)
                GLib.SignalHandler.unblock_by_func (tree, (void*) on_view_selection_changed, null);
        }

        public override bool get_visible_range (out Gtk.TreePath? start_path, out Gtk.TreePath? end_path) {
            start_path = null;
            end_path = null;
            return tree.get_visible_range (out start_path, out end_path);
        }

        public override void sync_selection () {
            /* FIXME Not implemented - needed? */
        }


/**  Helper functions */

        protected override void update_selected_files () {
//message ("IV update selected files");
            selected_files = null;
            tree.selected_foreach ((tree, path) => {
                unowned GOF.File file;
                file = model.file_for_path (path);
                /* FIXME - model does not return owned object?  Is this correct? */
                if (file != null) {
                    selected_files.prepend (file);
                } else {
                    critical ("Null file in model");
                }
            });
            selected_files.reverse ();
        }

        protected override bool view_has_focus () {
            return tree.has_focus;
        }

        protected override bool on_view_button_press_event (Gdk.EventButton event) {
//message ("IV button press");
            //grab_focus (); /* cancels any renaming */
            slot.active ();
            Gtk.TreePath? path = null;
            bool on_blank, on_icon, on_helper, on_name;
            get_click_position_info ((int)event.x, (int)event.y, out path,  out on_name, out on_blank, out on_icon, out on_helper);
            bool no_mods = (event.state & Gtk.accelerator_get_default_mod_mask ()) == 0;

            if (path == null || (!on_helper && !path_is_selected (path) && no_mods)) {
                unselect_all ();
                select_path (path);
            }

            bool result = false;
            switch (event.button) {
                case Gdk.BUTTON_PRIMARY:
                    if (path == null) {
                        block_drag_and_drop ();  /* allow rubber banding */
                    } else if (on_helper) {
                        if (path_is_selected (path))
                            unselect_path (path);
                        else
                            select_path (path);

                        return true;
                    } else {
//                        if (no_mods) {
//                            unselect_all ();
//                            tree.select_path (path);
//                        }
                        if (Preferences.settings.get_boolean ("single-click") && no_mods) {
                            result = handle_primary_button_single_click_mode (event, null, path, on_name, no_mods, on_blank, on_icon);
                        }
                    }
                    /* In double-click mode on path the default Gtk.TreeView handler is used */
                    break;

                case Gdk.BUTTON_MIDDLE: 
                    result = handle_middle_button_click (event, on_blank);
                    break;

                case Gdk.BUTTON_SECONDARY:
                    result = handle_secondary_button_click (event);
                    break;

                default:
                    result = handle_default_button_click ();
                    break;
            }
//message ("IV button press leaving");
            return result;
            //return true;
        }

        protected override bool handle_primary_button_single_click_mode (Gdk.EventButton event, Gtk.TreeSelection? selection, Gtk.TreePath? path, bool on_name, bool no_mods, bool on_blank, bool on_icon) {
//message ("IV handle left button");
            bool result = true;
            if (path != null) {
                if (!on_icon) {
                    rename_file (selected_files.data); /* Is this desirable? */
                } else {
                    result = false;
                }
            } 

            return result;
        }

        protected override bool handle_middle_button_click (Gdk.EventButton event, bool on_blank) {
                /* opens folder(s) in new tab */
                if (!on_blank) {
                    activate_selected_items (Marlin.OpenFlag.NEW_TAB);
                    return true;
                } else
                    return false;
        }

        protected override bool on_view_button_release_event (Gdk.EventButton event) {
//message ("IV button release event");
            if (dnd_disabled)
                unblock_drag_and_drop ();

            return false;
        }

        public override void start_renaming_file (GOF.File file, bool preselect_whole_name) {
//message ("ATV start renaming file");
            /* Select whole name if we are in renaming mode already */
            if (name_column != null && editable_widget != null) {
                editable_widget.select_region (0, -1);
                return;
            }

            Gtk.TreeIter? iter = null;
            if (!model.get_first_iter_for_file (file, out iter)) {
                critical ("Failed to find rename file in model");
                return;
            }

            /* Freeze updates to the view to prevent losing rename focus when the tree view updates */
            freeze_updates ();

            Gtk.TreePath path = model.get_path (iter);
            tree.scroll_to_path (path, true, (float) 0.0, (float) 0.0);
            /* set cursor_on_cell also triggers editing-started, where we save the editable widget */
            tree.set_cursor (path, name_renderer, true);

            int start_offset= 0, end_offset = -1;
            if (editable_widget != null) {
                Marlin.get_rename_region (original_name, out start_offset, out end_offset, preselect_whole_name);
                editable_widget.select_region (start_offset, end_offset);
            }
        }

//        private bool clicked_on_add_remove_helper (int x, int y) {
//message ("clicked on add remove helper");
//            Gtk.CellRenderer? renderer = null;
//            Gtk.TreePath? path = null;
//            tree.get_item_at_pos (x, y, out path, out renderer);
//            if (renderer != null && renderer is Marlin.IconRenderer) {
//                Gdk.Rectangle rect, area;
//                tree.get_cell_rect  (path, renderer, out rect);
//                area = renderer.get_aligned_area (tree, Gtk.CellRendererState.PRELIT, rect);
//message ("area x is %i, area y is %i, area width is %i, area height is %i;  x is %i, y is %i", area.x, area.y, area.width, area.height, x,y);
//                if (x <= area.x + 18 && y <= area.y + 18) {
//message ("returning true");
//                    return true;
//                }
//            }
//message ("returning false");
//            return false;
//        }

        protected void get_click_position_info (int x, int y,
                                                out Gtk.TreePath? path,
                                                out bool on_name,
                                                out bool on_blank,
                                                out bool on_icon,
                                                out bool on_helper) {
            unowned Gtk.TreePath? p = null;
            unowned Gtk.CellRenderer r;

            on_blank = !tree.get_item_at_pos (x, y, out p, out r);
            path = p;

            on_icon = false;
            on_helper = false;
            on_name = false;
            if (r != null) {
                if (r is Gtk.CellRendererText)
                    on_name = true;
                else {
                    Gdk.Rectangle rect, area;
                    tree.get_cell_rect  (p, r, out rect);
                    area = r.get_aligned_area (tree, Gtk.CellRendererState.PRELIT, rect);
                    if (x <= area.x + 18 && y <= area.y + 18) {
                        on_helper = true;
                    }
                }
            }
            on_icon = !on_name && !on_helper;

//message ("\non_blank is %s", on_blank ? "true" : "false");
//message ("on_icon is %s", on_icon ? "true" : "false");
//message ("on_name is %s", on_name ? "true" : "false");
//message ("on_helper is %s", on_helper ? "true" : "false");
//message ("path is %s\n", path != null ? "not null" : "null");
        }

    }
}
