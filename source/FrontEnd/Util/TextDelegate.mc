import Toybox.WatchUi;
import Toybox.Lang;

class TextDelegate extends WatchUi.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onBack() as Boolean {
		WatchUi.popView(WatchUi.SLIDE_DOWN);
		return true;
	}

	function onTap(evt) as Boolean {
		WatchUi.popView(WatchUi.SLIDE_DOWN);
		return true;
	}
}