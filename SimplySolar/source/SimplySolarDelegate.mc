using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Math;

class SimplySolarDelegate extends Ui.BehaviorDelegate {
    /* Initialize and get a reference to the view, so that
     * user iterations can call methods in the main view. */
	var SSView;
     
    function initialize(view) {
        Ui.BehaviorDelegate.initialize();
        SSView = view;
    }

    function onSelect() {
        Ui.requestUpdate();
        return true;
    }

    function onMenu() {
        SSView.setPrecision((SSView.Places + 1) % 2);
        
        Ui.requestUpdate();
        return true;
    }

}
