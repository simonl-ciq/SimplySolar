using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Application.Properties as Props;
using Toybox.Application.Storage as Storage;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Position as Position;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using SunPosition as Sunpos;

const	cSBearing = false;

class SimplySolarView extends Ui.View {
	
	var myInfo = null;
	var needGPS = true;
	var Places = 0;
	var Precision = "%.0f";
	var SBearing = false;
	
	var Title = "Solar Angles";
	var Azimuth = "Azimuth";
	var Bearing = "Shadow Bearing";
	var Elevation = "Elevation";
	var NoGPS = "acquiring GPS";

// This function allows us to make for pre2.4.x devices e.g. fenix3
	function utcHour(date) {
		return (date.value() % Gregorian.SECONDS_PER_DAY) / Gregorian.SECONDS_PER_HOUR;
	}

    function initialize() {
    	var temp;
        temp = Ui.loadResource( Rez.Strings.Title );
        if (temp != null ) {Title = temp;}
        temp = Ui.loadResource( Rez.Strings.Azimuth );
        if (temp != null ) {Azimuth = temp;}
        temp = Ui.loadResource( Rez.Strings.Elevation );
        if (temp != null ) {Elevation = temp;}
        temp = Ui.loadResource( Rez.Strings.NoGPS );
        if (temp != null ) {NoGPS = temp;}

		if ( App has :Properties ) {
	        temp = Props.getValue("DisplayType");
	    } else {
	        temp = App.getApp().getProperty("DisplayType");
	    }
       	SBearing = (temp != null && temp instanceof Number) ? (temp != 0) : cSBearing;

        if ( App has :Storage ) {
	    	temp = Storage.getValue("places");
	        if (temp == null) {
		        Storage.setValue("places", Places);
    		}
		} else {
	        temp = App.getApp().getProperty("places");
	        if (temp == null) {
		        App.getApp().setProperty("places", Places);
    		}
		}
		if (temp != null) {
   			Places = temp;
   		}

        View.initialize();
    }

    /* ======================== Position handling ========================== */

    function onPosition(info) {
    	myInfo = info;
        Ui.requestUpdate();
    }

    function setPrecision(p) {
		var azView = View.findDrawableById("azimuth");
		var elView = View.findDrawableById("elevation");

		Places = p;
        if ( App has :Storage ) {
	        Storage.setValue("places", Places);
		} else {
	        App.getApp().setProperty("places", Places);
		}
		Precision = "%." + Places.toString() + "f";
//		doFont(azView, elView, Places);
	}

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));

		var tmpView = View.findDrawableById("title");
		tmpView.setText(Title);

		var azitView = View.findDrawableById("azititle");
		azitView.setText(Azimuth);

		var eletView = View.findDrawableById("eletitle");
		eletView.setText(Elevation);

		setPrecision(Places);
		
		myInfo = Position.getInfo();
        if (myInfo == null || myInfo.accuracy < Position.QUALITY_POOR) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
		}
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
//        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // Update the view
    function onUpdate(dc) {
    	var az = "";
    	var el = "";
    	var azit = Azimuth;
    	var elet = Elevation;

		var azView = View.findDrawableById("azimuth");
		var azitView = View.findDrawableById("azititle");

		var elView = View.findDrawableById("elevation");
		var eletView = View.findDrawableById("eletitle");
		
		if (needGPS) {
	    	if (myInfo == null || myInfo.accuracy == null || myInfo.accuracy < Position.QUALITY_POOR) {
		    	myInfo = Position.getInfo();
		    }
			if (myInfo.accuracy != null && myInfo.accuracy != Position.QUALITY_NOT_AVAILABLE && myInfo.position != null) {
				if (myInfo.accuracy >= Position.QUALITY_POOR) {
		            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
					needGPS = false;
	    		}
	    	}
		}

		var myAccuracy = (!(myInfo has :accuracy) || myInfo.accuracy == null) ? Position.QUALITY_GOOD : myInfo.accuracy;
		if (myAccuracy > Position.QUALITY_NOT_AVAILABLE && myInfo.position != null) {
   			var loc = myInfo.position.toRadians();
    		var now = Time.now();
    		var today = Gregorian.info(now, Time.FORMAT_SHORT);
			var azimelev = Sunpos.sun_position(today.year, today.month, today.day, utcHour(now), today.min, today.sec, loc[0], loc[1]);
    		if (SBearing) {
    			azimelev[0] = Sunpos.myMod((azimelev[0] + 180), 360);
    			azit = Bearing;
    		} else {
    			azit = Azimuth;
    		}
    		
			az = azimelev[0].format(Precision);
			if (az.equals("360")) { az = "0"; }
			else if (az.equals("360.0")) { az = "0.0"; }
			el = azimelev[1].format(Precision);
			if (myAccuracy == Position.QUALITY_LAST_KNOWN) {
				azView.setColor(Gfx.COLOR_LT_GRAY);
				elView.setColor(Gfx.COLOR_LT_GRAY);
			} else {
				azView.setColor(Gfx.COLOR_WHITE);
				elView.setColor(Gfx.COLOR_WHITE);
			}
		} else {
    		azit = NoGPS + " ...";
    		elet = "";
		}

		azitView.setText(azit);
		azView.setText(az);
		eletView.setText(elet);
		elView.setText(el);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

}

