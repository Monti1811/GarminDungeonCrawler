import Toybox.WatchUi;
import Toybox.Lang;

class DCMapDelegate extends WatchUi.InputDelegate {

	private var _view as DCMapView;
	private var _previous_coords as Point2D?;

	function initialize(view as DCMapView) {
		InputDelegate.initialize();
		_view = view;
	}

	function onDrag(dragEvent as DragEvent) as Boolean {
		var drag_type = dragEvent.getType();
		switch (drag_type) {
			case DRAG_TYPE_START:
				_previous_coords = dragEvent.getCoordinates() as Point2D;
				break;
			case DRAG_TYPE_CONTINUE:
				var coords = dragEvent.getCoordinates();
				var dx = coords[0] - _previous_coords[0];
				var dy = coords[1] - _previous_coords[1];
				_previous_coords = coords as Point2D;
				// Move the map
				_view.moveMap(dx, dy);
				WatchUi.requestUpdate();
				break;
			case DRAG_TYPE_STOP:
				break;
		}
		return true;
	}

	function onSwipe(swipeEvent) as Boolean {
		return true;
	}

	// Detect Menu button input
    function onKey(keyEvent as KeyEvent) as Boolean {
        if (keyEvent.getKey() == KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        return true;
    }
}