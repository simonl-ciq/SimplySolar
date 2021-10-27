//https://github.com/haraldh/SunCalc/blob/master/source/



using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

enum {
	NIGHT_END,
	NAUTICAL_DAWN,
	DAWN,
	BLUE_HOUR_AM,
	SUNRISE,
	SUNRISE_END,
	GOLDEN_HOUR_AM,
	NOON,
	GOLDEN_HOUR_PM,
	SUNSET_START,
	SUNSET,
	BLUE_HOUR_PM,
	DUSK,
	NAUTICAL_DUSK,
	NIGHT,
	NUM_RESULTS
}

class SunCalc {

	hidden const PI   = Math.PI,
		RAD  = Math.PI / 180.0,
		PI2  = Math.PI * 2.0,
		DAYS = Time.Gregorian.SECONDS_PER_DAY,
		J1970 = 2440588,
		J2000 = 2451545,
		J0 = 0.0009;

	hidden const TIMES = [
		-18 * RAD,
		-12 * RAD,
		-6 * RAD,
		-4 * RAD,
		-0.833 * RAD,
		-0.3 * RAD,
		6 * RAD,
		null,
		6 * RAD,
		-0.3 * RAD,
		-0.833 * RAD,
		-4 * RAD,
		-6 * RAD,
		-12 * RAD,
		-18 * RAD
		];

	var lastD, lastLng;
	var	n, ds, M, sinM, C, L, sin2L, dec, Jnoon;

	function initialize() {
		lastD = null;
		lastLng = null;
	}

	function fromJulian(j) {
		return new Time.Moment((j + 0.5 - J1970) * DAYS);
	}

	function round(a) {
		if (a > 0) {
			return (a + 0.5).toNumber().toFloat();
		} else {
			return (a - 0.5).toNumber().toFloat();
		}
	}

	// lat and lng in radians
	function calculate(moment, lat, lng, what) {
		var d = moment.value().toDouble() / DAYS - 0.5 + J1970 - J2000;
		if (lastD != d || lastLng != lng) {
			n = round(d - J0 + lng / PI2);
//			ds = J0 - lng / PI2 + n;
			ds = J0 - lng / PI2 + n - 1.1574e-5 * 68;
			M = 6.240059967 + 0.0172019715 * ds;
			sinM = Math.sin(M);
			C = (1.9148 * sinM + 0.02 * Math.sin(2 * M) + 0.0003 * Math.sin(3 * M)) * RAD;
			L = M + C + 1.796593063 + PI;
			sin2L = Math.sin(2 * L);
			dec = Math.asin( 0.397783703 * Math.sin(L) );
			Jnoon = J2000 + ds + 0.0053 * sinM - 0.0069 * sin2L;
			lastD = d;
			lastLng = lng;
		}

		if (what == NOON) {
			return fromJulian(Jnoon);
		}

		var x = (Math.sin(TIMES[what]) - Math.sin(lat) * Math.sin(dec)) / (Math.cos(lat) * Math.cos(dec));

		if (x > 1.0 || x < -1.0) {
			return null;
		}

		var ds = J0 + (Math.acos(x) - lng) / PI2 + n - 1.1574e-5 * 68;

		var Jset = J2000 + ds + 0.0053 * sinM - 0.0069 * sin2L;
		if (what > NOON) {
			return fromJulian(Jset);
		}

		var Jrise = Jnoon - (Jset - Jnoon);

		return fromJulian(Jrise);
	}
	
function momentToString(moment, secs, Today, Tomorrow) {
// based on https://github.com/haraldh/SunCalc/blob/master/source/SunCalcView.mc
		if (moment == null) {
			return "--:--";
		}

   		var tinfo = Time.Gregorian.info(new Time.Moment(moment.value() + secs), Time.FORMAT_SHORT);
		var XM="";
		var text="";
		var time;
		if (Sys.getDeviceSettings().is24Hour) {
			time = tinfo.hour.format("%02d") + ":" + tinfo.min.format("%02d");
		} else {
			var hour = tinfo.hour % 12;
			if (hour == 0) {
				hour = 12;
			}
			time = hour.format("%02d") + ":" + tinfo.min.format("%02d");
			if (tinfo.hour < 12 || tinfo.hour == 24) {
				XM = "AM";
			} else {
				XM = "PM";
			}
		}

		var midnight_tonight = new Time.Moment(Time.today().value() + Gregorian.SECONDS_PER_DAY);
		if (moment.lessThan(midnight_tonight) == true) {
			text = Today + " ";
		} else {
			text = Tomorrow + " ";
		}
		return [time, XM, text];
	}
	
}
