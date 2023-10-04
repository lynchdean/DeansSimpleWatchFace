import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;

class WatchFaceSimpleView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
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
        setClockDisplay();
        setDateDisplay();
        setBatteryDisplay();
        setHeartrateDisplay();

        // Call the parent onUpdate function to redraw the layout
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

    hidden function setClockDisplay() {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeDisplay") as Text;
        view.setText(timeString);
    }

    hidden function setDateDisplay() {        
    	var now = Time.now();
	    var date = Gregorian.info(now, Time.FORMAT_LONG);
	    var dateString = Lang.format("$1$ $2$, $3$", [date.month, date.day, date.year]);
	    var dateDisplay = View.findDrawableById("DateDisplay")as Text;      
	    dateDisplay.setText(dateString);	    	
    }

    hidden function setBatteryDisplay() {
        var battery = System.getSystemStats().battery;				
	    var batteryDisplay = View.findDrawableById("BatteryDisplay") as Text;      
	    batteryDisplay.setText(battery.format("%d")+"%");
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
