import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

(:debug)
class DCDebugNumberFactory extends WatchUi.PickerFactory {

    private var _start as Number;
    private var _stop as Number;
    private var _increment as Number;
    private var _label as String;
    private var _font as FontDefinition;

    function initialize(label as String, start as Number, stop as Number, increment as Number, font as FontDefinition) {
        PickerFactory.initialize();
        _label = label;
        _start = start;
        _stop = stop;
        _increment = increment;
        _font = font;
    }

    function getIndex(value as Number) as Number {
        var clamped = $.MathUtil.clamp(value, _start, _stop);
        return Math.floor((clamped - _start) / _increment);
    }

    function getDrawable(index as Number, selected as Boolean) as Drawable? {
        var value = getValue(index) as Number;
        return new DCDebugNumberDrawable(_label, value, _font);
    }

    function getValue(index as Number) as Object? {
        return _start + (index * _increment);
    }

    function getSize() as Number {
        return ((_stop - _start) / _increment) + 1;
    }
}
