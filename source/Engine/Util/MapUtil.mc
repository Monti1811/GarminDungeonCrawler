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

	function checkEnemy(map as Array<Array<Object?>>, x as Number, y as Number) {
        if (x >= 0 && x < map.size() && y >= 0 && y < map[0].size()) {
            var enemy = map[x][y] as Enemy?;
            if (enemy != null && enemy instanceof Enemy) {
                return enemy;
            }
        }
        return null;
    }
	
    function getEnemyInRange(map as Array<Array<Object?>>, pos as Point2D, range as Number, range_type as RangeType, direction as WalkDirection) as Enemy? {
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
		Range 2, direction left:
		[ ][ ][ ][ ][ ]
		[ ][x][ ][ ][ ]
		[x][x][P][ ][ ]
		[ ][x][ ][ ][ ]
		[ ][ ][ ][ ][ ]
		Range 2.5, direction left:
		[ ][ ][ ][ ][ ]
		[x][x][ ][ ][ ]
		[x][x][P][ ][ ]
		[x][x][ ][ ][ ]
		[ ][ ][ ][ ][ ]
		Range 3, direction left:
		[ ][ ][x][ ][ ][ ]
		[ ][x][x][ ][ ][ ]
		[x][x][x][P][ ][ ]
		[ ][x][x][ ][ ][ ]
		[ ][ ][x][ ][ ][ ]
		Range 3.5, direction left:
		[ ][x][x][ ][ ][ ]
		[x][x][x][ ][ ][ ]
		[x][x][x][P][ ][ ]
		[x][x][x][ ][ ][ ]
		[ ][x][x][ ][ ][ ]
		*/
		var range_int = Math.floor(range).toNumber() as Number;
		var range_float = range - range_int;
		var x = pos[0];
		var y = pos[1];

		var dx = 0, dy = 0;
		if (direction == UP) {
			dy = -1;
		} else if (direction == DOWN) {
			dy = 1;
		} else if (direction == LEFT) {
			dx = -1;
		} else if (direction == RIGHT) {
			dx = 1;
		}

		// Check integer range
		for (var i = 1; i <= range_int; i++) {
			var reduced_i = i - 1;
			if (range_type == LINEAR) {
				reduced_i = 0;
			}
			for (var j = -reduced_i; j <= reduced_i; j++) {
				var enemy;
				if (direction == UP || direction == DOWN) {
					enemy = checkEnemy(map, x + j, y + i * dy);
				} else {
					enemy = checkEnemy(map, x + i * dx, y + j);
				}
				if (enemy != null) {
					return enemy;
				}
			}
		}

		// Check fractional range
		if (range_float > 0) {
			var enemy;
			if (direction == UP || direction == DOWN) {
				enemy = checkEnemy(map, x - 1, y + range_int * dy);
				if (enemy != null) {
					return enemy;
				}
				enemy = checkEnemy(map, x + 1, y + range_int * dy);
				if (enemy != null) {
					return enemy;
				}
			} else if (direction == LEFT || direction == RIGHT) {
				enemy = checkEnemy(map, x + range_int * dx, y - 1);
				if (enemy != null) {
					return enemy;
				}
				enemy = checkEnemy(map, x + range_int * dx, y + 1);
				if (enemy != null) {
					return enemy;
				}
			}
		}

		return null;
	}

	function getNumTilesForScreensize() as Point2D {
		var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
		var screen_size_x = Math.ceil(360.0/tile_width).toNumber();
		var screen_size_y = Math.ceil(360.0/tile_height).toNumber();
		return [screen_size_x, screen_size_y];
	}

	function getRandomPos(map as Array<Array<Object?>>, left as Number, right as Number, top as Number, bottom as Number) as Point2D {
		var x = 0;
		var y = 0;
		do {
			x = MathUtil.random(left + 1, right - 1);
			y = MathUtil.random(top + 1, bottom - 1);
		} while (map[x][y] != null);
		return [x, y];
	}

	function getRandomPosFromRoom(room as Room) as Point2D {
		var map_data = room.getMapData();
		var coords = getCoordOfRoom(map_data[:size_x], map_data[:size_y]);
		return getRandomPos(map_data[:map], coords[0], coords[1], coords[2], coords[3]);
	}

	function getCoordOfRoom(size_x as Number, size_y as Number) as Array<Number> {
		var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
		var screen_size_x = Math.ceil(360.0/tile_width).toNumber();
		var screen_size_y = Math.ceil(360.0/tile_height).toNumber();
		var room_size_x = MathUtil.random(5, 15);
		var room_size_y = MathUtil.random(5, 15);

		var middle_of_screen = [Math.floor(screen_size_x/2), Math.floor(screen_size_y/2)];
		var left = middle_of_screen[0] - Math.floor(room_size_x/2);
		var right = middle_of_screen[0] + Math.floor(room_size_x/2);
		var top = middle_of_screen[1] - Math.floor(room_size_y/2);
		var bottom = middle_of_screen[1] + Math.floor(room_size_y/2);
		return [left, right, top, bottom];
	}

}