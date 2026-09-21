import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCQuestDetailView extends WatchUi.View {

    private var _quest as Quest;
    private var _bgBitmap as BitmapReference;
    private var _small_font as FontResource;
    private var _isOffer as Boolean;
    private var _rightTopHint as WatchUi.Bitmap?;
    private var _rightBottomHint as WatchUi.Bitmap?;

    function initialize(quest as Quest, isOffer as Boolean) {
        View.initialize();
        _quest = quest;
        _isOffer = isOffer;
        _bgBitmap = WatchUi.loadResource($.Rez.Drawables.questBackground) as BitmapReference;
        _small_font = WatchUi.loadResource($.Rez.Fonts.small) as FontResource;
        if (_isOffer) {
            _rightTopHint = $.HintHelper.createRightTopHint($.Rez.Drawables.rightTopAccept);
            _rightBottomHint = $.HintHelper.createRightBottomHint($.Rez.Drawables.rightBottomCancel);
        }
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var W = dc.getWidth();
        var H = dc.getHeight();
        var ref = W < H ? W : H;
        var bgX = (W - ref) / 2;
        var bgY = (H - ref) / 2;

        dc.drawScaledBitmap(bgX, bgY, ref, ref, _bgBitmap);

        drawQuestName(dc, bgX, bgY, ref);
        drawDetails(dc, bgX, bgY, ref);
        drawDescription(dc, bgX, bgY, ref);

        if (_rightTopHint != null) {
            (_rightTopHint as WatchUi.Bitmap).draw(dc);
        }
        if (_rightBottomHint != null) {
            (_rightBottomHint as WatchUi.Bitmap).draw(dc);
        }
    }

    private function drawQuestName(dc as Dc, bgX as Number, bgY as Number, ref as Number) as Void {
        var x = (bgX + ref * 234 / 360).toNumber();
        var y = (bgY + ref * 103 / 360).toNumber();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, _small_font, _quest.getTitle(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawDetails(dc as Dc, bgX as Number, bgY as Number, ref as Number) as Void {
        var value_x = (bgX + ref * 220 / 360).toNumber();
        var y_start = (bgY + ref * 125 / 360).toNumber();
        var row_dist = (ref * 18 / 360).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(value_x, y_start, _small_font, getTypeLabel(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(value_x, y_start + row_dist, _small_font, _quest.target.format("%.0f"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(_quest.completed ? Graphics.COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(value_x, y_start + row_dist * 2, _small_font, _quest.getProgressLabel(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
        dc.drawText(value_x, y_start + row_dist * 3, _small_font, _quest.reward_gold.format("%.0f"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(0x4488FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(value_x, y_start + row_dist * 4, _small_font, _quest.reward_exp.format("%.0f"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawDescription(dc as Dc, bgX as Number, bgY as Number, ref as Number) as Void {
        if (_quest.description.length() == 0) {
            return;
        }
        var x = (bgX + ref / 2).toNumber();
        var y = (bgY + ref * 264 / 360).toNumber();
        var area_w = (ref * 245 / 360).toNumber();
        var area_h = (ref * 60 / 360).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var formatted = Graphics.fitTextToArea(_quest.description, _small_font, area_w, area_h, true);
        dc.drawText(x, y, _small_font, formatted, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function getTypeLabel() as String {
        switch (_quest.type) {
            case KILL_ENEMIES:
                return "Kill";
            case DEAL_DAMAGE:
                return "Damage";
            case TAKE_DAMAGE:
                return "Endure";
            case RUN_MINUTES:
                return "Run";
            case WALK_STAIRS:
                return "Climb";
            case BIKE_DISTANCE:
                return "Bike";
            case WALK_STEPS:
                return "Walk";
        }
        return "Quest";
    }
}
