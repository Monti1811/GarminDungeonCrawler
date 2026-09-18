import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCEnemyInfoStatsView extends WatchUi.View {

	private var _enemy as Enemy;
	private var _enemyIcon as BitmapReference;
	private var _bgBitmap as BitmapReference;
	private var _small_font as FontResource;

    function initialize(enemy as Enemy) {
		View.initialize();
		_enemy = enemy;
		_enemyIcon = WatchUi.loadResource(_enemy.getSprite()) as BitmapReference;
		_bgBitmap = WatchUi.loadResource($.Rez.Drawables.enemyInfoStatsRound) as BitmapReference;
		_small_font = WatchUi.loadResource($.Rez.Fonts.small) as FontResource;
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();

		dc.drawScaledBitmap(0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, _bgBitmap);

		drawEnemyName(dc);
		drawEnemyIcon(dc);
		drawStats(dc);
		drawDescription(dc);
	}

	function drawEnemyName(dc) {
		var text_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var name_y = (Constants.SCREEN_HEIGHT * 78 / 360).toNumber();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(text_x, name_y, Graphics.FONT_TINY, _enemy.name, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function drawEnemyIcon(dc) {
		var x = (Constants.SCREEN_WIDTH * 70 / 360).toNumber();
		var y = (Constants.SCREEN_HEIGHT * 128 / 360).toNumber();
		var size = (Constants.SCREEN_WIDTH * 64 / 360).toNumber();
		dc.drawScaledBitmap(x, y, size, size, _enemyIcon);
	}

	function drawStats(dc) {
		var value_x = (Constants.SCREEN_WIDTH * 285 / 360).toNumber();
		var y_start = (Constants.SCREEN_HEIGHT * 113 / 360).toNumber();
		var row_dist = (Constants.SCREEN_HEIGHT * 24 / 360).toNumber();

		var actions_per_turn = (_enemy.energy_per_turn.toFloat() / $.Constants.MIN_ENERGY_PER_TURN.toFloat()).format("%.1f");

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

		dc.drawText(value_x, y_start, _small_font, "" + _enemy.maxHealth, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x, y_start + row_dist, _small_font, "" + _enemy.damage, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x, y_start + row_dist * 2, _small_font, "" + _enemy.armor, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x, y_start + row_dist * 3, _small_font, "" + _enemy.getKillExperience(), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(value_x, y_start + row_dist * 4, _small_font, "" + actions_per_turn, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function drawDescription(dc) {
		if (_enemy.description.length() == 0) {
			return;
		}
		var text_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var desc_y = (Constants.SCREEN_HEIGHT * 290 / 360).toNumber();
		var area_w = (Constants.SCREEN_WIDTH * 160 / 360).toNumber();
		var area_h = (Constants.SCREEN_HEIGHT * 60 / 360).toNumber();

		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		var formatted = Graphics.fitTextToArea(_enemy.description, _small_font, area_w, area_h, false);
		dc.drawText(text_x, desc_y, _small_font, formatted, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}
}
