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
		dc.drawScaledBitmap(150, 90, 60, 60, _itemIcon);
		var formatted_text = Graphics.fitTextToArea(_item.getName(), Graphics.FONT_MEDIUM, 260, 150, false);
		dc.drawText(180, 160, Graphics.FONT_MEDIUM, formatted_text, Graphics.TEXT_JUSTIFY_CENTER);
	}
	
}