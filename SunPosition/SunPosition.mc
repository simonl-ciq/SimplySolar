using Toybox.Math;
/*
using Toybox.Time as Time;
using Toybox.Time.Gregorian;
*/
using Toybox.System as Sys;

(:glance)
module SunPosition {

const	leapYearsTo1949 = 472; // Number of leap years is theoretical based on current leap year rules.
const	leapDaysInAYear = 0.2425;

const	month_days = [0,31,28,31,30,31,30,31,31,30,31,30];

function leapyear(year)  {
    if (year % 400 == 0)  {return true;}
    else if (year % 100 == 0) {return false;}
    else if (year % 4 == 0) {return true;}
    else { return false;}
}

function leapYearsSince1949(year) {
    var leapYearsToGivenYear = (year * leapDaysInAYear).toNumber();
    var leapYearsBetweenYears = leapYearsToGivenYear - leapYearsTo1949;
    return leapYearsBetweenYears;
}

function calc_time(year, month, day, hour, minute, sec) {
    // Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leap years
//    day = day + sum(month_days[:month])
    var m; for (m = 0; m<month; m++) { day += month_days[m]; }

//    leapdays = leapyear(year) and day >= 60 and (not (month==2 and day==60));
    var leapdays = leapyear(year) && (day >= 60) && (!(month==2 && day==60));
    if (leapdays) {
    	day += 1;
    }
    // Get Julian date - 2400000
	hour = hour + minute / 60.0 + sec / 3600.0; // hour plus fraction
	var delta = year - 1949;
	var leap = leapYearsSince1949(year); // former leapyears
	var jd = 32916.5 + (delta * 365) + leap + day + (hour / 24.0);
    // The input to the Astronomer's almanac is the difference between
    // the Julian date and JD 2451545.0 (noon, 1 January 2000)
	var time = jd - 51545;
	return time;
}

// returns remainder a/b - a can be float point, b must be integer
function myMod(a, b) {
	return (a - ((a.toLong() / b) * b));
}

function meanLongitudeDegrees(time) {
//     return ((280.460 + 0.9856474 * time) % 360)
	return myMod ((280.460 + 0.9856474 * time), 360);
}

function meanAnomalyRadians(time) {
//    return (math.radians((357.528 + 0.9856003 * time) % 360))
    return Math.toRadians(myMod((357.528 + 0.9856003 * time), 360));
}

function eclipticLongitudeRadians(mnlong, mnanomaly) {
//  math.radians((mnlong + 1.915 * math.sin(mnanomaly) + 0.020 * math.sin(2 * mnanomaly)) % 360)
    return Math.toRadians(myMod((mnlong + 1.915 * Math.sin(mnanomaly) + 0.020 * Math.sin(2 * mnanomaly)), 360));
}

function eclipticObliquityRadians(time) {
    return (Math.toRadians(23.439 - 0.0000004 * time));
}

function rightAscensionRadians(oblqec, eclong) {
    var num = Math.cos(oblqec) * Math.sin(eclong);
    var den = Math.cos(eclong);
    var ra = Math.atan(num / den);
    if (den<0) { ra += Math.PI; }
    if (den >= 0 and num < 0) { ra += 2 * Math.PI ;}
    return (ra);
}

function rightDeclinationRadians(oblqec, eclong) {
    return (Math.asin(Math.sin(oblqec) * Math.sin(eclong)));
}

function greenwichMeanSiderealTimeHours(time, hour) {
//    return ((6.697375 + 0.0657098242 * time + hour) % 24)
    return myMod((6.697375 + 0.0657098242d * time + hour), 24);
}

/*
//  Original - lon in degrees (15 is 360 / 24)
function localMeanSiderealTimeRadians(gmst, lon) {
//    return (math.radians(15 * ((gmst + longitude / 15.0) % 24)))
	return Math.toRadians(15 * myMod((gmst + lon / 15.0), 24));
}
*/

// Modified - lon in radians (0.2617... is 2PI / 24)
function localMeanSiderealTimeRadians(gmst, lon) {
//    return (math.radians(15 * ((gmst + longitude / 15.0) % 24)))
	return 0.2617993950843811d * myMod((gmst + lon / 0.2617993950843811d), 24);
}

function hourAngleRadians(lmst, ra) {
//    return (((lmst - ra + math.pi) % (2 * math.pi)) - math.pi)
    return Math.toRadians(myMod(Math.toDegrees(lmst - ra) + 180, 360) - 180);
}

function elevationRadians(lat, dec, ha) {
    return (Math.asin(Math.sin(dec) * Math.sin(lat) + Math.cos(dec) * Math.cos(lat) * Math.cos(ha)));
}

function solarAzimuthRadiansCharlie(lat, dec, ha) {
    var zenithAngle = Math.acos(Math.sin(lat) * Math.sin(dec) + Math.cos(lat) * Math.cos(dec) * Math.cos(ha));
    var cos = ((Math.sin(lat) * Math.cos(zenithAngle) - Math.sin(dec)) / (Math.cos(lat) * Math.sin(zenithAngle)));
	var az;
	if (cos >= 1.0d) {
		az = 0.0d;
	} else if (cos <= -1.0d) {
		az = Math.PI;
	} else {
		az = Math.acos(cos);
	}
    if (ha > 0) {
        az = az + Math.PI;
    } else {
        az = Math.toRadians(myMod((3 * 180 - Math.toDegrees(az)), 360));
	}
    return az;
}

// lat & lon are in radians
function sun_position(year, month, day, hour, minute, sec, lat, lon) {

    var time = calc_time(year, month, day, hour, minute, sec);
    hour = hour + minute / 60.0 + sec / 3600.0;
    // Ecliptic coordinates  
	var mnlong = meanLongitudeDegrees(time);
    var mnanom = meanAnomalyRadians(time);
    var eclong = eclipticLongitudeRadians(mnlong, mnanom);
    var oblqec =  eclipticObliquityRadians(time);
    // Celestial coordinates
    var ra = rightAscensionRadians(oblqec, eclong);
    var dec = rightDeclinationRadians(oblqec, eclong);
    // Local coordinates
    var gmst = greenwichMeanSiderealTimeHours(time, hour);
	var lmst = localMeanSiderealTimeRadians(gmst, lon);

    // Hour angle
    var ha = hourAngleRadians(lmst, ra);
    // Latitude to radians
//    lat = Math.toRadians(lat);
    // Azimuth and elevation
    var el = elevationRadians(lat, dec, ha);
//    azJ = solarAzimuthRadiansJosh(lat, dec, ha, el)
    var azC = solarAzimuthRadiansCharlie(lat, dec, ha);

    var elevation = Math.toDegrees(el);
//    azimuthJ  = Math.degrees(azJ)
    var azimuth  = Math.toDegrees(azC);
    return ( [azimuth, elevation] );
}

}