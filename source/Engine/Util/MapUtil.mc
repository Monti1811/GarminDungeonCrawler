import Toybox.Lang;
import Toybox.Math;

module MapUtil {

	function isPosPlayer(map as Array<Array<Tile>>, new_pos as Point2D) as Boolean {
		if (map[new_pos[0]][new_pos[1]].player) {
			return true;
		}
		return false;
	}

	function canMoveToPoint(map as Array<Array<Tile>>, point as Point2D) as Boolean {
		if (point[0] < 0 || point[0] >= map.size() || point[1] < 0 || point[1] >= map[0].size()) {
			return false;
		}
		var tile = map[point[0]][point[1]];
		if (tile.type != PASSABLE || tile.content != null || tile.player) {
			return false;
		}
		return true;
	}

	function shuffle(array as Array) as Array {
		for (var i = array.size() - 1; i > 0; i--) {
			var j = MathUtil.random(0, i);
			var temp = array[i];
			array[i] = array[j];
			array[j] = temp;
		}
		return array;
	}

	function findRandomEmptyTileAround(map as Array<Array<Tile>>, pos as Point2D) as Point2D? {
		var directions = [
			[0, -1],
			[0, 1],
			[-1, 0],
			[1, 0]
		] as Array<Point2D>;
		var random_directions = shuffle(directions) as Array<Point2D>;
		for (var i = 0; i < random_directions.size(); i++) {
			var new_pos = [pos[0] + random_directions[i][0], pos[1] + random_directions[i][1]];
			if (canMoveToPoint(map, new_pos)) {
				return new_pos;
			}
		}
		return null;
	}

	function canMoveToPlayer(map as Array<Array<Tile>>, point as Point2D) as Boolean {
		if (point[0] < 0 || point[0] >= map.size() || point[1] < 0 || point[1] >= map[0].size()) {
			return false;
		}
		var tile = map[point[0]][point[1]];
		if (tile.content == null || !tile.player) {
			return false;
		}
		return true;
	}

	function checkEnemy(map as Array<Array<Tile>>, x as Number, y as Number) {
        if (x >= 0 && x < map.size() && y >= 0 && y < map[0].size()) {
            var enemy = map[x][y].content as Enemy?;
            if (enemy != null && enemy instanceof Enemy) {
                return enemy;
            }
        }
        return null;
    }

	function getEnemyInRangeLinear(map as Array<Array<Tile>>, pos as Point2D, range as Number, direction as WalkDirection) as Enemy? {
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
		for (var i = 1; i <= range; i++) {
			var enemy;
			if (direction == UP || direction == DOWN) {
				enemy = checkEnemy(map, x, y + i * dy);
			} else {
				enemy = checkEnemy(map, x + i * dx, y);
			}
			if (enemy != null) {
				return enemy;
			}
		}
		return null;
	}

