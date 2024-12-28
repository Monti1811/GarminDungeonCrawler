import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsEquipmentsView extends WatchUi.View {
	
	private var _player as Player;
	private const size_rectangles as Number = 74;
	private var small_font as FontResource;
	private var _hint as Bitmap;
	private var equipped_res as Dictionary<ItemSlot, BitmapReference?> = {};
	private const num_to_equipslot as Array<ItemSlot> = [HEAD, CHEST, BACK, LEGS, FEET, LEFT_HAND, RIGHT_HAND, ACCESSORY];
	
	function initialize(player as Player) {
		View.initialize();
		_player = player;
		small_font = WatchUi.loadResource($.Rez.Fonts.small);
		_hint = new WatchUi.Bitmap({:rezId => $.Rez.Drawables.rightTop, :locX => 300, :locY => 60});
		for (var i = 0; i < 8; i++) {
			var slot = num_to_equipslot[i];
			var item = _player.getEquip(slot);
			if (item != null) {
				equipped_res[slot] = WatchUi.loadResource(item.getSprite());
			}
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
			dc.drawScaledBitmap(x - res.getWidth(), y_start + res.getHeight()/2 - size_rectangles/10, size_rectangles * 3/5, size_rectangles * 3/5, res);
		}
	}

	function onLayout(dc) {
		
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		
		_hint.draw(dc);
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

	}

	
}