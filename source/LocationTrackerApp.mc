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
    public var tracker as Tracker?;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        tracker = new Tracker();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if (!_inBackground) {
            tracker.stopLocationEvents();
        }
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        logm("LocationTrackerApp","getInitialView");
        _inBackground = false;
        _view = new LocationTrackerView();
        tracker.setupLocationEvents();
        return [ _view ] as Array<Views or InputDelegates>;
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
}

function getApp() as LocationTrackerApp {
    return Application.getApp() as LocationTrackerApp;
}

(:debug)
const debug = true;
(:release)
const debug = false;

(:debug)
const trace_methods = false;
(:release)
const trace_methods = false;

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