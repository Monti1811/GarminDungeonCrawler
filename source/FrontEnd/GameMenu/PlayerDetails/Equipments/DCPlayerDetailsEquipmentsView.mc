import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsEquipmentsView extends WatchUi.View {
	
	private var _player as Player;
	private const size_rectangles as Number = 74;
	private var small_font as FontResource;
	private var _hint as Bitmap?;
	private var equipped_res as Dictionary<ItemSlot, BitmapReference?> = {};
	private const num_to_equipslot as Array<ItemSlot> = [HEAD, CHEST, BACK, LEGS, FEET, LEFT_HAND, RIGHT_HAND, ACCESSORY, AMMUNITION];

	private var accept as Bitmap?;
	private var cancel as Bitmap?;
	
	function initialize(player as Player, withHint as Boolean, creation as Boolean) {
		View.initialize();
		_player = player;
		small_font = WatchUi.loadResource($.Rez.Fonts.small);
		if (withHint) {
			_hint = new WatchUi.Bitmap({:rezId => $.Rez.Drawables.rightTop, :locX => 300, :locY => 60});
		}
		if (creation) {
			accept = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTopAccept, :locX=>300, :locY=>60});
			cancel = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightBottomCancel, :locX=>290, :locY=>220});
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

	function onLayout(dc) {
		
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
	
	
	function onUpdate(dc) {
		updateEquipped();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		
		if (_hint != null) {
			_hint.draw(dc);
		}
		if (accept != null) {
			accept.draw(dc);
			cancel.draw(dc);
		}
		// Head
		drawRectangle(dc, 180, 80, "Head", HEAD);
		// Chest
		drawRectangle(dc, 180, 160, "Chest", CHEST);
		// Back
		drawRectangle(dc, 100, 160, "Back", BACK);
		// Legs
		drawRectangle(dc, 180, 240, "Legs", LEGS);
		// Feet
		drawRectangle(dc, 180, 320, "Feet", FEET);
		// Hands
		drawRectangle(dc, 100, 240, "L. Hand", LEFT_HAND);
		drawRectangle(dc, 260, 240, "R. Hand", RIGHT_HAND);
		// Accessory
		drawRectangle(dc, 100, 80, "Accessory", ACCESSORY);
		// Ammunition
		drawAmmo(dc, 260, 160, "Ammo", AMMUNITION);

	}

	
}