import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsOverviewView extends WatchUi.View {
	
	private var _player as Player;
	private var _playerIcon as BitmapReference;
	
	function initialize(player as Player) {
		View.initialize();
		_player = player;
		_playerIcon = WatchUi.loadResource(_player.getSprite());
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
		dc.drawScaledBitmap(60, 150, 60, 60, _playerIcon);
		dc.drawText(270, 120, Graphics.FONT_MEDIUM, _player.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// Current level
		dc.drawText(270, 180, Graphics.FONT_TINY, "Level: " + _player.getLevel(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		// Current experience
		dc.drawText(270, 210, Graphics.FONT_TINY, "Experience: " + _player.getExperience() + "/" + _player.getExperienceToNextLevel(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

	}

	
}