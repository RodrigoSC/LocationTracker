import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Position;
import Toybox.Background;
import Toybox.Application.Storage;

(:background)
class LocationTrackerApp extends Application.AppBase {
    private const TIMER_DURATION = 5*60; // In seconds. Must be more that 5 minutes
    private const LAST_SAVE = 1;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new LocationTrackerView()] as Array<Views or InputDelegates>;
    }

    public function getServiceDelegate() as Array<ServiceDelegate> {
        return [new LocationTrackerServiceDelegate()] as Array<ServiceDelegate>;
    }
    
    public function saveLocation() as Void {
        System.println("saveLocation");
        var time = Time.now().value();
        var myLocation = Position.getInfo().position.toDegrees();
        var place = Lang.format("$1$;$2$", [myLocation[0], myLocation[1]]);
        System.println("Time: " + time);
        System.println("Place: " + place); 
        Storage.setValue(time,  place);
        Storage.setValue(LAST_SAVE, time);
    }

    public function setBackgroundEvent() as Void {
        System.println("setBackgroundEvent");
        var last = Storage.getValue(LAST_SAVE);
        var now = Time.now().value();
        if (last == null || (now - last) > TIMER_DURATION) {
            saveLocation();
        }
        try {
            System.println("Setting background event");
            Background.registerForTemporalEvent(new Time.Duration(TIMER_DURATION));
        } catch (e instanceof Background.InvalidBackgroundTimeException) {
            System.println("Exception!!"); // This will happen if timer < 5 mins
        }
    }

    public function deleteBackgroundEvent() as Void {
        System.println("deleteBackgroundEvent");
        Background.deleteTemporalEvent();
    }
}

function getApp() as LocationTrackerApp {
    return Application.getApp() as LocationTrackerApp;
}