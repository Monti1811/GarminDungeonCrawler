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
		if (new_x < 0 || new_y < 0 ) {	
			Toybox.System.println("Can't move map up in x or y direction");
		}
		if (new_x > _drawable_size[0] || new_y > _drawable_size[1]) {
			Toybox.System.println("Can't move map down in x or y direction");
		}
		_pos[0] = MathUtil.ceil(MathUtil.floor(new_x, _drawable_size[0]), 0);
		_pos[1] = MathUtil.ceil(MathUtil.floor(new_y, _drawable_size[1]), 0);
	}
}