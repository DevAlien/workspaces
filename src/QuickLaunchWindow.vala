public class Workspaces.QuickLaunchWindow : Gtk.Dialog {
    public signal void search_changed (string search_term);
    public signal void paste_item (int id);
    public signal void delete_item (int id);

    private Workspaces.Widgets.SearchListBox list_box;
    private Gtk.Stack stack;
    private Workspaces.Views.AlertView empty_alert;
    private Gtk.SearchEntry search_headerbar;
    public Workspaces.Controllers.WorkspacesController workspaces_controller;

    public QuickLaunchWindow () {
        Object (application: Application.instance,
                height_request: 700,
                icon_name: "com.github.devalien.workspaces",
                resizable: true,
                title: _ ("Workspaces"),
                width_request: 500);

        workspaces_controller = Application.instance.workspaces_controller;
        set_keep_above (true);
        window_position = Gtk.WindowPosition.CENTER;

        search_headerbar = new Gtk.SearchEntry ();
        search_headerbar.placeholder_text = _ ("Search Workspaces\u2026");
        search_headerbar.hexpand = true;

        search_headerbar.key_press_event.connect ((event) => {
            switch (event.keyval) {
            case Gdk.Key.Escape :
                close ();
                return true;
            default :
                return false;
            }
        });

        search_headerbar.search_changed.connect (() => {
            list_box.set_search_text (search_headerbar.text);
        });


        var style_context = search_headerbar.get_style_context ();
        style_context.add_class ("large-search-entry");


        var list_box_scroll = new Gtk.ScrolledWindow (null, null);
        list_box_scroll.vexpand = true;
        list_box = new Workspaces.Widgets.SearchListBox ();
        search_headerbar.search_changed.connect (() => {
            list_box.set_search_text (search_headerbar.text);
        });
        list_box_scroll.add (list_box);
        list_box_scroll.show_all ();

        list_box.row_activated.connect ((row) => {
            var search_item = row as Workspaces.Widgets.SearchListBoxItem;
            search_item.item.launch ();
        });

        empty_alert = new Workspaces.Views.AlertView (_ ("No Workspaces or Items Found"), "", "edit-find-symbolic");
        empty_alert.show_all ();

        var welcome = new Workspaces.Widgets.QuickWelcome ();

        stack = new Gtk.Stack ();
        stack.add_named (list_box_scroll, "listbox");
        stack.add_named (empty_alert, "empty");
        stack.add_named (welcome, "welcome");

        foreach (var item in workspaces_controller.get_all ()) {
            var entry = new Workspaces.Models.SearchItem ();
            entry.workspace = item;
            add_entry (entry);
            foreach (var it in item.items) {
                var item_entry = new Workspaces.Models.SearchItem ();
                item_entry.item = it;
                add_entry (item_entry);
            }
        }

        var add_workspace_button = new Gtk.Button.from_icon_name ("emblem-system-symbolic", Gtk.IconSize.MENU);
        add_workspace_button.valign = Gtk.Align.CENTER;
        add_workspace_button.halign = Gtk.Align.START;
        add_workspace_button.always_show_image = true;
        add_workspace_button.can_focus = false;
        add_workspace_button.label = _ ("Preferences");
        add_workspace_button.get_style_context ().add_class ("flat");
        add_workspace_button.get_style_context ().add_class ("font-bold");
        add_workspace_button.get_style_context ().add_class ("add-button");
        add_workspace_button.clicked.connect (() => {
            Application.instance.load_preferences ();
        });
        var add_revealer = new Gtk.Revealer ();
        add_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        add_revealer.reveal_child = true;
        add_revealer.add (add_workspace_button);

        var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        action_box.get_style_context ().add_class ("bottom-buttons");
        action_box.margin_end = 9;
        action_box.margin_top = 6;
        action_box.margin_start = 9;
        action_box.hexpand = true;
        action_box.pack_start (add_revealer, false, false, 0);

        get_content_area ().add (stack);
        get_content_area ().add (action_box);

        set_titlebar (search_headerbar);

        show_all ();
        update_stack_visibility ();
        search_headerbar.grab_focus ();
    }

    public void add_entry (Workspaces.Models.SearchItem entry) {
        list_box.add (new Workspaces.Widgets.SearchListBoxItem (entry));
        update_stack_visibility ();
    }

    private void update_stack_visibility () {
        if (list_box.get_children ().length () > 0) {
            stack.visible_child_name = "listbox";
        } else if (search_headerbar.text.length == 0) {
            stack.visible_child_name = "welcome";
        } else {
            stack.visible_child_name = "empty";
            empty_alert.description = _ ("Try changing search terms.");
        }
    }
}