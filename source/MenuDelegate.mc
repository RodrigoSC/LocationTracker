import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function buildMenu () {
        var menu = new WatchUi.Menu2({:title=>"Tracker"});
        var tracker = getApp().tracker;
        menu.addItem(new WatchUi.ToggleMenuItem("Tracking", {:enabled=>"On", :disabled=>"Off"}, "toggle_tracking", 
                    tracker.isTracking(), null));
        menu.addItem(new WatchUi.ToggleMenuItem("Reminder", {:enabled=>"On", :disabled=>"Off"}, "toggle_reminder", 
                    tracker.isReminding(), null));
        menu.addItem(new WatchUi.MenuItem("Status", null, "status", null));
        menu.addItem(new WatchUi.MenuItem("Export", null, "export", null));
        menu.addItem(new WatchUi.MenuItem("Reset...", null, "reset", null));
        return menu;
    }

    public function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        var tracker = getApp().tracker;
        if (id.equals("status")) {
            log("Show status");
            WatchUi.pushView(new StatusView(), null, WatchUi.SLIDE_UP); 
        } else if (id.equals("toggle_tracking")) {
            tracker.setTracking((item as ToggleMenuItem).isEnabled());
        } else if (id.equals("toggle_reminder")) {
            if((item as ToggleMenuItem).isEnabled()) {
                log("Enabling reminder");
                getApp().setBackgroundEvent();
            } else {
                log("Disabling reminder");
                getApp().deleteBackgroundEvent();
            }
        } else if (id.equals("export")) { 
            tracker.export();
        } else if (id.equals("reset")) {
            var dialog = new WatchUi.Confirmation("Are you sure you want to reset the tracking?");
            WatchUi.pushView(dialog, new ResetConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else {
            log("Not implemented menu");
        }
    }
}

class ResetConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            getApp().tracker.reset();
        } 
        return true;
    }
}