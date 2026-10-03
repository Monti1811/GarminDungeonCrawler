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

	private var _hasSecondBar as Boolean;
	private var _barLabelBitmap as BitmapReference?;
	private var _ref as Number;
	private var _bgX as Number;
	private var _bgY as Number;

	function initialize(player as Player, creation as Boolean) {
		View.initialize();
		_player = player;
		_playerIcon = WatchUi.loadResource(_player.getSprite());
		_bgBitmap = WatchUi.loadResource($.Rez.Drawables.characterInfoRoundNoStats) as BitmapReference;
		_hasSecondBar = _player.second_bar != null;
		_barLabelBitmap = null;
		if (!_hasSecondBar) {
			_statsOverlay = WatchUi.loadResource($.Rez.Drawables.characterInfoStatsNoMana) as BitmapReference;
		} else {
			// Strip with an empty row 4 - the matching bar label bitmap is drawn on top
			_statsOverlay = WatchUi.loadResource($.Rez.Drawables.characterInfoStatsBar) as BitmapReference;
			_barLabelBitmap = WatchUi.loadResource(getSecondBarLabelId()) as BitmapReference;
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

	function getSecondBarLabelId() as ResourceId {
		if (_player.hasSecondBarResource(:rage)) {
			return $.Rez.Drawables.characterInfoLabelRage;
		}
		if (_player.hasSecondBarResource(:energy)) {
			return $.Rez.Drawables.characterInfoLabelEnergy;
		}
		if (_player.hasSecondBarResource(:heat)) {
			return $.Rez.Drawables.characterInfoLabelHeat;
		}
		return $.Rez.Drawables.characterInfoLabelMana;
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();

		DrawUtil.drawScaledBitmap(dc, _bgX, _bgY, _ref, _ref, _bgBitmap);

		if (_statsOverlay != null) {
			var overlay_x = (_bgX + _ref * 169 / 360).toNumber();
			var overlay_y = (_bgY + _ref * 104 / 360).toNumber();
			var overlay_w = (_statsOverlay.getWidth() * _ref / 360).toNumber();
			var overlay_h = (_statsOverlay.getHeight() * _ref / 360).toNumber();
			DrawUtil.drawScaledBitmap(dc, overlay_x, overlay_y, overlay_w, overlay_h, _statsOverlay);
			if (_barLabelBitmap != null) {
				// Row 4 of the strip starts at y=60 in strip coordinates (scale = _ref / 360)
				var label_y = overlay_y + (_ref * 60 / 360).toNumber();
				var label_h = (_ref * 20 / 360).toNumber();
				DrawUtil.drawScaledBitmap(dc, overlay_x, label_y, overlay_w, label_h, _barLabelBitmap);
			}
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
		DrawUtil.drawScaledBitmap(dc, x, y, size, size, _playerIcon);
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

		// SECOND BAR
		if (_hasSecondBar) {
			dc.drawText(x_val, y_start + row_dist * (counter + 3), _small_font, _player.getCurrentSecondBar() + "/" + _player.getMaxSecondBar(), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
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
