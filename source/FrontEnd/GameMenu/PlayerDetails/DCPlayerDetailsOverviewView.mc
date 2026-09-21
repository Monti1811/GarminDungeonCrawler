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
	private var _ref as Number;
	private var _bgX as Number;
	private var _bgY as Number;

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
		_ref = Constants.SCREEN_WIDTH < Constants.SCREEN_HEIGHT ? Constants.SCREEN_WIDTH : Constants.SCREEN_HEIGHT;
		_bgX = ((Constants.SCREEN_WIDTH - _ref) / 2).toNumber();
		_bgY = ((Constants.SCREEN_HEIGHT - _ref) / 2).toNumber();
		if (creation) {
			_rightTopHint = $.HintHelper.createRightTopHint($.Rez.Drawables.rightTopAccept);
			_rightBottomHint = $.HintHelper.createRightBottomHint($.Rez.Drawables.rightBottomCancel);
		}
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();

		dc.drawScaledBitmap(_bgX, _bgY, _ref, _ref, _bgBitmap);

		if (_statsOverlay != null) {
			var overlay_x = (_bgX + _ref * 169 / 360).toNumber();
			var overlay_y = (_bgY + _ref * 104 / 360).toNumber();
			var overlay_w = (_statsOverlay.getWidth() * _ref / 360).toNumber();
			var overlay_h = (_statsOverlay.getHeight() * _ref / 360).toNumber();
			dc.drawScaledBitmap(overlay_x, overlay_y, overlay_w, overlay_h, _statsOverlay);
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
		var x = (_bgX + _ref * 70 / 360).toNumber();
		var y = (_bgY + _ref * 125 / 360).toNumber();
		var size = (_ref * 64 / 360).toNumber();
		dc.drawScaledBitmap(x, y, size, size, _playerIcon);
	}

	function drawPlayerName(dc) {
		var text_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var name_y = (_bgY + _ref * 78 / 360).toNumber();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(text_x, name_y, Graphics.FONT_TINY, _player.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function drawStats(dc) {
		var x_val = (_bgX + _ref * 330 / 360).toNumber();
		var y_start = (_bgY + _ref * 112 / 360).toNumber();
		var row_dist = (_ref * 20 / 360).toNumber();
		var counter = 0;

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

		// LVL
		dc.drawText(x_val, y_start, _small_font, "" + _player.getLevel(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// EXP
		dc.drawText(x_val, y_start + row_dist, _small_font, _player.getExperience().format("%.0f") + "/" + _player.getNextLevelExperience(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// HP
		dc.drawText(x_val, y_start + row_dist * (counter + 2), _small_font, _player.getHealth() + "/" + _player.getMaxHealth(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// MANA
		if (_hasMana) {
			dc.drawText(x_val, y_start + row_dist * (counter + 3), _small_font, _player.getCurrentMana() + "/" + _player.getMaxMana(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
			counter += 1;
		}

		// ATK
		dc.drawText(x_val, y_start + row_dist * (counter + 3), _small_font, _player.getAttack(null).toString(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

		// DEF
		dc.drawText(x_val, y_start + row_dist * (counter + 4), _small_font, _player.getDefense(null).toString(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);


		// GOLD
		dc.drawText(x_val, y_start + row_dist * (counter + 5), _small_font, _player.getGold().format("%.0f"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function drawStatus(dc) {
		var text_x = (Constants.SCREEN_WIDTH / 2 + (_ref * 15 / 360)).toNumber();
		var status_y = (_bgY + _ref * 297 / 360).toNumber();

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
