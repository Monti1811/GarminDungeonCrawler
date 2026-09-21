import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsAttributesView extends WatchUi.View {
	
	private var _player as Player;
	private var _bg as BitmapReference?;

	private var _title_x as Number = 0;
	private var _title_y as Number = 0;
	private var _bar_x as Number = 0;
	private var _bar_max_width as Number = 0;
	private var _bar_height as Number = 0;
	private var _value_x as Number = 0;
	private var _row_top as Number = 0;
	private var _row_spacing as Number = 0;
	private var _row_height as Number = 0;

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

	private static var ATTR_KEYS as Array<Symbol> = [
		:strength, :constitution, :dexterity, :intelligence, :wisdom, :charisma, :luck
	] as Array<Symbol>;
	
	function initialize(player as Player, withHint as Boolean, creation as Boolean) {
		View.initialize();
		_player = player;
		
		_bg = WatchUi.loadResource($.Rez.Drawables.characterAttributes) as BitmapReference?;

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

		var W = dc.getWidth();
		var H = dc.getHeight();
		var ref = W < H ? W : H;
		var bgX = (W - ref) / 2;
		var bgY = (H - ref) / 2;

		// Draw background centered
		if (_bg != null) {
			dc.drawScaledBitmap(bgX, bgY, ref, ref, _bg as BitmapReference);
		}

		// Draw hints
		if (_rightTopHint != null) {
			_rightTopHint.draw(dc);
		}
		if (_rightBottomHint != null) {
			_rightBottomHint.draw(dc);
		}

		// Proportional positions relative to ref (centered background)
		_title_x = (W / 2).toNumber();
		_title_y = (bgY + ref * 78 / 360).toNumber();
		_row_top = (bgY + ref * 98 / 360).toNumber();
		_row_spacing = (ref * 28 / 360).toNumber();
		_row_height = (ref * 15 / 360).toNumber();
		_bar_x = (bgX + ref * 135 / 360).toNumber();
		_bar_max_width = (ref * 115 / 360).toNumber();
		_bar_height = (_row_height * 10 / 28).toNumber();
		_value_x = (bgX + ref * 287 / 360).toNumber();

		// Title
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(_title_x, _title_y, Graphics.FONT_XTINY, "Attributes (" + _player.getAttributePoints() + ")", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		drawBars(dc);
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

		var half_bar = _bar_height / 2;

		for (var i = 0; i < 7; i++) {
			var val = _player.getAttribute(ATTR_KEYS[i]) as Number;
			var center_y = _row_top + i * _row_spacing + _row_height / 2;

			// Bar fill
			if (max_val > 0) {
				var bar_width = (val * _bar_max_width / max_val).toNumber();
				if (bar_width < 2) {
					bar_width = 2;
				}
				dc.setColor(ATTR_COLORS[i], Graphics.COLOR_TRANSPARENT);
				dc.fillRectangle(_bar_x, center_y - half_bar, bar_width, _bar_height);
			}

			// Value
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(_value_x, center_y, Graphics.FONT_XTINY, val, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}
	
}
