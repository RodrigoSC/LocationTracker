import Toybox.Application;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Background;
import Toybox.Lang;

(:background)
class LocationTrackerApp extends Application.AppBase {
    private var inBackground = true;
    private var fromBackground = false;
    private var tracker as Tracker?;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if (!inBackground) {
            tracker.stopLocationEvents();
        }
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        logm("LocationTrackerApp","getInitialView");
        inBackground = false;
        tracker = new Tracker();
        tracker.setupLocationEvents();
        tracker.setAutoExit(fromBackground);
        return [ new StatusView(tracker), new StatusViewDelegate(tracker) ] as Array<Views or InputDelegates>;
    }

    public function getServiceDelegate() as Array<ServiceDelegate> {
        return [new LocationTrackerServiceDelegate()] as Array<ServiceDelegate>;
    }

    public function onBackgroundData(data as Application.PersistableType) {
        logm("LocationTrackerApp", "onBackgroundData");
        fromBackground = true;
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