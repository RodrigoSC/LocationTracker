import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
using Toybox.Timer;


class StatusViewDelegate extends BehaviorDelegate {
    var tracker as Tracker;

    public function initialize(tracker) { 
        me.tracker = tracker;
        WatchUi.BehaviorDelegate.initialize();
    }

    public function onSelect() as Boolean {
        var delegate = new MenuDelegate(tracker);
        tracker.setAutoExit(false);
        WatchUi.pushView(delegate.buildMenu(), delegate, WatchUi.SLIDE_RIGHT);
        return true;
    }
}

class StatusView extends WatchUi.View {
    var tracker as Tracker;
    var screenHeight as Number = 0;
    var screenWidth as Number = 0;
    var refreshTimer as Timer.Timer = new Timer.Timer();

    function initialize(tracker as Tracker) {
        me.tracker = tracker;
        View.initialize();
    }

    function timerCallback() as Void {
        requestUpdate();
    }

    function onShow() as Void {
        tracker.setOnPositionEvent(method(:onPosition));
        refreshTimer.start(method(:timerCallback), 5000, true);
    }

    function onHide() as Void {
        tracker.setOnPositionEvent(null);
        refreshTimer.stop();
    }

    public function onPosition(info as Position.Info) as Void {
        logm("StatusView","onPosition");
        requestUpdate();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout($.Rez.Layouts.StatusLayout(dc));
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
    }

    function qualityToColor (qual as Position.Quality) as Graphics.ColorValue {
        if (qual == Position.QUALITY_NOT_AVAILABLE) { return Graphics.COLOR_RED; }
        else if (qual == Position.QUALITY_LAST_KNOWN) { return Graphics.COLOR_LT_GRAY; }
        else if (qual == Position.QUALITY_POOR) { return Graphics.COLOR_YELLOW; }
        else if (qual == Position.QUALITY_USABLE) { return Graphics.COLOR_DK_GREEN; }
        else if (qual == Position.QUALITY_GOOD) { return Graphics.COLOR_GREEN; }
        return Graphics.COLOR_PURPLE;
    }

    function lastSaveText() as String {
        var diff = Time.now().value() - tracker.getLastSave();
        if (diff < 0) { return "In the future?"; }
        if (diff < 5) { return "Just now"; }
        if (diff < 60) { return "Seconds ago"; }
        if (diff < 120) { return "A minute ago"; }
        if (diff < 60 * 60) { return Lang.format("$1$ minutes ago", [diff / 60 as Number]); }
        if (diff < 60 * 60 * 2) { return "An hour ago"; }
        if (diff < 60 * 60 * 24) { return Lang.format("$1$ hours ago", [diff / (60*60) as Number]);}
        return Lang.format("$1$ days ago", [diff / (60*60*24) as Number]);
    }
    
    // Update the view
    function onUpdate(dc as Dc) as Void {
        var gps_text = View.findDrawableById("gps") as Text;
        var track_text = View.findDrawableById("tracking") as Text;
        var auto_exit_text = View.findDrawableById("auto_exit") as Text;
        var lastsave_text = View.findDrawableById("last_save") as Text;
        var lon_text = View.findDrawableById("lon") as Text;
        var lat_text = View.findDrawableById("lat") as Text;
        var pos = Position.getInfo();
        var location = pos.position.toDegrees();
        
        lon_text.setText(location[0].format("%f"));
        lat_text.setText(location[1].format("%f"));
        lastsave_text.setText(lastSaveText());
        if (tracker.getAutoExit()) {
            auto_exit_text.setText(Lang.format("$1$ saves to quit", [tracker.getSavesToQuit()]));
        } else {
            auto_exit_text.setText("");
        }

        View.onUpdate(dc);
        
        addColorSign(dc, gps_text, qualityToColor(pos.accuracy));
        addColorSign(dc, track_text, tracker.isTracking() ? Graphics.COLOR_GREEN : Graphics.COLOR_RED);
    }

    function addColorSign(dc as Dc, text as Text, color as Graphics.ColorValue) as Void {
        var circle_radius = 10;
        var circle_x = screenWidth/2 - (circle_radius*3 + text.width)/2;
        text.setLocation(circle_x + circle_radius*2, text.locY);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(circle_x, text.locY + text.height/2, circle_radius);        
    }
}
