using Toybox.Application;
using Toybox.WatchUi;

class SimplySolarApp extends Application.AppBase {
	hidden var SolarView;
	hidden var GlanceView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        SolarView = new SimplySolarView();
        return [ SolarView, new SimplySolarDelegate(SolarView) ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
    	if (SolarView != null) {
			SolarView.getDisplayType();
			SolarView.getPrecision();
    	    WatchUi.requestUpdate();
    	}
    	if (GlanceView != null) {
			GlanceView.getDisplayType();
    	    GlanceView.requestUpdate();
    	}
    }

(:glance)
    function getGlanceView() {
        GlanceView = new SimplySolarGlanceView();
        return [ GlanceView ];
    }

}