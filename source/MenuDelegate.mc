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
        menu.addItem(new WatchUi.MenuItem("Reminder", reminderText(tracker.getReminderInterval()), "reminder", null));
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
        } else if (id.equals("reminder")) {
            var reminderDelegate = new ReminderMenuDelegate(item);
            WatchUi.pushView(reminderDelegate.buildMenu(), reminderDelegate, WatchUi.SLIDE_RIGHT);
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

class ReminderMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _item as MenuItem?;

    function initialize(item as MenuItem) {
        _item = item;
        Menu2InputDelegate.initialize();
    }

    public function buildMenu () {
        var menu = new WatchUi.Menu2({:title=>"Reminder"});
        menu.addItem(new WatchUi.MenuItem("No reminder", null, "0", null));
        menu.addItem(new WatchUi.MenuItem("Every 5 minutes", null, "5", null));
        menu.addItem(new WatchUi.MenuItem("Every 30 minutes", null, "30", null));
        menu.addItem(new WatchUi.MenuItem("Every 1 hours", null, "60", null));
        menu.addItem(new WatchUi.MenuItem("Every 2 hours", null, "120", null));
        menu.addItem(new WatchUi.MenuItem("Every 3 hours", null, "120", null));
        menu.addItem(new WatchUi.MenuItem("Every 8 hours", null, "480", null));
        menu.addItem(new WatchUi.MenuItem("Every 8 hours", null, "480", null));
        menu.addItem(new WatchUi.MenuItem("Every day", null, "1440", null));
        return menu;
    }

    public function onSelect(item as MenuItem) as Void {
        var id = item.getId() as String;
        var tracker = getApp().tracker;
        tracker.setReminderInterval(id.toNumber());
        _item.setSubLabel(reminderText(tracker.getReminderInterval()));
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
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

public function reminderText (interval) as String {
    if (interval == 0) { return "No reminder set";}
    else if (interval < 60) { return Lang.format("Every $1$ minutes", [interval]);}
    else if (interval >= 60) { return Lang.format("Every $1$ hours", [interval / 60]);}
    else { return "Bogus!"; }
}