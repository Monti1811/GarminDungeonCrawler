import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsOverviewView extends WatchUi.View {
	
	private var _player as Player;
	private var _playerIcon as BitmapReference;

	private const x_axis as Number = 230;
	private const y_axis as Number = 90;
	
	function initialize(player as Player) {
		View.initialize();
		_player = player;
		_playerIcon = WatchUi.loadResource(_player.getSprite());
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
		dc.drawScaledBitmap(50, 150, 60, 60, _playerIcon);
		dc.drawText(180, y_axis, Graphics.FONT_MEDIUM, _player.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// Current level
		dc.drawText(x_axis, y_axis + 60, Graphics.FONT_TINY, "Level: " + _player.getLevel(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// Current experience
		dc.drawText(x_axis, y_axis + 90, Graphics.FONT_TINY, "Experience: " + _player.getExperience() + "/" + _player.getNextLevelExperience(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// Current health
		dc.drawText(x_axis, y_axis + 120, Graphics.FONT_TINY, "Health: " + _player.getHealth() + "/" + _player.getMaxHealth(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// Current attack
		dc.drawText(x_axis, y_axis + 150, Graphics.FONT_TINY, "Attack: " + _player.getAttack(null), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// Current defense
		dc.drawText(x_axis, y_axis + 180, Graphics.FONT_TINY, "Defense: " + _player.getDefense(null), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// Current gold
		dc.drawText(x_axis, y_axis + 210, Graphics.FONT_TINY, "Gold: " + _player.getGold(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

	}

	
}