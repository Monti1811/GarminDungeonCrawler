import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsAttributesView extends WatchUi.View {
	
	private var _player as Player;

	private var label_x as Number;
	private var bar_x as Number;
	private var bar_max_width as Number;
	private var value_x as Number;

	private var rectangle_x as Number;
	private var rectangle_y as Number;
	private var rectangle_width as Number;
	private var tableentry_size as Number;
	private var _rightTopHint as WatchUi.Bitmap?;
	private var _rightBottomHint as WatchUi.Bitmap?;

	private static var ATTR_COLORS as Array<Number> = [
		0xFF4444, // STR - Red
		0xFF8C00, // CON - Orange
		0x44FF44, // DEX - Green
		0x4488FF, // INT - Blue
		0x44FFFF, // WIS - Cyan
		0xFF44FF, // CHA - Magenta
		0xFFFF44  // LCK - Yellow
	] as Array<Number>;

	private static var ATTR_LABELS as Array<String> = [
		"STR", "CON", "DEX", "INT", "WIS", "CHA", "LCK"
	] as Array<String>;

	private static var ATTR_KEYS as Array<Symbol> = [
		:strength, :constitution, :dexterity, :intelligence, :wisdom, :charisma, :luck
	] as Array<Symbol>;
	
	function initialize(player as Player, withHint as Boolean, creation as Boolean) {
		View.initialize();
		_player = player;
		
		// Original proportions: rectangle ~58% width, rows ~8% height
		rectangle_width = (Constants.SCREEN_WIDTH * 210 / 360).toNumber();
		rectangle_x = (Constants.SCREEN_WIDTH - rectangle_width) / 2;
		rectangle_y = (Constants.SCREEN_HEIGHT * 75 / 360).toNumber();
		tableentry_size = (Constants.SCREEN_HEIGHT * 30 / 360).toNumber();
		
		// Columns: label (25%), bar (55%), value (20%)
		label_x = rectangle_x + 6;
		bar_x = rectangle_x + (rectangle_width * 25 / 100).toNumber();
		bar_max_width = (rectangle_width * 55 / 100).toNumber();
		value_x = rectangle_x + rectangle_width - 6;
		
		if (withHint) {
			_rightTopHint = $.HintHelper.createRightTopHint($.Rez.Drawables.rightTop);
		}
		if (creation) {
			_rightTopHint = $.HintHelper.createRightTopHint($.Rez.Drawables.rightTopAccept);
			_rightBottomHint = $.HintHelper.createRightBottomHint($.Rez.Drawables.rightBottomCancel);
		}
	}
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

		// Draw hints
		if (_rightTopHint != null) {
			_rightTopHint.draw(dc);
		}
		if (_rightBottomHint != null) {
			_rightBottomHint.draw(dc);
		}

		drawTable(dc);
		drawBars(dc);
	}

	function drawTable(dc as Dc) as Void {
		var title_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var title_y = (Constants.SCREEN_HEIGHT * 50 / 360).toNumber();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(title_x, title_y, Graphics.FONT_TINY, "Attributes (" + _player.getAttributePoints() + ")", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawRectangle(rectangle_x, rectangle_y, rectangle_width, rectangle_width);
		for (var i = 1; i < 7; i += 1) {
			var y = rectangle_y + i * tableentry_size;
			dc.drawLine(rectangle_x, y, rectangle_x + rectangle_width, y);
		}
	}

	function drawBars(dc as Dc) as Void {
		// Find max value for proportional bars
		var max_val = 0;
		for (var i = 0; i < 7; i++) {
			var val = _player.getAttribute(ATTR_KEYS[i]) as Number;
			if (val > max_val) {
				max_val = val;
			}
		}

		for (var i = 0; i < 7; i++) {
			var val = _player.getAttribute(ATTR_KEYS[i]) as Number;
			var row_y = rectangle_y + i * tableentry_size;
			var center_y = row_y + tableentry_size / 2;

			// Label (white)
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(label_x, center_y, Graphics.FONT_XTINY, ATTR_LABELS[i], Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

			// Bar fill (bright)
			if (max_val > 0) {
				var bar_width = (val * bar_max_width / max_val).toNumber();
				if (bar_width < 2) {
					bar_width = 2;
				}
				dc.setColor(ATTR_COLORS[i], Graphics.COLOR_TRANSPARENT);
				dc.fillRectangle(bar_x, center_y - 5, bar_width, 10);
			}

			// Value (white)
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(value_x, center_y, Graphics.FONT_XTINY, val, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}
	
}