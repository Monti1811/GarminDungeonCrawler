import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

class TextView extends WatchUi.View {
	
	hidden var _textArea;
	private var _text as String;
	//private var completitionHint as Bitmap;

	function initialize(text as String) {
		View.initialize();
		_text = text;
	}

	function onLayout(dc as Dc) as Void {

    }

	function onShow() as Void {

		_textArea = new WatchUi.TextArea({
            :text=>_text,
            :color=>Graphics.COLOR_WHITE,
            :font=>[Graphics.FONT_TINY, Graphics.FONT_XTINY],
            :locX =>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER,
            :width=>Constants.SCREEN_WIDTH - 100,
            :height=>Constants.SCREEN_HEIGHT - 100,
        });
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.clear();
        _textArea.draw(dc);
    }
}