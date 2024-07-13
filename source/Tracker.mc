import Toybox.Application;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Background;
using Toybox.Communications;

class Tracker {
    private var positionEvent as Method(info as Position.Info) as Void?;
    private var autoExit as Boolean = false;
    private var totalSaves as Number = 0;

    public function getLastSave() as Number {
        return Properties.getValue("LastSave");
    }
    
    public function savePosition(info as Position.Info) {
        logm("Tracker","savePoint");
        var time = Time.now().value();
        var saveInterval = totalSaves <= 3 ? 5 : 10;
        if (isTracking() && (time - getLastSave() > saveInterval) && (info.accuracy == Position.QUALITY_USABLE or info.accuracy == Position.QUALITY_GOOD)) {
            var myLocation = info.position.toDegrees();
            var lastStoragePos = Properties.getValue("LastStoragePos");
            log(Lang.format("Saving on index $1$", [lastStoragePos]));
            Storage.setValue(lastStoragePos,  [time, myLocation[0], myLocation[1]]);
            Properties.setValue("LastSave", time);
            Properties.setValue("LastStoragePos", lastStoragePos + 1);
            totalSaves = totalSaves + 1;
        }
        if (getSavesToQuit() == 0 && autoExit) {
            log("Done all the saves. Exiting");
            Attention.vibrate([new Attention.VibeProfile(25, 500)]);
            System.exit();
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
        if (positionEvent != null) {
            positionEvent.invoke(info);
        }
    }

    public function setOnPositionEvent(evt as Method(info as Position.Info) as Void?) {
        positionEvent = evt;
    }

    public function isTracking() as Boolean {
        return Properties.getValue("Tracking");
    }

    public function setTracking(val as Boolean) {
        Properties.setValue("Tracking", val);
        setupLocationEvents();
        setupReminder();
    }

    public function export(callback as Method(responseCode as Number, percent as Float) as Void?) {
        var request = new ExportRequest();
        request.sendData(me, callback);
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

    public function getLastPos() {
        return Properties.getValue("LastStoragePos");
    }
    
    public function getData(start as Number, end as Number) as Array {
        var array = [];
        var last = getLastPos();
        last = last > end ? end : last;
        for (var i = start; i < last; i++) {
            var item = Storage.getValue(i);
            array.add({"nbr" => i, "time" => item[0], "lat" => item[1], "lon" => item[2]});
        }
        return array;
    }

    public function setAutoExit(value as Boolean) {
        log(Lang.format("Setting auto exit to $1$", [value]));
        autoExit = value;
    }

    public function getAutoExit() as Boolean {
        return autoExit;
    }

    public function getSavesToQuit() as Number {
        return (3 - totalSaves);
    }
}