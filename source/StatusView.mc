import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

class StatusView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout($.Rez.Layouts.StatusLayout(dc));
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var timeView = View.findDrawableById("time") as Text;
        var lonView = View.findDrawableById("lon") as Text;
        var latView = View.findDrawableById("lat") as Text;
        var myLocation = Position.getInfo().position.toDegrees();
        
        timeView.setText(Time.now().value().format("%02d"));
        lonView.setText(myLocation[0].format("%f"));
        latView.setText(myLocation[1].format("%f"));
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}
