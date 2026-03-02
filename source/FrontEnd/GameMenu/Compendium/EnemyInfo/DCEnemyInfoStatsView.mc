import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCEnemyInfoStatsView extends WatchUi.View {

	private var _enemy as Enemy;
	private const distance_lines as Number = 35;

    function initialize(enemy as Enemy) {
		View.initialize();
		_enemy = enemy;
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();

		var actions_per_turn = (_enemy.energy_per_turn.toFloat()/$.Constants.MIN_ENERGY_PER_TURN.toFloat()).format("%.2f");
		
		drawStat(dc, "Health", ": " + _enemy.maxHealth, 0);
		drawStat(dc, "Damage", ": " + _enemy.damage, 1);
		drawStat(dc, "Armor", ": " + _enemy.armor, 2);
		drawStat(dc, "XP", ": " + _enemy.getKillExperience(), 3);
		drawStat(dc, "Action/Turn", ": " + actions_per_turn, 4);
	}

	function drawStat(dc, label, value, counter) as Void {
		var label_x = (Constants.SCREEN_WIDTH * 80 / 360).toNumber();
		var value_x = (Constants.SCREEN_WIDTH * 190 / 360).toNumber();
		var base_y = (Constants.SCREEN_HEIGHT * 70 / 360).toNumber();
		var line_distance = (Constants.SCREEN_HEIGHT * distance_lines / 360).toNumber();
		dc.drawText(label_x, base_y + line_distance * counter, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(value_x, base_y + line_distance * counter, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_LEFT);
	}
}
