import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCItemInfoOverviewView extends WatchUi.View {
	
	private var _item as Item;
	private var _itemIcon as BitmapReference;
	
	function initialize(item as Item) {
		View.initialize();
		_item = item;
		_itemIcon = WatchUi.loadResource(_item.getSprite());
	}
	
	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
		var icon_x = (Constants.SCREEN_WIDTH * 150 / 360).toNumber();
		var icon_y = (Constants.SCREEN_HEIGHT * 90 / 360).toNumber();
		var icon_size = (Constants.SCREEN_WIDTH * 60 / 360).toNumber();
		var text_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var text_y = (Constants.SCREEN_HEIGHT * 160 / 360).toNumber();
		var area_width = (Constants.SCREEN_WIDTH * 260 / 360).toNumber();
		var area_height = (Constants.SCREEN_HEIGHT * 150 / 360).toNumber();
		dc.drawScaledBitmap(icon_x, icon_y, icon_size, icon_size, _itemIcon);
		var formatted_text = Graphics.fitTextToArea(_item.getName(), Graphics.FONT_MEDIUM, area_width, area_height, false);
		dc.drawText(text_x, text_y, Graphics.FONT_MEDIUM, formatted_text, Graphics.TEXT_JUSTIFY_CENTER);
	}
	
}