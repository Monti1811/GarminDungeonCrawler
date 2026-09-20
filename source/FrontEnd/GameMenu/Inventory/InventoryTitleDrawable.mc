import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class InventoryTitleDrawable extends WatchUi.Drawable {

	private var _weight as Numeric;
	private var _maxWeight as Numeric;

	function initialize(weight as Numeric, maxWeight as Numeric) {
		Drawable.initialize({:identifier => "InventoryTitle"});
		_weight = weight;
		_maxWeight = maxWeight;
	}

	function draw(dc as Graphics.Dc) as Void {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();

		var w = dc.getWidth();
		var h = dc.getHeight();

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(w / 2, h * 20 / 100, Graphics.FONT_TINY, "Inventory", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		var weightStr = _weight.format("%.1f") + "/" + _maxWeight;
		var pct = _maxWeight > 0 ? _weight.toFloat() / _maxWeight.toFloat() : 0.0;
		if (pct < 0.75) {
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		} else if (pct < 0.95) {
			dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
		} else {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		}
		dc.drawText(w / 2, h * 65 / 100, Graphics.FONT_XTINY, weightStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}
}
