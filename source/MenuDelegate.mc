import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id.equals("status")) {
            log("Show status");
            WatchUi.pushView(new StatusView(), null, WatchUi.SLIDE_UP); 
        } else if (id.equals("toggle_tracking")) {
            getApp().setTracking((item as ToggleMenuItem).isEnabled());
        } else if (id.equals("toggle_reminder")) {
            if((item as ToggleMenuItem).isEnabled()) {
                log("Enabling reminder");
                getApp().setBackgroundEvent();
            } else {
                log("Disabling reminder");
                getApp().deleteBackgroundEvent();
            }
        } else if (id.equals("export")) {
            log("Exporting data");
            getApp().export();
        } else {
            log("Not implemented menu");
        }
    }
}