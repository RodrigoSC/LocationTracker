import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;

class StatusView extends WatchUi.View {
    var tracker as Tracker;

    function initialize() {
        View.initialize();
        tracker = getApp().tracker;
        tracker.setOnPositionEvent(method(:onPosition));
    }

    public function onPosition(info) {
        logm("StatusView","onPosition");
        requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout($.Rez.Layouts.StatusLayout(dc));
    }

    function qualityToString (qual as Position.Quality) as String {
        if (qual == Position.QUALITY_NOT_AVAILABLE) { return "Not available"; }
        else if (qual == Position.QUALITY_LAST_KNOWN) { return "Last known"; }
        else if (qual == Position.QUALITY_POOR) { return "Poor..."; }
        else if (qual == Position.QUALITY_USABLE) { return "Usable"; }
        else if (qual == Position.QUALITY_GOOD) { return "Good!"; }
        else { return "Unknown value"; }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var qualityView = View.findDrawableById("quality") as Text;
        var timeView = View.findDrawableById("time") as Text;
        var lonView = View.findDrawableById("lon") as Text;
        var latView = View.findDrawableById("lat") as Text;
        var pos = Position.getInfo();
        var location = pos.position.toDegrees();
        
        qualityView.setText(qualityToString(pos.accuracy));
        timeView.setText(Time.now().value().format("%02d"));
        lonView.setText(location[0].format("%f"));
        latView.setText(location[1].format("%f"));
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        tracker.setOnPositionEvent(null);
    }
}
