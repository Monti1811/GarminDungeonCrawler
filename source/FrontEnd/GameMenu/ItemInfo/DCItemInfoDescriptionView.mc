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
		var text_x = (Constants.SCREEN_WIDTH / 2).toNumber();
		var name_y = (Constants.SCREEN_HEIGHT * 90 / 360).toNumber();
		var desc_y = (Constants.SCREEN_HEIGHT * 150 / 360).toNumber();
		var area_width = (Constants.SCREEN_WIDTH * 260 / 360).toNumber();
		var area_height = (Constants.SCREEN_HEIGHT * 150 / 360).toNumber();
		var formatted_name = Graphics.fitTextToArea(_item.getName(), Graphics.FONT_MEDIUM, area_width, area_height, false);
		dc.drawText(text_x, name_y, Graphics.FONT_MEDIUM, formatted_name, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		var formatted_text = Graphics.fitTextToArea(_item.getDescription(), Graphics.FONT_XTINY, area_width, area_height, false);
		dc.drawText(text_x, desc_y, Graphics.FONT_TINY, formatted_text, Graphics.TEXT_JUSTIFY_CENTER);
	}
	
}