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
		dc.drawScaledBitmap(60, 150, 60, 60, _itemIcon);
		dc.drawText(180, 180, Graphics.FONT_MEDIUM, _item.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}
	
}