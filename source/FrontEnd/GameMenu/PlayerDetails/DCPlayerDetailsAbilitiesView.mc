import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

// 4. Seite des CharacterInfo-Loops: Kurz-Ueberblick ueber die Klasse,
// die zweite Bar (was sie ist und was sie bringt) und die Kernfaehigkeit
class DCPlayerDetailsAbilitiesView extends WatchUi.View {

	private const GOLD_COLOR = 0xFFD700;

	private var _player as Player;
	private var _small_font as FontResource;

	function initialize(player as Player) {
		View.initialize();
		_player = player;
		_small_font = WatchUi.loadResource($.Rez.Fonts.small) as FontResource;
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();

		var center_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var screen_h = Constants.SCREEN_HEIGHT;

		// Titel: Klassen-Beschreibung (ganz oben, schmale Flaeche wegen rundem Screen)
		var title_w = (Constants.SCREEN_WIDTH * 250 / 360).toNumber();
		var title_y = (screen_h * 56 / 360).toNumber();
		var title_h = (screen_h * 36 / 360).toNumber();
		var title = Graphics.fitTextToArea(_player.getDescription(), _small_font, title_w, title_h, true);
		dc.setColor(GOLD_COLOR, Graphics.COLOR_TRANSPARENT);
		dc.drawText(center_x, title_y, _small_font, title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		// Name und Farbe der zweiten Bar - deutlich oberhalb des Fliesstextes
		if (_player.second_bar != null) {
			var bar_y = (screen_h * 98 / 360).toNumber();
			dc.setColor(_player.getSecondBarColor(), Graphics.COLOR_TRANSPARENT);
			dc.drawText(center_x, bar_y, _small_font, "Second bar: " + _player.getSecondBarName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}

		// Faehigkeiten-Text
		var body_w = (Constants.SCREEN_WIDTH * 280 / 360).toNumber();
		var body_y = (screen_h * 212 / 360).toNumber();
		var body_h = (screen_h * 168 / 360).toNumber();
		var body = Graphics.fitTextToArea(_player.getAbilityText(), _small_font, body_w, body_h, true);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(center_x, body_y, _small_font, body, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}

}
