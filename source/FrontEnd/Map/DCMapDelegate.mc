import Toybox.WatchUi;
import Toybox.Lang;

class DCMapDelegate extends WatchUi.InputDelegate {

	var _previous_coords as Point2D?;

	function initialize() {
		InputDelegate.initialize();
	}

	function onDrag(dragEvent as DragEvent) as Boolean {
		if (dragEvent.getType == DRAG_TYPE_START) {
			_previous_coords = dragEvent.getCoordinates();
			return true;
		}
		if (dragEvent.getType == DRAG_TYPE_CONTINUE) {
			var coords = dragEvent.getCoordinates();
			var dx = coords[0] - _previous_coords[0];
			var dy = coords[1] - _previous_coords[1];
			_previous_coords = coords;
			// Move the map
			
			return true;
		}
		if (dragEvent.getType == DRAG_TYPE_STOP) {
			return true;
		}
		return true;
	}

	function onBack() as Boolean {
		WatchUi.popView(WatchUi.SLIDE_DOWN);
		return true;
	}
}