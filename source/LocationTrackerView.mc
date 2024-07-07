import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Application.Storage;

class LocationTrackerView extends WatchUi.View {
    private var _menuPushed as Boolean;

    function initialize() {
        View.initialize();
        _menuPushed = false;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
    }

    // Called when this View is brought to the foreground.
    // Used to show the app view
    public function onShow() as Void {
        logm("LocationTrackerView", "onShow");
        if (_menuPushed == false) {
            var delegate = new MenuDelegate();
            WatchUi.pushView(delegate.buildMenu(), delegate, WatchUi.SLIDE_UP);
            _menuPushed = true;
        } else {
            WatchUi.popView(WatchUi.SLIDE_UP);
        }
    }
    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}
