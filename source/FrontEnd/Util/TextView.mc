import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

class TextView extends WatchUi.View {
	
	private var _text as String;
	//private var completitionHint as Bitmap;

	function initialize(text as String) {
		View.initialize();
		_text = text;
		//completitionHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.completition});
	}

	function onLayout(dc as Dc) as Void {

    }

	function onShow() as Void {
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.clear();

        var formatted_text = Graphics.fitTextToArea(_text, Graphics.FONT_TINY, 260, 260, false);
        dc.drawText(180, 180, Graphics.FONT_TINY, formatted_text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		//completitionHint.draw(dc);

    }
}