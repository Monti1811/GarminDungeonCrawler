import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsAttributesView extends WatchUi.View {
	
	private var _player as Player;

	private const x_axis as Number = 85;
	private const value_x_axis as Number = 240;

	private const minus_x_axis as Number = 205;
	private const plus_x_axis as Number = 275;

	private const rectangle_x as Number = 75;
	private const rectangle_y as Number = 75;
	private const rectangle_width as Number = 210;
	private const tableentry_size as Number = 30;

	private var actionMenuHint as Bitmap?;
	private var accept as Bitmap?;
	private var cancel as Bitmap?;
	
	function initialize(player as Player, withHint as Boolean, creation as Boolean) {
		View.initialize();
		_player = player;
		if (withHint) {
			actionMenuHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.actionMenu, :locX=>-30, :locY=>290});
		}
		if (creation) {
			accept = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTopAccept, :locX=>300, :locY=>60});
			cancel = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightBottomCancel, :locX=>290, :locY=>220});
		}
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
		drawTable(dc);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		drawEntries(dc);
		//drawPlusMinus(dc);
		if (actionMenuHint != null) {
			actionMenuHint.draw(dc);
		}	
		if (accept != null) {
			accept.draw(dc);
			cancel.draw(dc);
		}
	}

	function drawTable(dc as Dc) as Void {
		dc.drawText(180, 50, Graphics.FONT_TINY, "Attributes (" + _player.getAttributePoints() + ")", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawRectangle(rectangle_x, rectangle_y, rectangle_width, rectangle_width);
		for (var i = rectangle_x + tableentry_size; i < rectangle_x + rectangle_width; i += tableentry_size) {
			dc.drawLine(rectangle_x, i, rectangle_x + rectangle_width, i);
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