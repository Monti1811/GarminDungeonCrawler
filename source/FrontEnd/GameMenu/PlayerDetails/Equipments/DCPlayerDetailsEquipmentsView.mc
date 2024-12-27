import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCPlayerDetailsEquipmentsView extends WatchUi.View {
	
	private var _player as Player;
	private const size_rectangles as Number = 74;
	private var small_font as FontResource;
	private var _hint as Bitmap;
	
	function initialize(player as Player) {
		View.initialize();
		_player = player;
		small_font = WatchUi.loadResource($.Rez.Fonts.small);
		_hint = new WatchUi.Bitmap({:rezId => $.Rez.Drawables.rightTop, :locX => 290, :locY => 140});
	}

	function drawRectangle(dc as Dc, x as Number, y as Number, name as String) as Void {
		var x_start = x - size_rectangles/2;
		var y_line = y + 1*size_rectangles/5;
		dc.drawRectangle(x_start, y - size_rectangles/2, size_rectangles, size_rectangles);
		dc.drawLine(x_start, y_line, x_start + size_rectangles, y_line);
		dc.drawText(x, y_line, small_font, name, Graphics.TEXT_JUSTIFY_CENTER);
	}

	function onLayout(dc) {
		
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		
		_hint.draw(dc);
		// Head
		drawRectangle(dc, 180, 80, "Head");
		// Chest
		drawRectangle(dc, 180, 160, "Chest");
		// Legs
		drawRectangle(dc, 180, 240, "Legs");
		// Feet
		drawRectangle(dc, 180, 320, "Feet");
		// Hands
		drawRectangle(dc, 100, 240, "L. Hand");
		drawRectangle(dc, 260, 240, "R. Hand");
		// Accessory
		drawRectangle(dc, 100, 80, "Accessory");
		// Back
		drawRectangle(dc, 100, 160, "Back");

	}

	
}