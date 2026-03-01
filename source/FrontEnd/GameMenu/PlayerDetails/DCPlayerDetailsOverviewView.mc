import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsOverviewView extends WatchUi.View {
	
	private var _player as Player;
	private var _playerIcon as BitmapReference;

	private var x_axis as Number;
	private var y_axis as Number;
	private var space_between as Number;

	private var _font as FontReference | FontDefinition;

	private var layout_type as Number = 0;
	
	function initialize(player as Player, creation as Boolean) {
		View.initialize();
		_player = player;
		_playerIcon = WatchUi.loadResource(_player.getSprite());
		_font = Graphics.FONT_XTINY; //WatchUi.loadResource($.Rez.Fonts.small);
		x_axis = (Constants.SCREEN_WIDTH * 160 / 360).toNumber();
		y_axis = (Constants.SCREEN_HEIGHT * 90 / 360).toNumber();
		space_between = (Constants.SCREEN_HEIGHT * 25 / 360).toNumber();
		if (creation) {
			layout_type = 1;
		}
	}

	function onLayout(dc) {
		if (self.layout_type == 1) {
			setLayout(Rez.Layouts.DCPlayerDetailsEquipmentsViewHint(dc));
		}
	}

	
	
	function drawTextPair(dc, left_text_x, right_text_x, y, label, value) {
		dc.drawText(left_text_x, y, _font, label, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(right_text_x, y, _font, ": " + value, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();
		// Update layout
		View.onUpdate(dc);

		var icon_x = (Constants.SCREEN_WIDTH * 50 / 360).toNumber();
		var icon_y = (Constants.SCREEN_HEIGHT * 150 / 360).toNumber();
		var icon_size = (Constants.SCREEN_WIDTH * 60 / 360).toNumber();
		var name_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		dc.drawScaledBitmap(icon_x, icon_y, icon_size, icon_size, _playerIcon);
		dc.drawText(name_x, y_axis, Graphics.FONT_MEDIUM, _player.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);R);
		var left_text_x = x_axis;
		var right_text_x = x_axis + (Constants.SCREEN_WIDTH * 60 / 360).toNumber(); // Adjust this value as needed for spacing


		var size = _player.second_bar == :mana ? 7 : 6;
		var text_pairs = new Array<Dictionary<Symbol, String | Number>>[size]; /* as Array<Dictionary<Symbol, String or Number>> */ 
		text_pairs[0] = { :label => "LVL", :value => _player.getLevel().toString() };
		text_pairs[1] = { :label => "EXP", :value => _player.getExperience().format("%.0f") + "/" + _player.getNextLevelExperience() };
		text_pairs[2] =	{ :label => "HP", :value => _player.getHealth() + "/" + _player.getMaxHealth() };
		
		var index = 2;
		if (_player.second_bar == :mana) {
			index += 1;
			text_pairs[index] = { :label => "MP", :value => _player.getCurrentMana() + "/" + _player.getMaxMana() };
		}
		text_pairs[index + 1] = { :label => "ATK", :value => _player.getAttack(null).toString() };
		text_pairs[index + 2] = { :label => "DEF", :value => _player.getDefense(null).toString() };
		text_pairs[index + 3] = { :label => "GOLD", :value => _player.getGold().format("%.0f") };

		for (var i = 0; i < size; i++) {
			drawTextPair(dc, left_text_x, right_text_x, y_axis + 60 + i * space_between, text_pairs[i][:label], text_pairs[i][:value]);
		}
	}

	
}