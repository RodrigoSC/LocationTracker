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
            System.println("Show status");
            WatchUi.pushView(new StatusView(), null, WatchUi.SLIDE_UP); 
        } else if (id.equals("toggle_tracking")) {
            if((item as ToggleMenuItem).isEnabled()) {
                System.println("Enabling tracker");
                getApp().setBackgroundEvent();
            } else {
                System.println("Disabling tracker");
                getApp().deleteBackgroundEvent();
            }
        } else {
            System.println("Not implemented menu");
        }
    }
}