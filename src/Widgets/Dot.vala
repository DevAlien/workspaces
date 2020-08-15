using Gtk;

public class Workspaces.Widgets.Dot : DrawingArea {
    public Dot () {
        // Set favored widget size
        set_size_request (10, 10);
        set_vexpand (true);
        set_hexpand (true);
        set_valign (Align.CENTER);
    }

    /* Widget is asked to draw itself */
    public override bool draw (Cairo.Context cr) {
        cr.set_source_rgb (0.258, 0.56, 0.96);
        cr.translate (5, 5);
        cr.arc (0, 0, 5, 0, 2.0 * 3.14);
        cr.fill ();
        cr.stroke ();
        return false;
    }
}