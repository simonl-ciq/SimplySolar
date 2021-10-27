using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
/*
using Toybox.Math;
*/

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
        SSView.setNoon(!SSView.SNoon);
        Ui.requestUpdate();
        return true;
    }

	function changeBearing() {
   	    if (!SSView.SNoon) { SSView.setDisplayType(!SSView.SBearing); }
        Ui.requestUpdate();
       	return true;
	}

    function onKey(evt) {
    	var key = evt.getKey();
		return (key == Ui.KEY_CLOCK || key == Ui.KEY_LAP || key == Ui.KEY_ZOUT) ? changeBearing() : false;
    }

    function onSwipe(evt) {
    	var direction = evt.getDirection();
		return (direction == Ui.SWIPE_LEFT || direction == Ui.SWIPE_RIGHT) ? changeBearing() : false;
    }

}
