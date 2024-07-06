import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Background;
import Toybox.Position;

(:background)
class LocationTrackerApp extends Application.AppBase {
    private var _inBackground = true;
    private var _view as LocationTrackerView?; 
    private var _position_event as Lang.Method?;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if (!_inBackground) {
            log("Disabling location event");
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        }
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        logm("LocationTrackerApp","getInitialView");
        _inBackground = false;
        _view = new LocationTrackerView();
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        
        return [ _view ] as Array<Views or InputDelegates>;
    }

    public function onPosition(info as Position.Info) as Void {
        logm("LocationTrackerApp","onPosition");
        savePosition(info);
        if (_position_event != null) {
            _position_event.invoke(info);
        }
    }

    public function savePosition(info as Position.Info) {
        logm("LocationTrackerApp","savePoint");
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

    public function export() {
        var lastStoragePos = Properties.getValue("LastStoragePos");
        System.println("--- Start Export ---");
        for (var i = 10; i < lastStoragePos; i++) {
            var values = Storage.getValue(i);
            System.println(Lang.format("$1$,$2$,$3$", values));
        }
        System.println("--- End Export ---");
    }

    public function getServiceDelegate() as Array<ServiceDelegate> {
        return [new LocationTrackerServiceDelegate()] as Array<ServiceDelegate>;
    }
    
    public function setBackgroundEvent() as Void {
        logm("LocationTrackerApp","setBackgroundEvent");
        try {
            var reminderInterval = Properties.getValue("ReminderInterval");
            if (reminderInterval != 0) {
                log("Setting background event");
                Background.registerForTemporalEvent(new Time.Duration(reminderInterval * 60));
            }
        } catch (e instanceof Background.InvalidBackgroundTimeException) {
            log("Exception!!"); // This will happen if timer < 5 mins
        }
    }

    public function deleteBackgroundEvent() as Void {
        logm("LocationTrackerApp","deleteBackgroundEvent");
        Background.deleteTemporalEvent();
    }

    public function isTracking() as Boolean {
        return Properties.getValue("Tracking");
    }

    public function setTracking(val as Boolean) {
        Properties.setValue("Tracking", val);
    }

    public function isReminding() as Boolean {
        return Background.getTemporalEventRegisteredTime() != null;
    }

    public function setOnPositionEvent(evt) {
        _position_event = evt;
    }
}

function getApp() as LocationTrackerApp {
    return Application.getApp() as LocationTrackerApp;
}

var debug = true;
var trace_methods = false;

function log(message) {
    if (debug) {
        try {
            var clockTime = System.getClockTime();       
            message = Lang.format("$1$:$2$:$3$: $4$", [clockTime.hour, clockTime.min.format("%02d"), clockTime.sec.format("%02d"), message]);
            System.println(message);
        } catch (ex) {
            message = Lang.format("--:--:--: $1$", [message]);
            System.println(message);
        }
    }
}

function logm(class_name, method_name) {
    if (trace_methods) {
        log(Lang.format("> $1$.$2$", [class_name, method_name]));
    }
}