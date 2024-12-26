import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsEquipmentsView extends WatchUi.View {
	
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
		dc.drawText(180, 180, Graphics.FONT_MEDIUM, _player.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	
}