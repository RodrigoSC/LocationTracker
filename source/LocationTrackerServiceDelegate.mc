import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;

// Main entry point for background processes.
(:background)
class LocationTrackerServiceDelegate extends System.ServiceDelegate {
    var _view as LocationTrackerView?;

    //! Constructor
    public function initialize() {
        ServiceDelegate.initialize();
    }

    public function onTemporalEvent() as Void {
        System.println("Temporal event launched");
        System.println("saveLocation");
        var myLocation = Position.getInfo().position.toDegrees();
        var time = Time.now().value();
        var place = Lang.format("$1$;$2$", [myLocation[0], myLocation[1]]);
        System.println("Time: " + time);
        System.println("Place: " + place); 
        Storage.setValue(time,  place);
        Storage.setValue(1, time);
        Background.exit(true);
    }
}
