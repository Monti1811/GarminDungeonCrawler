import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCEnemyInfoOverviewView extends WatchUi.View {
	
	private var _enemy as Enemy;
	private var _enemyIcon as BitmapReference;
	
	function initialize(enemy as Enemy) {
		View.initialize();
		_enemy = enemy;
		_enemyIcon = WatchUi.loadResource(_enemy.getSprite());
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
		dc.drawScaledBitmap(150, 90, 60, 60, _enemyIcon);
		var formatted_text = Graphics.fitTextToArea(_enemy.getName(), Graphics.FONT_MEDIUM, 260, 150, false);
		dc.drawText(180, 160, Graphics.FONT_MEDIUM, formatted_text, Graphics.TEXT_JUSTIFY_CENTER);
	}
	
}
