import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Weather;
import Toybox.Position;
import Toybox.Application.Properties;

class WatchFaceSimpleView extends WatchUi.WatchFace {
    var settings;
    var stats;
    var textColor;
    var iconColor;

    var now;
    var today;
    var date;

    var currentConditions;
    var sunrise;
    var sunset;

    function initialize() {
        WatchFace.initialize();

        textColor = Properties.getValue("TextColor") as Number;
        iconColor = Properties.getValue("IconColor") as Number;

        settings = System.getDeviceSettings();
        stats = System.getSystemStats();
        currentConditions = Weather.getCurrentConditions();

        date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        today = Time.today();
    } 

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        var screenHeight = settings.screenHeight;

        if (screenHeight != null) {
            if (screenHeight == 454) {
                setLayout(Rez.Layouts.WatchFace454(dc));
            } else {
                // Default to 260x260 & 240x240
                setLayout(Rez.Layouts.WatchFace260(dc));
            }
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void { 
        now = Time.now();
        var newToday = Time.today();
        if (currentConditions != null) {
            if (newToday != today) {
                today = newToday;
                date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
                updateSunsetSunrise();
            }
        }

        stats = System.getSystemStats();
        settings = System.getDeviceSettings();

        setTime();
        setMiddleRight();
        setConnected();
        setHeartRate();
        setDate();
        setBattery();
        if (currentConditions != null) {
            setTemperature();
            setPrecipitationChance();
            setSunriseSunset();
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

    function handleSettingsUpdate() as Void {
        textColor = Properties.getValue("TextColor") as Number;
        iconColor = Properties.getValue("IconColor") as Number;
    }

    hidden function updateSunsetSunrise() as Void {
        var position = currentConditions.observationLocationPosition;
        if (position != null && now != null) {
            sunrise = Weather.getSunrise(position, now);
            sunset = Weather.getSunset(position, now);
        }
    }

    hidden function setTime() as Void {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        if (!settings.is24Hour) {
            hour = hour % 12;
            if (hour == 00) {
                hour = 12;
            }
        }
        var timeString = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
        var textArea = View.findDrawableById("HoursMinutesText") as TextArea;
        textArea.setText(timeString);
        textArea.setColor(textColor);
    }


    hidden function setMiddleRight() as Void {
        var replaceSeconds = Properties.getValue("ReplaceSeconds") as Boolean;
        if (!replaceSeconds) {
            clearNotificationCount();
            setSeconds();
        } else {
            clearSeconds();
            setNotificationCount();
        }
    }

    hidden function setSeconds() as Void {
        var clockTime = System.getClockTime();
        var secondsString = clockTime.sec.format("%02d");
        var textArea = View.findDrawableById("SecondsText") as TextArea;
        textArea.setText(secondsString);
        textArea.setColor(iconColor);
    }

    hidden function clearSeconds() as Void {
        var seconds = View.findDrawableById("SecondsText") as TextArea;
        seconds.setText("");
    }

    hidden function setNotificationCount() as Void {
        var nc = settings.notificationCount;
        if (nc > 99) {
            nc = "99+";
        }
        var icon = View.findDrawableById("NotifCountIcon") as TextArea;
        icon.setText("M");
        icon.setColor(iconColor);
        var textArea = View.findDrawableById("NotifCountText") as TextArea;
        textArea.setText(nc.toString());
        textArea.setColor(textColor);
    }

    hidden function clearNotificationCount() as Void {
        var text = View.findDrawableById("NotifCountText") as TextArea;
        text.setText("");
        var icon = View.findDrawableById("NotifCountIcon") as TextArea;
        icon.setText("");
    }

    hidden function setConnected() as Void {
        if (settings.phoneConnected != null) {
            if (settings.phoneConnected) {
                var textArea = View.findDrawableById("ConnnectedBT") as TextArea;
                textArea.setText("B");
                textArea.setColor(iconColor);
            }
        }
    }

    hidden function setBattery() as Void {
        var battery = stats.battery;	
        var textArea = View.findDrawableById("BatteryText") as TextArea;
	    textArea.setText(battery.format("%d")+"%");
        textArea.setColor(textColor);

        // Set battery icon
        var icon = View.findDrawableById("BatteryIcon") as TextArea;
        icon.setColor(iconColor);

        if (stats.charging)  {
            icon.setText("0");
        } else if (battery > 50) {
           icon.setText("1");
        } else if (battery > 5) {
           icon.setText("2");
        } else {
           icon.setText("3");
        }
    }

    hidden function setHeartRate() as Void {
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr == null) {
            var heartrateIterator = ActivityMonitor.getHeartRateHistory(1, true);
            var hrHistory = heartrateIterator.next();

            if(hrHistory != null && hrHistory.heartRate != ActivityMonitor.INVALID_HR_SAMPLE){
                hr = hrHistory.heartRate;
            } else {
                hr = "--";
            }
        }
        var textArea = View.findDrawableById("HeartRateText") as TextArea; 
	    textArea.setText(hr.format("%d"));
        textArea.setColor(textColor);
        var icon = View.findDrawableById("HeartRateIcon") as TextArea;
        icon.setColor(iconColor);

    }

    hidden function setDate() as Void {        
        if (date == null) {
            date = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        }
        var dateNumberString = Lang.format("$1$", [date.day]);
	    var dateDayString = Lang.format("$1$", [date.day_of_week]).substring(0, 3).toUpper();
	    var dateNumber = View.findDrawableById("DateNumberText") as TextArea;  
	    dateNumber.setText(dateNumberString);	
        dateNumber.setColor(textColor);
        var textArea = View.findDrawableById("DateDayText") as TextArea;
	    textArea.setText(dateDayString);
        textArea.setColor(textColor);
    }

    hidden function setTemperature() as Void {   
        if(currentConditions.temperature != null) {
	        var temperature = currentConditions.temperature;
            // Change unit to fahrenheit if statute defined in system settings
            if (settings != null && settings.temperatureUnits != null) {
                if (settings.temperatureUnits == settings.UNIT_STATUTE) {
                    temperature = (temperature * 1.8) + 32;
                    var temperatureUnit = View.findDrawableById("TemperatureUnit") as TextArea;
                    temperatureUnit.setText("ºF");
                }
            }
            var textArea = View.findDrawableById("TemperatureText") as TextArea;
            textArea.setText(temperature.format("%d"));
            textArea.setColor(textColor);
            var icon = View.findDrawableById("TemperatureUnit") as TextArea;
            icon.setColor(iconColor);
        }  
    }

    hidden function setPrecipitationChance() as Void {
        if (currentConditions.precipitationChance != null) {
            var chance = currentConditions.precipitationChance;
            var textArea = View.findDrawableById("RainText") as TextArea; 
            textArea.setText(chance.format("%d") + "%");
            textArea.setColor(textColor);
            var icon = View.findDrawableById("RainIcon") as TextArea;
            icon.setColor(iconColor);
        }
    }

    hidden function setSunriseSunset() as Void {
        var info;
        var sunIcon = View.findDrawableById("SunIcon") as TextArea;
        sunIcon.setColor(iconColor);

        if(now.greaterThan(sunrise) && now.lessThan(sunset)) {
            info = Gregorian.info(sunset, Time.FORMAT_SHORT);
            sunIcon.setText("s");
        } else {
            info = Gregorian.info(sunrise, Time.FORMAT_SHORT);
            sunIcon.setText("S");
        }

        var sunTime = Lang.format("$1$:$2$", [info.hour.format("%02d"), info.min.format("%02d")]);
        var textArea = View.findDrawableById("SunText") as TextArea;
        textArea.setText(sunTime);
        textArea.setColor(textColor);
    }
}
