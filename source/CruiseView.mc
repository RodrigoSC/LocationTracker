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

    function onUpdate(dc as Dc) as Void {
        logm("CruiseView", "onUpdate");
        View.onUpdate(dc);
        var time_text = View.findDrawableById("time") as Text;
        var sog_text = View.findDrawableById("sog") as Text;
        var cog_text = View.findDrawableById("cog") as Text;
        var time = System.getClockTime();
        
        time_text.setText(time.hour.format("%02d") + ":" + time.min.format("%02d"));
        if (tracker.sog < 100) {
            sog_text.setText(tracker.sog.format("%.1f"));
        } else {
            sog_text.setText(tracker.sog.format("%d"));
        }
        cog_text.setText(tracker.cog + "º");
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