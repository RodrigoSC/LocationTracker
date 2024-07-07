import Toybox.Application;
import Toybox.Position;
import Toybox.Lang;

class Tracker {
    private var _position_event as Lang.Method?;

    public function savePosition(info as Position.Info) {
        logm("Tracker","savePoint");
        var time = Time.now().value();
        var lastSave = Properties.getValue("LastSave");
        if (isTracking() && (time - lastSave > 10) && (info.accuracy == Position.QUALITY_USABLE or info.accuracy == Position.QUALITY_GOOD)) {
            var myLocation = info.position.toDegrees();
            var lastStoragePos = Properties.getValue("LastStoragePos");
            log(Lang.format("Saving on index $1$", [lastStoragePos]));
            Storage.setValue(lastStoragePos,  [time, myLocation[0], myLocation[1]]);
            Properties.setValue("LastSave", time);
            Properties.setValue("LastStoragePos", lastStoragePos + 1);
        }        
    }

    public function setupLocationEvents() {
        if(isTracking()) {
            log("Turning on location events");
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        } else {
            stopLocationEvents();
        }
    }
    
    function stopLocationEvents() {
        log("Turning off location events");
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    public function onPosition(info as Position.Info) as Void {
        logm("Tracker","onPosition");
        savePosition(info);
        if (_position_event != null) {
            _position_event.invoke(info);
        }
    }

    public function setOnPositionEvent(evt) {
        _position_event = evt;
    }

    public function isTracking() as Boolean {
        return Properties.getValue("Tracking");
    }

    public function setTracking(val as Boolean) {
        Properties.setValue("Tracking", val);
        setupLocationEvents();
    }

    public function isReminding() as Boolean {
        return Background.getTemporalEventRegisteredTime() != null;
    }

    public function export() {
        var lastStoragePos = Properties.getValue("LastStoragePos");
        System.println("--- Start Export ---");
        for (var i = 0; i < lastStoragePos; i++) {
            var values = Storage.getValue(i);
            System.println(Lang.format("$1$,$2$,$3$", values));
        }
        System.println("--- End Export ---");
    }

    public function reset() {
        log("Reseting data");
        Storage.clearValues();
        Properties.setValue("LastStoragePos", 0);       
    }
}