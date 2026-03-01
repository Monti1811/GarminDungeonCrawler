import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsAttributesView extends WatchUi.View {
	
	private var _player as Player;

	private var x_axis as Number;
	private var value_x_axis as Number;

	private var minus_x_axis as Number;
	private var plus_x_axis as Number;

	private var rectangle_x as Number;
	private var rectangle_y as Number;
	private var rectangle_width as Number;
	private var tableentry_size as Number;

	private var layout_type as Number = 0;
	
	function initialize(player as Player, withHint as Boolean, creation as Boolean) {
		View.initialize();
		_player = player;
		
		// Calculate dynamic positions based on screen size
		x_axis = (Constants.SCREEN_WIDTH * 85 / 360).toNumber();
		value_x_axis = (Constants.SCREEN_WIDTH * 240 / 360).toNumber();
		minus_x_axis = (Constants.SCREEN_WIDTH * 205 / 360).toNumber();
		plus_x_axis = (Constants.SCREEN_WIDTH * 275 / 360).toNumber();
		rectangle_x = (Constants.SCREEN_WIDTH * 75 / 360).toNumber();
		rectangle_y = (Constants.SCREEN_HEIGHT * 75 / 360).toNumber();
		rectangle_width = (Constants.SCREEN_WIDTH * 210 / 360).toNumber();
		tableentry_size = (Constants.SCREEN_HEIGHT * 30 / 360).toNumber();
		
		if (withHint) {
			layout_type = 1;
		}
		if (creation) {
			layout_type = 2;
		}
	}

	function onLayout(dc as Dc) as Void {
		if (layout_type == 1) {
			setLayout($.Rez.Layouts.DCAttributesViewHint(dc));
		} else if (layout_type == 2) {
			setLayout($.Rez.Layouts.DCPlayerDetailsEquipmentsViewCreation(dc));
		}
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

		// Draw layout (includes hints)
		View.onUpdate(dc);

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		drawTable(dc);
		drawEntries(dc);
		//drawPlusMinus(dc);
	}

	function drawTable(dc as Dc) as Void {
		var title_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var title_y = (Constants.SCREEN_HEIGHT * 50 / 360).toNumber();
		dc.drawText(title_x, title_y, Graphics.FONT_TINY, "Attributes (" + _player.getAttributePoints() + ")", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawRectangle(rectangle_x, rectangle_y, rectangle_width, rectangle_width);
		for (var i = 1; i < 7; i += 1) {
			var y = rectangle_x + i * tableentry_size;
			dc.drawLine(rectangle_x, y, rectangle_x + rectangle_width, y);
		}
	}

	function drawEntries(dc as Dc) as Void {
		dc.drawText(x_axis, rectangle_x + tableentry_size/2, Graphics.FONT_XTINY, "Strength", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(x_axis, rectangle_x + 3 * tableentry_size/2, Graphics.FONT_XTINY, "Constitution", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(x_axis, rectangle_x + 5 * tableentry_size/2, Graphics.FONT_XTINY, "Dexterity", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(x_axis, rectangle_x + 7 * tableentry_size/2, Graphics.FONT_XTINY, "Intelligence", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(x_axis, rectangle_x + 9 * tableentry_size/2, Graphics.FONT_XTINY, "Wisdom", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(x_axis, rectangle_x + 11 * tableentry_size/2, Graphics.FONT_XTINY, "Charisma", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(x_axis, rectangle_x + 13 * tableentry_size/2, Graphics.FONT_XTINY, "Luck", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

		dc.drawText(value_x_axis, rectangle_x + tableentry_size/2, Graphics.FONT_XTINY, _player.getAttribute(:strength), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x_axis, rectangle_x + 3 * tableentry_size/2, Graphics.FONT_XTINY, _player.getAttribute(:constitution), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x_axis, rectangle_x + 5 * tableentry_size/2, Graphics.FONT_XTINY, _player.getAttribute(:dexterity), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x_axis, rectangle_x + 7 * tableentry_size/2, Graphics.FONT_XTINY, _player.getAttribute(:intelligence), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x_axis, rectangle_x + 9 * tableentry_size/2, Graphics.FONT_XTINY, _player.getAttribute(:wisdom), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x_axis, rectangle_x + 11 * tableentry_size/2, Graphics.FONT_XTINY, _player.getAttribute(:charisma), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x_axis, rectangle_x + 13 * tableentry_size/2, Graphics.FONT_XTINY, _player.getAttribute(:luck), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

	}

	function drawPlusMinus(dc as Dc) as Void {
		for (var i = rectangle_x + tableentry_size/2; i < rectangle_x + rectangle_width; i += tableentry_size) {
			dc.drawText(minus_x_axis, i, Graphics.FONT_XTINY, "-", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(plus_x_axis, i, Graphics.FONT_XTINY, "+", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}

	
}