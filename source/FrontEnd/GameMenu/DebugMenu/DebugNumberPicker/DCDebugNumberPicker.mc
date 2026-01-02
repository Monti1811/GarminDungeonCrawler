import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

(:debug)
class DCDebugNumberPicker extends WatchUi.Picker {

    function initialize(label as String, start as Number, stop as Number, increment as Number, current as Number) {
        var title = new WatchUi.Text({:text=>label, :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factory = new DCDebugNumberFactory(label, start, stop, increment, Graphics.FONT_SMALL);
        var index = factory.getIndex(current);
        Picker.initialize({:title=>title, :pattern=>[factory], :index=>index});
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}