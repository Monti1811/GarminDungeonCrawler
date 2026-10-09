import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Page 1: title + progress bar
class DCAchievementDetailView extends WatchUi.View {

    private var _def as Dictionary;
    private const GOLD_COLOR = 0xFFD700;

    function initialize(def as Dictionary) {
        View.initialize();
        _def = def;
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var id = _def["id"] as String;
        var title = _def["title"] as String;
        var target = _def["target"] as Number;
        var mode = _def["mode"] as Symbol;
        var unlocked = $.Achievements.isUnlocked(id);
        var progress = $.Achievements.getProgress(_def);

        // Title (gold)
        dc.setColor(GOLD_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 25 / 100).toNumber(), Graphics.FONT_LARGE, title,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (mode == :flag) {
            // Single milestone: status text only
            dc.setColor(unlocked ? GOLD_COLOR : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, (height * 55 / 100).toNumber(), Graphics.FONT_LARGE,
                unlocked ? "Unlocked" : "Locked",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        // Progress bar
        var bar_x = (width * 10 / 100).toNumber();
        var bar_w = (width * 80 / 100).toNumber();
        var bar_h = (height * 7 / 100).toNumber();
        var bar_y = (height * 48 / 100).toNumber();

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(bar_x, bar_y, bar_w, bar_h, (bar_h / 2).toNumber());

        var fraction = 0.0;
        if (target > 0) {
            fraction = progress.toFloat() / target.toFloat();
        }
        if (fraction > 1.0) {
            fraction = 1.0;
        }
        if (fraction > 0.0) {
            dc.setColor(unlocked ? GOLD_COLOR : Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            var fill = (bar_w * fraction).toNumber();
            if (fill >= 1) {
                dc.fillRoundedRectangle(bar_x, bar_y, fill, bar_h, (bar_h / 2).toNumber());
            }
        }

        // Progress text below the bar
        var percent = (fraction * 100.0).toNumber();
        var status = progress.toString() + "/" + target.toString() + "  (" + percent.toString() + "%)";
        dc.setColor(unlocked ? GOLD_COLOR : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height * 62 / 100).toNumber(), Graphics.FONT_SMALL, status,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

// Page 2: description
class DCAchievementDescriptionView extends WatchUi.View {

    private var _def as Dictionary;

    function initialize(def as Dictionary) {
        View.initialize();
        _def = def;
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var desc = _def["desc"] as String;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var area_width = (width * 84 / 100).toNumber();
        var area_height = (height * 60 / 100).toNumber();
        var text = Graphics.fitTextToArea(desc, Graphics.FONT_SMALL, area_width, area_height, true);
        dc.drawText(width / 2, height / 2, Graphics.FONT_SMALL, text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

// ViewLoop delegate: up/down switches between the two pages
class DCAchievementDetailDelegate extends WatchUi.ViewLoopDelegate {

    private var _viewLoop as ViewLoop;

    function initialize(viewLoop as ViewLoop) {
        ViewLoopDelegate.initialize(viewLoop);
        _viewLoop = viewLoop;
    }

    function onNextView() {
        _viewLoop.changeView(WatchUi.ViewLoop.DIRECTION_PREVIOUS);
        return true;
    }

    function onPreviousView() {
        _viewLoop.changeView(WatchUi.ViewLoop.DIRECTION_NEXT);
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
