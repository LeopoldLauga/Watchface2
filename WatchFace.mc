import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Weather;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.SensorHistory;

class WatchFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();   // 360
        var h = dc.getHeight();  // 360
        var cx = w / 2;          // 180
        var cy = h / 2;          // 180

        // ── BACKGROUND ───────────────────────────────────────
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // ── TIME (large teal) ─────────────────────────────────
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var timeStr = now.hour.format("%02d") + ":" + now.min.format("%02d");

        dc.setColor(0x81FFE8, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 135, Graphics.FONT_NUMBER_THAI_HOT, timeStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ── SECONDS ───────────────────────────────────────────
        var secStr = now.sec.format("%02d");
        dc.setColor(0x2aaa88, Graphics.COLOR_TRANSPARENT);
        dc.drawText(305, 195, Graphics.FONT_SMALL, secStr, Graphics.TEXT_JUSTIFY_RIGHT);

        // ── DATE badge (top centre) ───────────────────────────
        var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dayStr   = dayNames[now.day_of_week - 1];
        var dateNum  = now.day.toString();

        // White pill background
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRoundedRectangle(143, 14, 74, 30, 5);

        // Date number (black on white)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(180, 29, Graphics.FONT_MEDIUM, dateNum,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Day label above the pill
        dc.setColor(0x2a2a2a, Graphics.COLOR_TRANSPARENT);
        dc.drawText(180, 10, Graphics.FONT_XTINY, dayStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ── "ThursdayFace" label (from your SVG) ──────────────
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(180, 60, Graphics.FONT_XTINY, "ThursdayFace",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ── DIVIDER LINE ──────────────────────────────────────
        dc.setColor(0x1a1a1a, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(40, 220, 320, 220);

        // ── WIDGET CIRCLES ───────────────────────────────────
        // Left (82,282), Centre (180,282), Right (278,282), radius ~40
        var widgetY  = 282;
        var widgetR  = 40;
        var lx = 82;
        var mx = 180;
        var rx = 278;

        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(lx, widgetY, widgetR);
        dc.drawCircle(mx, widgetY, widgetR);
        dc.drawCircle(rx, widgetY, widgetR);

        // ── LEFT WIDGET: Weather / Temp ───────────────────────
        var tempStr = "--°";
        if (Weather has :getCurrentConditions) {
            var conditions = Weather.getCurrentConditions();
            if (conditions != null && conditions.temperature != null) {
                tempStr = conditions.temperature.format("%d") + "°";
            }
        }
        // Cloud icon (simplified arc)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(lx - 6, widgetY - 10, 10, Graphics.ARC_COUNTER_CLOCKWISE, 0, 180);
        dc.drawArc(lx + 4, widgetY - 13, 8,  Graphics.ARC_COUNTER_CLOCKWISE, 0, 180);
        dc.drawArc(lx + 13, widgetY - 8, 6,  Graphics.ARC_COUNTER_CLOCKWISE, 0, 180);
        dc.drawLine(lx - 16, widgetY - 8, lx + 19, widgetY - 8);
        // Rain drops
        dc.setColor(0x81FFE8, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(lx - 8, widgetY - 4, lx - 10, widgetY + 4);
        dc.drawLine(lx,     widgetY - 4, lx - 2,  widgetY + 4);
        dc.drawLine(lx + 8, widgetY - 4, lx + 6,  widgetY + 4);
        // Temp text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(lx, widgetY + 14, Graphics.FONT_XTINY, tempStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ── CENTRE WIDGET: Activity rings + HR ────────────────
        var hrVal   = "--";
        var stepPct = 0.0f;
        var hrPct   = 0.0f;

        // Steps
        var actInfo = ActivityMonitor.getInfo();
        if (actInfo != null) {
            var steps = actInfo.steps;
            var goal  = actInfo.stepGoal;
            if (steps != null && goal != null && goal > 0) {
                stepPct = steps.toFloat() / goal.toFloat();
                if (stepPct > 1.0f) { stepPct = 1.0f; }
            }
        }

        // Heart rate
        var actData = Activity.getActivityInfo();
        if (actData != null && actData.currentHeartRate != null) {
            hrVal = actData.currentHeartRate.toString();
            hrPct = (actData.currentHeartRate - 40).toFloat() / 160.0f;
            if (hrPct < 0.0f) { hrPct = 0.0f; }
            if (hrPct > 1.0f) { hrPct = 1.0f; }
        }

        // Steps ring (outer, green)
        var stepDeg = (stepPct * 330).toNumber();
        dc.setPenWidth(5);
        dc.setColor(0x1a3320, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(mx, widgetY, 34, Graphics.ARC_CLOCKWISE, 105, -225);
        if (stepDeg > 0) {
            dc.setColor(0x66bb6a, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(mx, widgetY, 34, Graphics.ARC_COUNTER_CLOCKWISE, 90, 90 - stepDeg);
        }

        // HR ring (inner, red)
        var hrDeg = (hrPct * 330).toNumber();
        dc.setColor(0x2a0f0f, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(mx, widgetY, 24, Graphics.ARC_CLOCKWISE, 105, -225);
        if (hrDeg > 0) {
            dc.setColor(0xef5350, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(mx, widgetY, 24, Graphics.ARC_COUNTER_CLOCKWISE, 90, 90 - hrDeg);
        }
        dc.setPenWidth(1);

        // HR value
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mx, widgetY - 4, Graphics.FONT_SMALL, hrVal,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mx, widgetY + 10, Graphics.FONT_XTINY, "BPM",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ── RIGHT WIDGET: Steps ───────────────────────────────
        var stepsStr = "--";
        if (actInfo != null && actInfo.steps != null) {
            var s = actInfo.steps;
            if (s >= 1000) {
                stepsStr = (s / 1000).toString() + "," + (s % 1000).format("%03d");
            } else {
                stepsStr = s.toString();
            }
        }
        // Simple foot icon (two ellipses)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(rx - 7, widgetY - 14, 5, 7);
        dc.fillEllipse(rx + 5, widgetY - 6,  5, 7);
        // Steps value
        dc.drawText(rx, widgetY + 10, Graphics.FONT_XTINY, stepsStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rx, widgetY + 22, Graphics.FONT_XTINY, "STEPS",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {
    }
}

class WatchFaceApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new WatchFaceView()];
    }
}
