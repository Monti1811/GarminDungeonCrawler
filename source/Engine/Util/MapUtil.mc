import Toybox.Lang;
import Toybox.Math;

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
	
    function getEnemyInRange(map as Array<Array<Object?>>, pos as Point2D, range as Number, direction as WalkDirection) as Enemy? {
		// If range is a natural number like 1, take the fields directly adjacent, if it's something like 1.5, take the fields directly adjacent and diagonal
		// Takes into account the walkdirection, so if the player is facing up, it will only check the fields above him
		/*
		Range 1, direction left:
		[ ][ ][ ][ ][ ]
		[ ][ ][ ][ ][ ]
		[ ][x][P][ ][ ]
		[ ][ ][ ][ ][ ]
		[ ][ ][ ][ ][ ]
		Range 1.5, direction left:
		[ ][ ][ ][ ][ ]
		[ ][x][ ][ ][ ]
		[ ][x][P][ ][ ]
		[ ][x][ ][ ][ ]
		[ ][ ][ ][ ][ ]
		*/
		var x = pos[0];
		var y = pos[1];
		var range_int = Math.floor(range);
		var range_float = range - range_int;
		var enemy = null as Enemy?;
		if (direction == UP) {
			for (var i = 1; i <= range_int; i++) {
				if (y - i >= 0) {
					enemy = map[x][y - i] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
			}
			if (range_float > 0) {
				if (y - range_int - 1 >= 0 && x - 1 >= 0) {
					enemy = map[x - 1][y - range_int - 1] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
				if (y - range_int - 1 >= 0 && x + 1 < map.size()) {
					enemy = map[x + 1][y - range_int - 1] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
			}
		} else if (direction == DOWN) {
			for (var i = 1; i <= range_int; i++) {
				if (y + i < map[0].size()) {
					enemy = map[x][y + i] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
			}
			if (range_float > 0) {
				if (y + range_int + 1 < map[0].size() && x - 1 >= 0) {
					enemy = map[x - 1][y + range_int + 1] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
				if (y + range_int + 1 < map[0].size() && x + 1 < map.size()) {
					enemy = map[x + 1][y + range_int + 1] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
			}
		} else if (direction == LEFT) {
			for (var i = 1; i <= range_int; i++) {
				if (x - i >= 0) {
					enemy = map[x - i][y] as Enemy?;
					if (enemy != null) {
						return enemy;
						}
					}
				}
				if (range_float > 0) {
					if (x - range_int - 1 >= 0 && y - 1 >= 0) {
						enemy = map[x - range_int - 1][y - 1] as Enemy?;
						if (enemy != null) {
							return enemy;
						}
					}
					if (x - range_int - 1 >= 0 && y + 1 < map[0].size()) {
						enemy = map[x - range_int - 1][y + 1] as Enemy?;
						if (enemy != null) {
							return enemy;
						}
					}
				}
		} else if (direction == RIGHT) {
			for (var i = 1; i <= range_int; i++) {
				if (x + i < map.size()) {
					enemy = map[x + i][y] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
			}
			if (range_float > 0) {
				if (x + range_int + 1 < map.size() && y - 1 >= 0) {
					enemy = map[x + range_int + 1][y - 1] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
				if (x + range_int + 1 < map.size() && y + 1 < map[0].size()) {
					enemy = map[x + range_int + 1][y + 1] as Enemy?;
					if (enemy != null) {
						return enemy;
					}
				}
			}
		}
		return null;
	}

}