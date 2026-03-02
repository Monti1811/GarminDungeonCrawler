import Toybox.Lang;
import Toybox.Math;

module Pathfinder {

	
	function toIntPoint2D(point as Point2D) as Number {
        return (point[0] << 8) + point[1];
	}

	function fromIntPoint2D(point as Number) as Point2D {
		return [point >> 8, point & 0xFF];
	}


    // Find the next best movement to reach the target the fastest
    function findPathToPos(map as Map, start_pos as Point2D, end_pos as Point2D) as Point2D? {
        return findPathToAnyPos(map, start_pos, [end_pos]);
    }

    // Find the next best movement to reach any target position the fastest
    function findPathToAnyPos(map as Map, start_pos as Point2D, end_positions as Array<Point2D>) as Point2D? {
        start_pos = toIntPoint2D(start_pos);
        

        var target_dict = {} as Dictionary<Number, Boolean>;
        for (var i = 0; i < end_positions.size(); i++) {
            target_dict[toIntPoint2D(end_positions[i])] = true;
        }

        if (target_dict.size() == 0) {
            return null;
        }

        var open_dict = {start_pos => true} as Dictionary<Number, Boolean>;
        var closed_dict = {} as Dictionary<Number, Boolean>;
        var g_score = {} as Dictionary<Number, Number>;
        var came_from = {} as Dictionary<Number, Number>;
        g_score[start_pos] = 0;

        while (open_dict.size() > 0) {
            var current = getLowestG(open_dict, g_score);
            if (target_dict.hasKey(current)) {
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


    function getNeighbors(map as Map, pos_num as Number) as Array<Number> {
        var neighbors = [] as Array<Number>;
        var pos = fromIntPoint2D(pos_num);
        if (pos[0] > 0 && MapUtil.canMoveToPlayer(map, [pos[0] - 1, pos[1]])) {
            neighbors.add(toIntPoint2D([pos[0] - 1, pos[1]]));
        }
        if (pos[0] < map.getXSize() - 1 && MapUtil.canMoveToPlayer(map, [pos[0] + 1, pos[1]])) {
            neighbors.add(toIntPoint2D([pos[0] + 1, pos[1]]));
        }
        if (pos[1] > 0 && MapUtil.canMoveToPlayer(map, [pos[0], pos[1] - 1])) {
            neighbors.add(toIntPoint2D([pos[0], pos[1] - 1]));
        }
        if (pos[1] < map.getYSize() - 1 && MapUtil.canMoveToPlayer(map, [pos[0], pos[1] + 1])) {
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
        if (path.size() < 2) {
            return path[0];
        }
        return path[path.size() - 2];
    }

	function findSimplePathToPos(map as Map, start_pos as Point2D, end_pos as Point2D) as Point2D? {
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

    function randomMovement(map as Map, pos as Point2D) as Point2D? {
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

    function randomTeleport(map as Map, pos as Point2D) as Point2D? {
        var new_pos = null as Point2D?;
        var max_iterations = 10;
        var iteration = 0;
        var room = $.Game.getCurrentRoom();
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

    function teleportToPlayer(map as Map, pos as Point2D) as Point2D? {
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

    function teleportBehindPlayer(map as Map, pos as Point2D) as Point2D? {
        var player = $.getApp().getPlayer();
        var player_pos = player.getPos();

        var dx = player_pos[0] - pos[0];
        var dy = player_pos[1] - pos[1];
        var step_x = 0;
        var step_y = 0;
        if (dx > 0) {
            step_x = 1;
        } else if (dx < 0) {
            step_x = -1;
        }
        if (dy > 0) {
            step_y = 1;
        } else if (dy < 0) {
            step_y = -1;
        }

        var candidates = [
            [player_pos[0] + step_x, player_pos[1] + step_y],
            [player_pos[0] + step_x, player_pos[1]],
            [player_pos[0], player_pos[1] + step_y],
            [player_pos[0] - step_x, player_pos[1]],
            [player_pos[0], player_pos[1] - step_y]
        ] as Array<Point2D>;

        return getFirstWalkablePos(map, candidates);
    }

    function teleportToFurthestFromPlayer(map as Map, pos as Point2D) as Point2D? {
        var player = $.getApp().getPlayer();
        var player_pos = player.getPos();
        var room = $.Game.getCurrentRoom();
        var room_size = room.getSize();
        var coords_room = MapUtil.getCoordOfRoom(room_size[0], room_size[1]);

        var corners = [
            [coords_room[0] + 1, coords_room[2] + 1],
            [coords_room[0] + 1, coords_room[3] - 1],
            [coords_room[1] - 1, coords_room[2] + 1],
            [coords_room[1] - 1, coords_room[3] - 1]
        ] as Array<Point2D>;

        var best_pos = null as Point2D?;
        var best_dist = -1;
        for (var i = 0; i < corners.size(); i++) {
            var candidate = corners[i];
            if (!MapUtil.canMoveToPoint(map, candidate)) {
                continue;
            }
            var dist = MapUtil.calcDistance(candidate, player_pos);
            if (dist > best_dist) {
                best_dist = dist;
                best_pos = candidate;
            }
        }

        if (best_pos != null) {
            return best_pos;
        }
        return randomTeleport(map, pos);
    }

    function strafeAroundPlayer(map as Map, pos as Point2D, clockwise as Boolean) as Point2D? {
        var player = $.getApp().getPlayer();
        var player_pos = player.getPos();

        var rel_x = pos[0] - player_pos[0];
        var rel_y = pos[1] - player_pos[1];

        var strafe = [0, 0] as Point2D;
        if (clockwise) {
            strafe = [rel_y, -rel_x];
        } else {
            strafe = [-rel_y, rel_x];
        }

        var step_x = 0;
        var step_y = 0;
        if (strafe[0] > 0) {
            step_x = 1;
        } else if (strafe[0] < 0) {
            step_x = -1;
        }
        if (strafe[1] > 0) {
            step_y = 1;
        } else if (strafe[1] < 0) {
            step_y = -1;
        }

        var candidates = [
            [pos[0] + step_x, pos[1] + step_y],
            [pos[0] + step_x, pos[1]],
            [pos[0], pos[1] + step_y]
        ] as Array<Point2D>;

        return getFirstWalkablePos(map, candidates);
    }

    function dashTowardPlayer(map as Map, pos as Point2D, max_steps as Number) as Point2D? {
        var player = $.getApp().getPlayer();
        var player_pos = player.getPos();
        if (max_steps < 1) {
            return null;
        }

        var path_step = findPathToPos(map, pos, player_pos);
        if (path_step == null || path_step == pos) {
            return null;
        }

        var current = path_step;
        var step = 1;
        while (step < max_steps) {
            var next = findPathToPos(map, current, player_pos);
            if (next == null || next == current || !MapUtil.canMoveToPlayer(map, next)) {
                break;
            }
            current = next;
            step += 1;
        }
        return current;
    }

    function keepDistanceToPlayer(map as Map, pos as Point2D, min_distance as Number, max_distance as Number) as Point2D? {
        var player = $.getApp().getPlayer();
        var player_pos = player.getPos();
        var directions = [
            [pos[0] + 1, pos[1]],
            [pos[0] - 1, pos[1]],
            [pos[0], pos[1] + 1],
            [pos[0], pos[1] - 1]
        ] as Array<Point2D>;

        var best_move = null as Point2D?;
        var best_score = 99999;
        for (var i = 0; i < directions.size(); i++) {
            var candidate = directions[i];
            if (!MapUtil.canMoveToPlayer(map, candidate) && !MapUtil.canMoveToPoint(map, candidate)) {
                continue;
            }
            var dist = MapUtil.calcDistance(candidate, player_pos);
            var score = 0;
            if (dist < min_distance) {
                score = min_distance - dist;
            } else if (dist > max_distance) {
                score = dist - max_distance;
            }
            if (score < best_score) {
                best_score = score;
                best_move = candidate;
            }
        }
        return best_move;
    }

    function getFirstWalkablePos(map as Map, candidates as Array<Point2D>) as Point2D? {
        for (var i = 0; i < candidates.size(); i++) {
            var candidate = candidates[i];
            if (MapUtil.canMoveToPoint(map, candidate) || MapUtil.canMoveToPlayer(map, candidate)) {
                return candidate;
            }
        }
        return null;
    }

    // Move away from the player
    function walkAwayFromPlayer(map as Map, pos as Point2D) as Point2D? {
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