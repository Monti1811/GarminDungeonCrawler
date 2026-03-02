import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;
import Rez.Styles;

class DCPlayerDetailsEquipmentsView extends WatchUi.View {
	
	private var _player as Player;
	private var size_rectangles as Number;
	private var small_font as FontResource;
	private var equipped_res as Dictionary<ItemSlot, BitmapReference?> = {};
	private const num_to_equipslot as Array<ItemSlot> = [HEAD, CHEST, BACK, LEGS, FEET, LEFT_HAND, RIGHT_HAND, ACCESSORY, AMMUNITION];

	private var layout_type as Number = 0;
	
	function initialize(player as Player, withHint as Boolean, creation as Boolean) {
		View.initialize();
		_player = player;
		small_font = WatchUi.loadResource($.Rez.Fonts.small);
		size_rectangles = (Constants.SCREEN_WIDTH * 74 / 360).toNumber();
		if (withHint) {
			layout_type = 1;
		}
		if (creation) {
			layout_type = 2;
		}
	}

	function onLayout(dc) {
		if (self.layout_type == 1) {
			setLayout(Rez.Layouts.DCPlayerDetailsEquipmentsViewHint(dc));
		} else if (self.layout_type == 2) {
			setLayout(Rez.Layouts.DCPlayerDetailsEquipmentsViewCreation(dc));
		}
	}

	function drawRectangle(dc as Dc, x as Number, y as Number, name as String, equipslot as ItemSlot) as Void {
		var x_start = x - size_rectangles/2;
		var y_start = y - size_rectangles/2;
		var y_line = y + 1*size_rectangles/5;
		dc.drawRectangle(x_start, y_start, size_rectangles, size_rectangles);
		dc.drawLine(x_start, y_line, x_start + size_rectangles, y_line);
		dc.drawText(x, y_line, small_font, name, Graphics.TEXT_JUSTIFY_CENTER);
		var res = equipped_res[equipslot];
		if (res != null) {
			var new_size = size_rectangles * 3/5;
			dc.drawScaledBitmap(x - new_size/2, y_start + new_size/2 - size_rectangles/4, new_size, new_size, res);
		}
	}

	function drawAmmo(dc as Dc, x as Number, y as Number, name as String, equipslot as ItemSlot) as Void {
		drawRectangle(dc, x, y, name, equipslot);
		var ammo = _player.getEquip(AMMUNITION);
		if (ammo != null) {
			var x_text = x + size_rectangles/2;
			var y_text = y - size_rectangles/2;
			var amount = ammo.getAmount();
			dc.drawText(x_text - 1, y_text, small_font, "x" + amount, Graphics.TEXT_JUSTIFY_RIGHT);
		}
	}

	function updateEquipped() {
		equipped_res = {};
		for (var i = 0; i < 9; i++) {
			var slot = num_to_equipslot[i];
			var item = _player.getEquip(slot);
			if (item != null) {
				equipped_res[slot] = WatchUi.loadResource(item.getSprite());
			}
		}
	}
	
	
	function onUpdate(dc as Dc) as Void {
		updateEquipped();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

		// Update layout
		View.onUpdate(dc);

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

		// Calculate dynamic positions for equipment slots
		var center_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var left_x = (Constants.SCREEN_WIDTH * 100 / 360).toNumber();
		var right_x = (Constants.SCREEN_WIDTH * 260 / 360).toNumber();
		var y1 = (Constants.SCREEN_HEIGHT * 80 / 360).toNumber();
		var y2 = (Constants.SCREEN_HEIGHT * 160 / 360).toNumber();
		var y3 = (Constants.SCREEN_HEIGHT * 240 / 360).toNumber();
		var y4 = (Constants.SCREEN_HEIGHT * 320 / 360).toNumber();

		// Head
		drawRectangle(dc, center_x, y1, "Head", HEAD);
		// Chest
		drawRectangle(dc, center_x, y2, "Chest", CHEST);
		// Back
		drawRectangle(dc, left_x, y2, "Back", BACK);
		// Legs
		drawRectangle(dc, center_x, y3, "Legs", LEGS);
		// Feet
		drawRectangle(dc, center_x, y4, "Feet", FEET);
		// Hands
		drawRectangle(dc, left_x, y3, "L. Hand", LEFT_HAND);
		drawRectangle(dc, right_x, y3, "R. Hand", RIGHT_HAND);
		// Accessory
		drawRectangle(dc, left_x, y1, "Accessory", ACCESSORY);
		// Ammunition
		drawAmmo(dc, right_x, y2, "Ammo", AMMUNITION);

	}

	
}