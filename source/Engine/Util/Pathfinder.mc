import Toybox.Lang;
import Toybox.Math;

module Pathfinder {

	
	function toIntPoint2D(point as Point2D) as Number {
		return point[0] << 8 + point[1];
	}

	function fromIntPoint2D(point as Number) as Point2D {
		return [point >> 8, point & 0xFF];
	}


    // Find the next best movement to reach the target the fastest
    function findPathToPos(map as Array<Array<Tile>>, start_pos as Point2D, end_pos as Point2D) as Point2D? {
        start_pos = toIntPoint2D(start_pos);
        end_pos = toIntPoint2D(end_pos);
        var open_dict = {start_pos => true} as Dictionary<Number, Boolean>;
        var closed_dict = {} as Dictionary<Number, Boolean>;
        var g_score = {} as Dictionary<Number, Number>;
        var came_from = {} as Dictionary<Number, Number>;
        g_score[start_pos] = 0;

        while (open_dict.size() > 0) {
            var current = getLowestG(open_dict, g_score);
            if (current == end_pos) {
                return fromIntPoint2D(reconstructPath(came_from, current));
            }

            open_dict.remove(current);
            closed_dict.put(current, true);

            var neighbors = getNeighbors(map, current);
            for (var i = 0; i < neighbors.size(); i++) {
                var neighbor = neighbors[i] as Number;
                if (closed_dict.hasKey(neighbor)) {
                    continue;
                }

                var tentative_g_score = g_score[current] + 1;
				var hasKey = open_dict.hasKey(neighbor);
                if (!hasKey || tentative_g_score < g_score[neighbor]) {
                    came_from[neighbor] = current;
                    g_score[neighbor] = tentative_g_score;
                    if (!hasKey) {
                        open_dict.put(neighbor, true);
                    }
                }
            }
        }

        return null;
    }

    function getLowestG(open_dict as Dictionary<Number, Boolean>, g_score as Dictionary<Number, Number>) as Number {
		var keys = open_dict.keys();
        var lowest = keys[0];
        for (var i = 1; i < keys.size(); i++) {
            if (g_score[keys[i]] < g_score[lowest]) {
                lowest = keys[i];
            }
        }
        return lowest;
    }


    function getNeighbors(map as Array<Array<Tile>>, pos_num as Number) as Array<Number> {
        var neighbors = [] as Array<Number>;
        var pos = fromIntPoint2D(pos_num);
        if (pos[0] > 0 && MapUtil.canMoveToPlayer(map, [pos[0] - 1, pos[1]])) {
            neighbors.add(toIntPoint2D([pos[0] - 1, pos[1]]));
        }
        if (pos[0] < map.size() - 1 && MapUtil.canMoveToPlayer(map, [pos[0] + 1, pos[1]])) {
            neighbors.add(toIntPoint2D([pos[0] + 1, pos[1]]));
        }
        if (pos[1] > 0 && MapUtil.canMoveToPlayer(map, [pos[0], pos[1] - 1])) {
            neighbors.add(toIntPoint2D([pos[0], pos[1] - 1]));
        }
        if (pos[1] < map[0].size() - 1 && MapUtil.canMoveToPlayer(map, [pos[0], pos[1] + 1])) {
            neighbors.add(toIntPoint2D([pos[0], pos[1] + 1]));
        }
        return neighbors;
    }

    function reconstructPath(came_from as Dictionary<Number, Number>, current as Number) as Number? {
        var path = [current];
        while (came_from[current] != null) {
            current = came_from[current];
            path.add(current);
        }
        return path[path.size() - 2];
    }

	function findSimplePathToPos(map as Array<Array<Tile>>, start_pos as Point2D, end_pos as Point2D) as Point2D? {
		var current_pos = start_pos;
		var directions = [
			[current_pos[0] + 1, current_pos[1]], // right
			[current_pos[0] - 1, current_pos[1]], // left
			[current_pos[0], current_pos[1] + 1], // down
			[current_pos[0], current_pos[1] - 1]  // up
		];
		var min_distance = MapUtil.calcDistance(current_pos, end_pos);
		var best_move = null;

		for (var i = 0; i < directions.size(); i++) {
			var new_pos = directions[i];
			if (MapUtil.canMoveToPlayer(map, new_pos) || MapUtil.canMoveToPoint(map, new_pos)) {
				var new_distance = MapUtil.calcDistance(new_pos, end_pos);
				if (new_distance < min_distance) {
					min_distance = new_distance;
					best_move = new_pos;
				}
			}
		}
		return best_move;
	}

    function randomMovement(map as Array<Array<Tile>>, pos as Point2D) as Point2D? {
        var directions = [
            [0, 1],
            [0, -1],
            [1, 0],
            [-1, 0],
        ];
        var new_pos = null as Point2D?;
        var max_iterations = 10;
        var iteration = 0;
        while (iteration < max_iterations && new_pos == null) {
            var direction = directions[MathUtil.random(0, directions.size() - 1)];
            new_pos = [pos[0] + direction[0], pos[1] + direction[1]];
            if (!MapUtil.canMoveToPoint(map, new_pos)) {
                new_pos = null;
            }
            iteration++;
        }
        return new_pos;
    }

    function randomTeleport(map as Array<Array<Tile>>, pos as Point2D) as Point2D? {
        var new_pos = null as Point2D?;
        var max_iterations = 10;
        var iteration = 0;
        var room = $.getApp().getCurrentDungeon().getCurrentRoom();
        var room_size = room.getSize();
        var coords_room = MapUtil.getCoordOfRoom(room_size[0], room_size[1]);
        while (iteration < max_iterations && new_pos == null) {
            var x = MathUtil.random(coords_room[0] + 1, coords_room[1] - 1);
            var y = MathUtil.random(coords_room[2] + 1, coords_room[3] - 1);
            if (MapUtil.canMoveToPoint(map, [x, y])) {
                new_pos = [x, y] as Point2D;
            }
            iteration++;
        }
        return new_pos;
    }

    function teleportToPlayer(map as Array<Array<Tile>>, pos as Point2D) as Point2D? {
        var player = $.getApp().getPlayer();
        var player_pos = player.getPos();
        var new_pos = null as Point2D?;
        var max_iterations = 10;
        var iteration = 0;
        while (iteration < max_iterations && new_pos == null) {
            var x = MathUtil.random(player_pos[0] - 1, player_pos[0] + 1);
            var y = MathUtil.random(player_pos[1] - 1, player_pos[1] + 1);
            if (MapUtil.canMoveToPoint(map, [x, y])) {
                new_pos = [x, y] as Point2D;
            }
            iteration++;
        }
        return new_pos;
    }

    // Move away from the player
    function walkAwayFromPlayer(map as Array<Array<Tile>>, pos as Point2D) as Point2D? {
		var player = $.getApp().getPlayer();
		var player_pos = player.getPos();
		var directions = [
			[pos[0] + 1, pos[1]], // right
			[pos[0] - 1, pos[1]], // left
			[pos[0], pos[1] + 1], // down
			[pos[0], pos[1] - 1]  // up
		];
		var max_distance = MapUtil.calcDistance(pos, player_pos);
		var best_move = null;

		for (var i = 0; i < directions.size(); i++) {
			var new_pos = directions[i];
			if (MapUtil.canMoveToPlayer(map, new_pos) || MapUtil.canMoveToPoint(map, new_pos)) {
				var new_distance = MapUtil.calcDistance(new_pos, player_pos);
				if (new_distance > max_distance) {
					max_distance = new_distance;
					best_move = new_pos;
				}
			}
		}
		return best_move;
	}
}