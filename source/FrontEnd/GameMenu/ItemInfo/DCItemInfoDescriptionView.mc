import Toybox.Lang;
import Toybox.WatchUi;

class DCItemInfoDescriptionView extends WatchUi.View {
	
	private var _item as Item;
	
	function initialize(item as Item) {
		View.initialize();
		_item = item;
	}

	
	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();
		dc.drawText(180, 120, Graphics.FONT_MEDIUM, _item.getName(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(180, 180, Graphics.FONT_TINY, _item.getDescription(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	}
	
}