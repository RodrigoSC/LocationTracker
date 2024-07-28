
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;

class MapViewDelegate extends WatchUi.BehaviorDelegate {
    private var tracker as Tracker?;
    private var view as MapView?;

    public function initialize(tracker as Tracker, view as MapView) {
        BehaviorDelegate.initialize();
        me.tracker = tracker;
        me.view = view;
    }

    public function onSelect() as Boolean {
        view.setMapMode(WatchUi.MAP_MODE_BROWSE);
        return true;
    }

    public function onPreviousPage() as Boolean {
        WatchUi.switchToView(new CruiseView(tracker), new CruiseViewDelegate(tracker), WatchUi.SLIDE_DOWN);
        return true;
    }

    public function onNextPage() as Boolean {
        WatchUi.switchToView(new StatusView(tracker), new StatusViewDelegate(tracker), WatchUi.SLIDE_UP);
        return true;
    }

    public function onBack() as Boolean {
        if (view.getMapMode() == WatchUi.MAP_MODE_PREVIEW) {
            System.exit();
        } else {
            view.setMapMode(WatchUi.MAP_MODE_PREVIEW);
        }
        return true;
    }
}

class MapView extends WatchUi.MapView {
    var tracker as Tracker?;
    const step = 100;
    var refreshTimer as Timer.Timer = new Timer.Timer();

    public function initialize(tracker as Tracker) {
        logm("MapView", "initialize");
        me.tracker = tracker;
        
        MapView.initialize();

        setMapMode(WatchUi.MAP_MODE_PREVIEW);
        updatePoly();
        setScreenVisibleArea(0, 0, System.getDeviceSettings().screenWidth, System.getDeviceSettings().screenHeight);
    }

    public function onLayout(dc as Dc) as Void {
    }

    function timerCallback() as Void {
        updatePoly();
    }

    public function onShow() as Void {
        logm("MapView", "onShow");
        refreshTimer.start(method(:timerCallback), 3000, true);
    }

    public function onHide() as Void {
        logm("MapView", "onHide");
        refreshTimer.stop();
    }

    function updatePoly() {
        logm("MapView", "updatePoly");
        var polyline = new WatchUi.MapPolyline();
        polyline.setColor(Graphics.COLOR_RED);
        polyline.setWidth(2);
        var lastPos = tracker.getLastPos();
        var firstPos = lastPos > step ? lastPos - step : 0;
        var box = {"top"=>-90, "left"=>180, "bottom"=>90, "right"=>-180};
        
        // 1st point 
        if (firstPos != 0) {
            var first = tracker.getData(0, 1);
            polyline.addLocation(new Position.Location({:latitude => first[0]["lat"], :longitude => first[0]["lon"], :format => :degrees}));
        }
        
        var points = tracker.getData(firstPos, lastPos);
        for (var i=0; i < points.size(); i++) {
            var lat =  points[i]["lat"];
            var lon =  points[i]["lon"];
            polyline.addLocation(new Position.Location({:latitude => lat, :longitude => lon, :format => :degrees}));
            if (lat > box["top"]) {box["top"] = lat;}
            if (lat < box["bottom"]) {box["bottom"] = lat;}
            if (lon < box["left"]) {box["left"] = lon;}
            if (lon > box["right"]) {box["right"] = lon;}
        }
        clear();
        setPolyline(polyline);

        var top_left = new Position.Location({:latitude => box["top"], :longitude =>box["left"], :format => :degrees});
        var bottom_right = new Position.Location({:latitude => box["bottom"], :longitude =>box["right"], :format => :degrees});
        
        if (getMapMode() == WatchUi.MAP_MODE_PREVIEW) {
            setMapVisibleArea(top_left, bottom_right);
        }
    }

    public function onUpdate(dc as Dc) as Void {
        logm("MapView", "onUpdate");
        MapView.onUpdate(dc);
    }
}