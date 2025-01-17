import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

class DCCostDrawable extends WatchUi.Drawable {
	private var _cost as Number;
	private var _font as FontDefinition;
	private var _amount as Number;

	function initialize(cost as Number, font as FontDefinition, amount as Number) {
		Drawable.initialize({});
		_cost = cost;
		_font = font;
		_amount = amount;
	}

	function draw(dc as Dc) as Void {
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
		dc.clear();

		var amount_text = _amount.format("Amount: %d");
		var cost_text = _cost.format("Cost: %d");
		var font_height = dc.getFontHeight(_font) / 2;
		dc.drawText(dc.getHeight() / 2, dc.getWidth() / 2 - font_height, _font, amount_text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(dc.getHeight() / 2, dc.getWidth() / 2 + font_height, _font, cost_text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}
}