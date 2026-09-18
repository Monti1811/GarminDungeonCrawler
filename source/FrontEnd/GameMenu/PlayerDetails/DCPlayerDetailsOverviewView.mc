import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsOverviewView extends WatchUi.View {

	private var _player as Player;
	private var _playerIcon as BitmapReference;
	private var _bgBitmap as BitmapReference;
	private var _statsOverlay as BitmapReference?;
	private var _small_font as FontResource;
	private var _rightTopHint as WatchUi.Bitmap?;
	private var _rightBottomHint as WatchUi.Bitmap?;

	private var _hasMana as Boolean;

	function initialize(player as Player, creation as Boolean) {
		View.initialize();
		_player = player;
		_playerIcon = WatchUi.loadResource(_player.getSprite());
		_bgBitmap = WatchUi.loadResource($.Rez.Drawables.characterInfoRoundNoStats) as BitmapReference;
		_hasMana = _player.second_bar == :mana;
		if (_hasMana) {
			_statsOverlay = WatchUi.loadResource($.Rez.Drawables.characterInfoStatsMana) as BitmapReference;
		} else {
			_statsOverlay = WatchUi.loadResource($.Rez.Drawables.characterInfoStatsNoMana) as BitmapReference;
		}
		_small_font = WatchUi.loadResource($.Rez.Fonts.small) as FontResource;
		if (creation) {
			_rightTopHint = $.HintHelper.createRightTopHint($.Rez.Drawables.rightTopAccept);
			_rightBottomHint = $.HintHelper.createRightBottomHint($.Rez.Drawables.rightBottomCancel);
		}
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();

		dc.drawBitmap((dc.getWidth() - _bgBitmap.getWidth()) / 2, (dc.getHeight() - _bgBitmap.getHeight()) / 2, _bgBitmap);

		if (_statsOverlay != null) {
			dc.drawBitmap(
				(Constants.SCREEN_WIDTH * 169 / 360).toNumber(),
				(Constants.SCREEN_HEIGHT * 104 / 360).toNumber(),
				_statsOverlay
			);
		}

		drawPlayerIcon(dc);
		drawPlayerName(dc);
		drawStats(dc);
		drawStatus(dc);

		if (_rightTopHint != null) {
			_rightTopHint.draw(dc);
		}
		if (_rightBottomHint != null) {
			_rightBottomHint.draw(dc);
		}
	}

	function drawPlayerIcon(dc) {
		var x = (Constants.SCREEN_WIDTH * 70 / 360).toNumber();
		var y = (Constants.SCREEN_HEIGHT * 125 / 360).toNumber();
		var size = (Constants.SCREEN_WIDTH * 64 / 360).toNumber();
		dc.drawScaledBitmap(x, y, size, size, _playerIcon);
	}

	function drawPlayerName(dc) {
		var text_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var name_y = (Constants.SCREEN_HEIGHT * 78 / 360).toNumber();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(text_x, name_y, Graphics.FONT_TINY, _player.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function drawStats(dc) {
		var x_val = (Constants.SCREEN_WIDTH * 330 / 360).toNumber();
		var y_start = (Constants.SCREEN_HEIGHT * 112 / 360).toNumber();
		var row_dist = (Constants.SCREEN_HEIGHT * 20 / 360).toNumber();

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

		// LVL
		dc.drawText(x_val, y_start, _small_font, "" + _player.getLevel(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// EXP
		dc.drawText(x_val, y_start + row_dist, _small_font, _player.getExperience().format("%.0f") + "/" + _player.getNextLevelExperience(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// HP
		dc.drawText(x_val, y_start + row_dist * 2, _small_font, _player.getHealth() + "/" + _player.getMaxHealth(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// ATK
		dc.drawText(x_val, y_start + row_dist * 3, _small_font, _player.getAttack(null).toString(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// DEF
		dc.drawText(x_val, y_start + row_dist * 4, _small_font, _player.getDefense(null).toString(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// MANA
		if (_hasMana) {
			dc.drawText(x_val, y_start + row_dist * 5, _small_font, _player.getCurrentMana() + "/" + _player.getMaxMana(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		}

		// GOLD
		dc.drawText(x_val, y_start + row_dist * (_hasMana ? 6 : 5), _small_font, _player.getGold().format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function drawStatus(dc) {
		var text_x = (Constants.SCREEN_WIDTH / 2 + (Constants.SCREEN_WIDTH * 15 / 360)).toNumber();
		var status_y = (Constants.SCREEN_HEIGHT * 297 / 360).toNumber();

		var status_text = "Ready for adventure.";
		if (_player.getHealth() <= 0) {
			status_text = "Fallen in battle.";
		} else if (_player.getHealth() < _player.getMaxHealth() * 0.25) {
			status_text = "Critical condition!";
		} else if (_player.getHealth() < _player.getMaxHealth() * 0.5) {
			status_text = "Wounded but standing.";
		}

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(text_x, status_y, _small_font, status_text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

}