	function getEnemyInRangeDirectional(map as Array<Array<Tile>>, pos as Point2D, range as Number, direction as WalkDirection) as Enemy? {
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

	function getEnemyInRangeSurrounding(map as Array<Array<Tile>>, pos as Point2D, range as Number) as Array<Enemy?> {
		var x = pos[0];
		var y = pos[1];
		// Check every field around the position for enemies and add them to the list
		var enemies = [];
		for (var i = -range; i <= range; i++) {
			for (var j = -range; j <= range; j++) {
				if (i == 0 && j == 0) {
					continue;
				}
				var enemy = checkEnemy(map, x + i, y + j);
				if (enemy != null) {
					enemies.add(enemy);
				}
			}
		}
		return enemies;
	}
	
    function getEnemyInRange(map as Array<Array<Tile>>, pos as Point2D, range as Number, range_type as RangeType, direction as WalkDirection) as Array<Enemy?> {
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
		switch (range_type) {
			case LINEAR:
				return [getEnemyInRangeLinear(map, pos, range, direction)];
			case DIRECTIONAL:
				return [getEnemyInRangeDirectional(map, pos, range, direction)];
			case SURROUNDING:
				return getEnemyInRangeSurrounding(map, pos, range);
		}
		return [];
		
	}

	function getRangeCoords(map as Array<Array<Tile>>, pos as Point2D, range as Number, range_type as RangeType, direction as WalkDirection) as Array<Point2D> {
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

		var coords = [];
		// Check integer range
		for (var i = 1; i <= range_int; i++) {
			var reduced_i = i - 1;
			for (var j = -reduced_i; j <= reduced_i; j++) {
				if (direction == UP || direction == DOWN) {
					coords.add([x + j, y + i * dy]);
				} else {
					coords.add([x + i * dx, y + j]);
				}
			}
		}

		// Check fractional range
		if (range_float > 0) {
			if (direction == UP || direction == DOWN) {
				coords.add([x - 1, y + range_int * dy]);
				coords.add([x + 1, y + range_int * dy]);
			} else if (direction == LEFT || direction == RIGHT) {
				coords.add([x + range_int * dx, y - 1]);
				coords.add([x + range_int * dx, y + 1]);
			}
		}

		return coords;
	}

	function getNumTilesForScreensize() as Point2D {
		var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
		var screen_size_x = Math.ceil(360.0/tile_width).toNumber();
		var screen_size_y = Math.ceil(360.0/tile_height).toNumber();
		return [screen_size_x, screen_size_y];
	}

	function getRandomPos(map as Array<Array<Tile>>, left as Number, right as Number, top as Number, bottom as Number) as Point2D {
		var x = 0;
		var y = 0;
		do {
			x = MathUtil.random(left + 1, right - 1);
			y = MathUtil.random(top + 1, bottom - 1);
		} while ((x == 11 || y == 11) && map[x][y].content != null);
		return [x, y];
	}

	function getRandomPosFromRoom(room as Room) as Point2D {
		var map_data = room.getMapData();
		var coords = getCoordOfRoom(map_data[:size_x], map_data[:size_y]);
		return getRandomPos(map_data[:map], coords[0], coords[1], coords[2], coords[3]);
	}

	function getCoordOfRoom(room_size_x as Number, room_size_y as Number) as Array<Number> {
		var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
		var screen_size_x = Math.ceil(360.0/tile_width).toNumber();
		var screen_size_y = Math.ceil(360.0/tile_height).toNumber();

		var middle_of_screen = [Math.floor(screen_size_x/2), Math.floor(screen_size_y/2)];
		var left = middle_of_screen[0] - Math.floor(room_size_x/2);
		var right = middle_of_screen[0] + Math.floor(room_size_x/2);
		var top = middle_of_screen[1] - Math.floor(room_size_y/2);
		var bottom = middle_of_screen[1] + Math.floor(room_size_y/2);
		return [left, right, top, bottom];
	}

	function calcDistance(pos1 as Point2D, pos2 as Point2D) as Numeric {
		return Math.sqrt(Math.pow(pos1[0] - pos2[0], 2) + Math.pow(pos1[1] - pos2[1], 2));
	}

	class EnemyDistanceCompare {

		private var player_pos as Point2D;

		function initialize(player_pos as Point2D) {
			self.player_pos = player_pos;
		}

		function compare(a as Object, b as Object) as Number {
			var enemy1 = a as Enemy;
			var enemy2 = b as Enemy;

			var dist1 = calcDistance(player_pos, enemy1.getPos());
			var dist2 = calcDistance(player_pos, enemy2.getPos());
			if (dist1 < dist2) {
				return -1;
			} else if (dist1 > dist2) {
				return 1;
			}
			return 0;
			
		}
	}

	function getCoordInDirection(pos as Point2D, direction as WalkDirection) as Point2D {
		var x = pos[0];
		var y = pos[1];
		if (direction == UP) {
			y--;
		} else if (direction == DOWN) {
			y++;
		} else if (direction == LEFT) {
			x--;
		} else if (direction == RIGHT) {
			x++;
		}
		return [x, y];
	}

	function getInversedDirection(direction as WalkDirection) as WalkDirection {
		if (direction == UP) {
			return DOWN;
		} else if (direction == DOWN) {
			return UP;
		} else if (direction == LEFT) {
			return RIGHT;
		} else if (direction == RIGHT) {
			return LEFT;
		}
		return STANDING;
	}

	function getAllDirectionPoints(pos as Point2D) as Array<Point2D> {
		var points = [] as Array<Point2D>;
		points.add(getCoordInDirection(pos, UP));
		points.add(getCoordInDirection(pos, DOWN));
		points.add(getCoordInDirection(pos, LEFT));
		points.add(getCoordInDirection(pos, RIGHT));
		return points;
	}

}