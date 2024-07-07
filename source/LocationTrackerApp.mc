import Toybox.Application;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Background;
import Toybox.Lang;

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
        tracker = new Tracker();
        tracker.setupLocationEvents();
        return [ _view ] as Array<Views or InputDelegates>;
    }

    public function getServiceDelegate() as Array<ServiceDelegate> {
        return [new LocationTrackerServiceDelegate()] as Array<ServiceDelegate>;
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