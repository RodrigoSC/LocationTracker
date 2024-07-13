import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MenuDelegate extends WatchUi.Menu2InputDelegate {
    var progressBar as WatchUi.ProgressBar?;
    var tracker as Tracker;

    function initialize(tracker as Tracker) {
        me.tracker = tracker;
        Menu2InputDelegate.initialize();
    }

    public function buildMenu () {
        var menu = new WatchUi.Menu2({:title=>"Tracker"});
        menu.addItem(new WatchUi.ToggleMenuItem("Tracking", {:enabled=>"On", :disabled=>"Off"}, "toggle_tracking", 
                    tracker.isTracking(), null));
        menu.addItem(new WatchUi.MenuItem("Reminder", reminderText(tracker.getReminderInterval()), "reminder", null));
        menu.addItem(new WatchUi.MenuItem("Export", null, "export", null));
        menu.addItem(new WatchUi.MenuItem("Reset...", null, "reset", null));
        return menu;
    }

    public function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id.equals("toggle_tracking")) {
            tracker.setTracking((item as ToggleMenuItem).isEnabled());
        } else if (id.equals("reminder")) {
            var reminderDelegate = new ReminderMenuDelegate(tracker, item);
            WatchUi.pushView(reminderDelegate.buildMenu(), reminderDelegate, WatchUi.SLIDE_RIGHT);
        } else if (id.equals("export")) { 
            progressBar = new WatchUi.ProgressBar("Processing...", null);
            WatchUi.pushView(progressBar, new ExportProgressDelegate(), WatchUi.SLIDE_IMMEDIATE);
            tracker.export(method(:exportProgress));
        } else if (id.equals("reset")) {
            var dialog = new WatchUi.Confirmation("Are you sure you want to reset the tracking?");
            WatchUi.pushView(dialog, new ResetConfirmationDelegate(tracker), WatchUi.SLIDE_IMMEDIATE);
        } else {
            log("Not implemented menu");
        }
    }

    function exportProgress (responseCode as Number, percent as Float) as Void {
        progressBar.setProgress(percent);
        if (percent == 100.0) {
            if (responseCode == 200) {
                progressBar.setDisplayString("Done!");
            } else if (responseCode == -104) {
                progressBar.setDisplayString("Phone not connected");
            } else {
                progressBar.setDisplayString("Error code: " + responseCode);
            }
        }
    }
}

class ReminderMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var menuitem as MenuItem?;
    private var tracker as Tracker?;

    function initialize(tracker as Tracker, item as MenuItem) {
        menuitem = item;
        me.tracker = tracker;
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
        tracker.setReminderInterval(id.toNumber());
        menuitem.setSubLabel(reminderText(tracker.getReminderInterval()));
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class ResetConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var tracker as Tracker;
    
    function initialize(tracker as Tracker) {
        me.tracker = tracker;
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            tracker.reset();
        } 
        return true;
    }
}

class ExportProgressDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        return true;
    }
}

public function reminderText (interval) as String {
    if (interval == 0) { return "No reminder set";}
    else if (interval < 60) { return Lang.format("Every $1$ minutes", [interval]);}
    else if (interval >= 60) { return Lang.format("Every $1$ hours", [interval / 60]);}
    else { return "Bogus!"; }
}