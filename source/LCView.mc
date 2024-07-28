import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Timer;

class LCView extends WatchUi.View {
    var refreshTimer as Timer.Timer = new Timer.Timer();
    var tracker as Tracker;
    var screenHeight as Number = 0;
    var screenWidth as Number = 0;

    function initialize(tracker as Tracker) {
        me.tracker = tracker;
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
    }

    function timerCallback() as Void {
        requestUpdate();
    }

    function onShow() as Void {
        logm("LCView", "onShow");
        tracker.setOnPositionEvent(method(:onPosition));
        refreshTimer.start(method(:timerCallback), 5000, true);
    }

    function onHide() as Void {
        logm("LCView", "onHide");
        tracker.setOnPositionEvent(null);
        refreshTimer.stop();
    }

    public function onPosition(info as Position.Info) as Void {
        logm("LCView","onPosition");
        requestUpdate();
    }
}
