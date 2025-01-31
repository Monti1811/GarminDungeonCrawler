import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

class DCMapView extends WatchUi.View {

	private var _map as DCMapDrawable;
	private var _pos as Point2D;
	private var _drawable_size as Point2D;

	function initialize() {
		View.initialize();
		_map = new DCMapDrawable();
		_pos = _map.getInitialPos();
		_drawable_size = _map.getDrawableSize();
	}


	function onUpdate(dc as Dc) {
		_map.setLocation(_pos[0], _pos[1]);
		_map.draw(dc);
	}

	function updatePos(pos as Point2D) {
		_pos = pos;
	}

	function moveMap(dx as Number, dy as Number) {
		var new_x = _pos[0] + dx;
		var new_y = _pos[1] + dy;

		var min_x = -_drawable_size[0] / 2;
		var min_y = -_drawable_size[1] / 2;
		var max_x = _drawable_size[0] * 3/2;
		var max_y = _drawable_size[1] * 3/2;
		if (new_x < min_x || new_y < min_y) {	
			Toybox.System.println("Can't move map up in x or y direction");
		}
		if (new_x > max_x || new_y > max_y) {
			Toybox.System.println("Can't move map down in x or y direction");
		}
		_pos[0] = MathUtil.clamp(new_x, min_x, max_x);
		_pos[1] = MathUtil.clamp(new_y, min_y, max_y);
	}
}