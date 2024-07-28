import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;

class CruiseView extends LCView {
    public function initialize(tracker) { 
        LCView.initialize(tracker);
    }

    function onLayout(dc as Dc) as Void {
        logm("CruiseView", "onLayout");
        LCView.onLayout(dc);
        setLayout($.Rez.Layouts.CruiseLayout(dc));
    }

    function printSpeed(speed as Float) {
        if (speed < 100) {return speed.format("%.1f");}
        return speed.format("%d");
    }
    
    function onUpdate(dc as Dc) as Void {
        logm("CruiseView", "onUpdate");
        var time_text = View.findDrawableById("time") as Text;
        var sog_text = View.findDrawableById("sog") as Text;
        var sogAvg_text = View.findDrawableById("sogAvg") as Text;
        var cog_text = View.findDrawableById("cog") as Text;
        var time = System.getClockTime();
        
        time_text.setText(time.hour.format("%02d") + ":" + time.min.format("%02d"));
        sog_text.setText(printSpeed(tracker.sog));
        cog_text.setText(tracker.cog.format("%.3d"));
        sogAvg_text.setText(printSpeed(tracker.sogAvg));

        View.onUpdate(dc);

        drawIndicator(dc, tracker.sog, tracker.sogAvg);
    }

    function drawIndicator(dc as Dc, sog as Float, avg as Float) {
        log(Lang.format("Drawing indicator for $1$, avg $2$", [sog, avg]));
        var HALF_WIDTH = 10;
        var MAX_HEIGHT = 228 - 164;
        var x = screenWidth / 2;
        var value = sog - avg;
        var color = value > 0 ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
        var start = value > 0 ? 228 : 164;
        var height = avg == 0 ? 0 : (value / avg) * (MAX_HEIGHT * 10);
        height = height > MAX_HEIGHT ? MAX_HEIGHT : height;
        height = height < -MAX_HEIGHT ? -MAX_HEIGHT : height;
        
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[x - HALF_WIDTH, start], [x + HALF_WIDTH, start], [x + HALF_WIDTH, start - height], [x - HALF_WIDTH, start - height]]);
    }
}

class CruiseViewDelegate extends BehaviorDelegate {
    var tracker as Tracker;

    public function initialize(tracker) { 
        me.tracker = tracker;
        WatchUi.BehaviorDelegate.initialize();
    }

    public function onSelect() as Boolean {
        var delegate = new MenuDelegate(tracker);
        WatchUi.pushView(delegate.buildMenu(), delegate, WatchUi.SLIDE_RIGHT);
        return true;
    }

    public function onNextPage() as Boolean {
        var view = new MapView(tracker);
        WatchUi.switchToView(view, new MapViewDelegate(tracker, view), WatchUi.SLIDE_UP);
        return true;
    }

    public function onPreviousPage() as Boolean {
        WatchUi.switchToView(new StatusView(tracker), new StatusViewDelegate(tracker), WatchUi.SLIDE_DOWN);
        return true;
    }
}