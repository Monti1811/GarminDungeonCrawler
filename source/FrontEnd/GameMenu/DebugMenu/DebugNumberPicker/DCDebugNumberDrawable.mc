import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

(:debug)
class DCDebugNumberDrawable extends WatchUi.Drawable {

    private var _label as String;
    private var _value as Number;
    private var _font as FontDefinition;

    function initialize(label as String, value as Number, font as FontDefinition) {
        Drawable.initialize({});
        _label = label;
        _value = value;
        _font = font;
    }

    function draw(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.clear();
        var value_text = _value.toString();
        var label_height = dc.getFontHeight(_font) / 2;
        dc.drawText(dc.getHeight() / 2, dc.getWidth() / 2 - label_height, _font, _label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dc.getHeight() / 2, dc.getWidth() / 2 + label_height, _font, value_text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
