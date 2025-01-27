import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsOverviewView extends WatchUi.View {
	
	private var _player as Player;
	private var _playerIcon as BitmapReference;

	private const x_axis as Number = 160;
	private const y_axis as Number = 90;
	private const space_between as Number = 25;

	private var _font as FontReference | FontDefinition;

	private var accept as Bitmap?;
	private var cancel as Bitmap?;
	
	function initialize(player as Player, creation as Boolean) {
		View.initialize();
		_player = player;
		_playerIcon = WatchUi.loadResource(_player.getSprite());
		_font = Graphics.FONT_XTINY; //WatchUi.loadResource($.Rez.Fonts.small);
		if (creation) {
			accept = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTopAccept, :locX=>300, :locY=>60});
			cancel = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightBottomCancel, :locX=>290, :locY=>220});
		}
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();
		if (accept != null) {
			accept.draw(dc);
			cancel.draw(dc);
		}
		dc.drawScaledBitmap(50, 150, 60, 60, _playerIcon);
		dc.drawText(180, y_axis, Graphics.FONT_MEDIUM, _player.getName(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		var left_text_x = x_axis;
		var right_text_x = x_axis + 60; // Adjust this value as needed for spacing

		// Current level
		dc.drawText(left_text_x, y_axis + 60, _font, "LVL", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(right_text_x, y_axis + 60, _font, ": " + _player.getLevel().toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

		// Current experience
		dc.drawText(left_text_x, y_axis + 60 + space_between, _font, "EXP", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(right_text_x, y_axis + 60 + space_between, _font, ": " + _player.getExperience() + "/" + _player.getNextLevelExperience(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

		// Current health
		dc.drawText(left_text_x, y_axis + 60 + 2 * space_between, _font, "HP", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(right_text_x, y_axis + 60 + 2 * space_between, _font, ": " + _player.getHealth() + "/" + _player.getMaxHealth(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

		// Current attack
		dc.drawText(left_text_x, y_axis + 60 + 3 * space_between, _font, "ATK", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(right_text_x, y_axis + 60 + 3 * space_between, _font, ": " + _player.getAttack(null).toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

		// Current defense
		dc.drawText(left_text_x, y_axis + 60 + 4 * space_between, _font, "DEF", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(right_text_x, y_axis + 60 + 4 * space_between, _font, ": " + _player.getDefense(null).toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

		// Current gold
		dc.drawText(left_text_x, y_axis + 60 + 5 * space_between, _font, "GOLD", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(right_text_x, y_axis + 60 + 5 * space_between, _font, ": " + _player.getGold().toString(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	
}