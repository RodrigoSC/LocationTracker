import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;

class CruiseView extends LCView {
    private var destUpdate = 0;
    private var destBear = 0.0;
    private var destDist = 0.0;

    public function initialize(tracker) { 
        LCView.initialize(tracker);
    }

    function onLayout(dc as Dc) as Void {
        logm("CruiseView", "onLayout");
        LCView.onLayout(dc);
        if(Properties.getValue("SetDest")) {
            setLayout($.Rez.Layouts.CruiseLayoutDest(dc));
        } else {
            setLayout($.Rez.Layouts.CruiseLayout(dc));
        }
    }

    function printSpeed(speed as Float) {
        if (speed < 100) {return speed.format("%.1f");}
        return speed.format("%d");
    }
    
    function onUpdate(dc as Dc) as Void {
        logm("CruiseView", "onUpdate");
        var time_text = View.findDrawableById("time") as Text;
        var sog_text = View.findDrawableById("sog") as Text;
        var cog_text = View.findDrawableById("cog") as Text;
        var time = System.getClockTime();
        var pos = Position.getInfo();
        var location = pos.position.toDegrees();
        
        time_text.setText(time.hour.format("%02d") + ":" + time.min.format("%02d"));
        sog_text.setText(printSpeed(tracker.sog));
        cog_text.setText(tracker.cog.format("%.3d"));
        
        if (Properties.getValue("SetDest")) {
            var dest = [Properties.getValue("DestLat"), Properties.getValue("DestLon")];
            var dist_text = View.findDrawableById("dist") as Text;
            var bear_text = View.findDrawableById("bear") as Text;
            if (destUpdate == 0) {
                destBear = getCoordinateBearing(location, dest);
                destDist = getCoordinateDistance(location, dest);
            }
            destUpdate = (destUpdate + 1) % 5;
            dist_text.setText(destDist.format("%d"));
            bear_text.setText(destBear.format("%.3d"));
        } else {
            var sogAvg_text = View.findDrawableById("sogAvg") as Text;
            sogAvg_text.setText(printSpeed(tracker.sogAvg));
        }
        View.onUpdate(dc);

        drawIndicator(dc, tracker.sog, tracker.sogAvg);
        if (Properties.getValue("SetDest")) {
            drawDestArrow(dc, destBear - tracker.cog, Graphics.COLOR_LT_GRAY);
            drawDestArrow(dc, -tracker.cog, Graphics.COLOR_DK_GRAY);
        }
    }

    function drawDestArrow(dc as Dc, angle as Float, color as Graphics.ColorValue) as Void {
        var arrowBuffer = Graphics.createBufferedBitmap({:width=> 20, :height=> 25}); 
        var tmpDc = arrowBuffer.get().getDc();
        var rad = angle * Math.PI / 180.0;

        tmpDc.setColor(color, Graphics.COLOR_TRANSPARENT);
        tmpDc.setAntiAlias(true);
        tmpDc.clear();

        tmpDc.fillPolygon([[0, 17], [10, 0], [20, 17], [20, 25], [0, 25]]);

        var transformMatrix = new Graphics.AffineTransform();
        var sin = Math.sin(rad);
        var cos = Math.cos(rad);
        transformMatrix.initialize();
        transformMatrix.translate(-10.0*cos + 227*sin, -227*cos - 10.0*sin);
        transformMatrix.rotate(rad);

        dc.drawBitmap2(screenWidth / 2, screenHeight / 2, arrowBuffer, {
            :transform => transformMatrix,
            :filterMode => Graphics.FILTER_MODE_BILINEAR
        });
    }

    function getCoordinateDistance(orig as Array<Double>, dest as Array<Double>) as Float {
        // Code extracted from here: https://www.movable-type.co.uk/scripts/latlong.html
        var R = 6371e3; // metres
        var φ1 = orig[0] * Math.PI/180; 
        var φ2 = dest[0] * Math.PI/180;
        var Δφ = (dest[0]-orig[0]) * Math.PI/180;
        var Δλ = (dest[1]-orig[1]) * Math.PI/180;

        var a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
          Math.cos(φ1) * Math.cos(φ2) *
          Math.sin(Δλ/2) * Math.sin(Δλ/2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        var d = R * c; // in metres

        return d / 1852;
    }

    function getCoordinateBearing(orig as Array<Double>, dest as Array<Double>) as Number {
        var φ1 = orig[0] * Math.PI/180; 
        var φ2 = dest[0] * Math.PI/180;
        var λ1 = orig[1] * Math.PI/180; 
        var λ2 = dest[1] * Math.PI/180;

        var y = Math.sin(λ2-λ1) * Math.cos(φ2);
        var x = Math.cos(φ1)*Math.sin(φ2) - Math.sin(φ1)*Math.cos(φ2)*Math.cos(λ2-λ1);
        var θ = Math.atan2(y, x);
        return (θ*180.0/Math.PI + 360.0).toNumber() % 360; 
    }

    function drawIndicator(dc as Dc, sog as Float, avg as Float) {
        var HALF_WIDTH = 10;
        var MAX_HEIGHT = 218 - 154;
        var x = screenWidth / 2;
        var value = sog - avg;
        var color = value > 0 ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
        var start = value > 0 ? 218 : 154;
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