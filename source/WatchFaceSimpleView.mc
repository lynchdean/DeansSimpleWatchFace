import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Weather;
import Toybox.Position;

class WatchFaceSimpleView extends WatchUi.WatchFace {

    var myShapes;
    var date;
    var clockFont;
    var currentConditions;

    function initialize() {
        WatchFace.initialize();
        myShapes = new Rez.Drawables.shapes();
        currentConditions = Weather.getCurrentConditions();
	    date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    } 

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Draw Background Template 
        // myShapes.draw();

        setHoursMinutes();
        setSeconds();
        setHeartRate();
        setDate();
        setBattery();
        if (currentConditions != null) {
            setTemperature();
            setPrecipitationChance();
            setSunset();
        }
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    hidden function setHoursMinutes() {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        var textArea = View.findDrawableById("HoursMinutesText") as Text;
        textArea.setText(timeString);
    }

    hidden function setSeconds() {
        var clockTime = System.getClockTime();
        var secondsString = clockTime.sec.format("%02d");
        var textArea = View.findDrawableById("SecondsText") as Text;
        textArea.setText(secondsString);
    }

    hidden function setBattery() {
        var battery = System.getSystemStats().battery;				
	    var textArea = View.findDrawableById("BatteryText") as Text;      
	    textArea.setText(battery.format("%d")+"%");
    }

    hidden function setHeartRate() {
    	var heartRate = "";
        var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
        var currentHeartrate = heartrateIterator.next().heartRate;

        if(currentHeartrate == ActivityMonitor.INVALID_HR_SAMPLE) {
            heartRate = "--";
        } else {
            heartRate = currentHeartrate.format("%d");
        }	

	    var heartrateDisplay = View.findDrawableById("HeartRateText") as Text;      
	    heartrateDisplay.setText(heartRate);
    }

    hidden function setDate() {        
        var dateNumberString = Lang.format("$1$", [date.day]);
	    var dateDayString = Lang.format("$1$", [date.day_of_week]).substring(0, 3).toUpper();
	    var dateNumber = View.findDrawableById("DateNumberText") as Text;      
	    dateNumber.setText(dateNumberString);	    
        var textArea = View.findDrawableById("DateDayText") as Text;      
	    textArea.setText(dateDayString);
    }

    hidden function setTemperature() {   
        if(currentConditions.temperature != null) {
	        var textArea = View.findDrawableById("TemperatureText") as Text; 
            textArea.setText(currentConditions.temperature.format("%d"));
        }  
    }

    hidden function setPrecipitationChance() {
        if (currentConditions.precipitationChance != null) {
            var chance = currentConditions.precipitationChance;
            var textArea = View.findDrawableById("RainText") as Text; 
            textArea.setText(chance.format("%d") + "%");
        }
    }

    hidden function setSunset() {
        if (currentConditions.observationLocationPosition != null && currentConditions.observationTime != null) {
            var sunset = Weather.getSunset(currentConditions.observationLocationPosition, currentConditions.observationTime);
            var info = Gregorian.utcInfo(sunset, Time.FORMAT_SHORT);
            var time = Lang.format("$1$:$2$", [info.hour.format("%02d"), info.min.format("%02d")]);
            var textArea = View.findDrawableById("SunsetText") as Text;      
            textArea.setText(time);
        }
    }
}
