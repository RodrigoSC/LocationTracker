import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;

// Main entry point for background processes.
(:background)
class LocationTrackerServiceDelegate extends System.ServiceDelegate {
    //! Constructor
    public function initialize() {
        ServiceDelegate.initialize();
    }

    public function onTemporalEvent() as Void {
        Background.requestApplicationWake("Time to checkin your position");
        Background.exit(true);
    }
}
