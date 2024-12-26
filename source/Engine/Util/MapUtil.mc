import Toybox.Lang;

module MapUtil {

	function isPosPlayer(map as Array<Array<Object?>>, new_pos as Point2D) as Boolean {
		if (map[new_pos[0]][new_pos[1]] instanceof Player) {
			return true;
		}
		return false;
	}

	function canMoveToPoint(map as Array<Array<Object?>>, point as Point2D) as Boolean {
		if (point[0] < 0 || point[0] >= map.size() || point[1] < 0 || point[1] >= map[0].size()) {
			return false;
		}
		if (map[point[0]][point[1]] != null) {
			return false;
		}
		return true;
	}
	
}