(:glance)
class SimplySolarGlanceView extends Ui.GlanceView {
	var vcentre = 80;
	var SBearing = false;

	function initialize() {
		var temp = Props.getValue("DisplayType");
       	SBearing = (temp != null && temp instanceof Number) ? (temp != 0) : cSBearing;
		GlanceView.initialize();
	}

	function onLayout(dc) {
		vcentre = dc.getFontHeight(Gfx.FONT_SMALL) - 2;
		vcentre = 30;
	}

	function onUpdate(dc) {
		var azit = "a";
		var az = "";
		var el = "";
	    var	myInfo = Position.getInfo();
//	    	    myInfo.position = Position.parse("53.825564, -2.421976", Position.GEO_DEG);
//	    	    myInfo.position = Position.parse("34.0522, -118.2437", Position.GEO_DEG);
// Tokyo 35.6762, 139.6503

		var myAccuracy = (!(myInfo has :accuracy) || myInfo.accuracy == null) ? Position.QUALITY_GOOD : myInfo.accuracy;
		if (myAccuracy > Position.QUALITY_NOT_AVAILABLE && myInfo.position != null) {
			var loc = myInfo.position.toRadians();
    		var today = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
    		var azimelev = Sunpos.sun_position(today.year, today.month, today.day, today.hour, today.min, today.sec, loc[0], loc[1]);
    		if (SBearing) {
    			azimelev[0] = Sunpos.myMod((azimelev[0] + 180), 360);
    			azit = "b";
    		} else {
    			azit = "a";
    		}
			az = azimelev[0].format("%.0f");
			if (az.equals("360")) {az = "0";}
			az = azit+":"+az+"°";
			el = "e:"+azimelev[1].format("%.0f")+"°";
		}
		dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
		dc.clear();
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
        var AppName = Ui.loadResource( Rez.Strings.AppName );
        if (AppName == null ) {AppName = "Solar Angles";}
		dc.drawText(0, 0, Gfx.FONT_SMALL, AppName, Gfx.TEXT_JUSTIFY_LEFT);
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		if (myInfo.accuracy == Position.QUALITY_LAST_KNOWN) {
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		}
		dc.drawText(0, vcentre, Gfx.FONT_TINY, az, Gfx.TEXT_JUSTIFY_LEFT);
		var x = dc.getTextDimensions(AppName, Gfx.FONT_SMALL)[0];
		dc.drawText(x, vcentre, Gfx.FONT_TINY, el, Gfx.TEXT_JUSTIFY_RIGHT);
	}

}
