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
		var formatted_name = Graphics.fitTextToArea(_item.getName(), Graphics.FONT_MEDIUM, 260, 150, false);
		dc.drawText(180, 90, Graphics.FONT_MEDIUM, formatted_name, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		var formatted_text = Graphics.fitTextToArea(_item.getDescription(), Graphics.FONT_XTINY, 260, 150, false);
		dc.drawText(180, 150, Graphics.FONT_TINY, formatted_text, Graphics.TEXT_JUSTIFY_CENTER);
	}
	
}