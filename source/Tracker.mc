import Toybox.Application;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Background;

class Tracker {
    private var _position_event as Method(info as Position.Info) as Void?;

    public function getLastSave() as Number {
        return Properties.getValue("LastSave");
    }
    
    public function savePosition(info as Position.Info) {
        logm("Tracker","savePoint");
        var time = Time.now().value();
        if (isTracking() && (time - getLastSave() > 10) && (info.accuracy == Position.QUALITY_USABLE or info.accuracy == Position.QUALITY_GOOD)) {
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

    public function setOnPositionEvent(evt as Method(info as Position.Info) as Void?) {
        _position_event = evt;
    }

    public function isTracking() as Boolean {
        return Properties.getValue("Tracking");
    }

    public function setTracking(val as Boolean) {
        Properties.setValue("Tracking", val);
        setupLocationEvents();
        setupReminder();
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

    public function getReminderInterval() as Number {
        return Properties.getValue("ReminderInterval");
    }

    public function setReminderInterval(interval as Number) {
        Properties.setValue("ReminderInterval", interval);
        setupReminder();
    }

    public function setupReminder() {
        var interval = getReminderInterval();
        if (isTracking() && interval > 0) {
            try {
                log(Lang.format("Setting reminder to $1$ minutes", [interval]));
                Background.registerForTemporalEvent(new Time.Duration(interval * 60));
            } catch (e instanceof Background.InvalidBackgroundTimeException) {
                log("Exception setting interval!!"); // This will happen if timer < 5 mins
            }
        } else {
            Background.deleteTemporalEvent();
        }
    }
}