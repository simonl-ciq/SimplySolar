using Toybox.Application;

class SimplySolarApp extends Application.AppBase {
	hidden var SolarView;

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

(:glance)
    function getGlanceView() {
        return [ new SimplySolarGlanceView() ];
    }

}