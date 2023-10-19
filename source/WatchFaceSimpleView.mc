import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;

class WatchFaceSimpleView extends WatchUi.WatchFace {

    var myShapes;

    function initialize() {
        WatchFace.initialize();
        myShapes = new Rez.Drawables.shapes();
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
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Draw Background Template 
        myShapes.draw(dc);

        drawHoursMinutes(dc);
        drawSeconds(dc);
        drawBattery(dc);
        // setClockDisplay();
        // setDateDisplay();
        // setBatteryDisplay();
        // setHeartrateDisplay();

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

    hidden function drawHoursMinutes(dc) {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        var view = View.findDrawableById("HoursMinutesText");
        (view as Text).setText(timeString);
        view.draw(dc);
    }

    hidden function drawSeconds(dc) {
        var clockTime = System.getClockTime();
        var secondsString = clockTime.sec.format("%02d");
        var view = View.findDrawableById("SecondsText");
        (view as Text).setText(secondsString);
        view.draw(dc);
    }

    hidden function drawBattery(dc) {
        var battery = System.getSystemStats().battery;				
	    var view = View.findDrawableById("BatteryText");      
	    (view as Text).setText(battery.format("%d")+"%");
        view.draw(dc);
    }

    hidden function setDateDisplay() {        
    	var now = Time.now();
	    var date = Gregorian.info(now, Time.FORMAT_LONG);
	    var dateString = Lang.format("$1$ $2$, $3$", [date.month, date.day, date.year]);
	    var dateDisplay = View.findDrawableById("DateDisplay")as Text;      
	    dateDisplay.setText(dateString);	    	
    }

    hidden function setHeartrateDisplay() {
    	var heartRate = "";
        var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
        var currentHeartrate = heartrateIterator.next().heartRate;

        if(currentHeartrate == ActivityMonitor.INVALID_HR_SAMPLE) {
            heartRate = "--";
        } else {
            heartRate = currentHeartrate.format("%d");
        }	

	    var heartrateDisplay = View.findDrawableById("HeartrateDisplay") as Text;      
	    heartrateDisplay.setText(heartRate);
    }
}
