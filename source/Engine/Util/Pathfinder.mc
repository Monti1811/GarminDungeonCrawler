import Toybox.Lang;
import Toybox.Math;

module Pathfinder {

	
	function toIntPoint2D(point as Point2D) as Number {
        return (point[0] << 8) + point[1];
	}

	function fromIntPoint2D(point as Number) as Point2D {
		return [point >> 8, point & 0xFF];
	}

    // Manhattan Distance Heuristik
    function manhattanHeuristic(pos1 as Number, pos2 as Number) as Number {
        var x1 = pos1 >> 8;
        var y1 = pos1 & 0xFF;
        var x2 = pos2 >> 8;
        var y2 = pos2 & 0xFF;
        return (x1 - x2).abs() + (y1 - y2).abs();
    }

    // Priority Queue: Array von [priority, value] Paaren
    function pq_enqueue(queue as Array, priority as Number, value as Number) as Void {
        var entry = [priority, value];
        var i = 0;
        while (i < queue.size() && (queue[i] as Array)[0] <= priority) {
            i++;
        }
        queue.add(entry);
        // Verschiebe ab i alle Elements nach hinten
        for (var j = queue.size() - 1; j > i; j--) {
            queue[j] = queue[j - 1];
        }
        queue[i] = entry;
    }
    
    function pq_dequeue(queue as Array) as Number {
        return (queue[0] as Array)[1] as Number;
    }

    // Find the next best movement to reach the target the fastest
    function findPathToPos(map as Map, start_pos as Point2D, end_pos as Point2D) as Point2D? {
        return findPathToAnyPos(map, start_pos, [end_pos]);
    }

    // Find the next best movement to reach any target position the fastest
    function findPathToAnyPos(map as Map, start_pos as Point2D, end_positions as Array<Point2D>) as Point2D? {
        var start_num = toIntPoint2D(start_pos);
        
        var target_dict = {} as Dictionary<Number, Boolean>;
        for (var i = 0; i < end_positions.size(); i++) {
            target_dict[toIntPoint2D(end_positions[i])] = true;
        }

        if (target_dict.size() == 0) {
            return null;
        }

        var open_queue = [] as Array;  // Priority Queue
        var closed_dict = {} as Dictionary<Number, Boolean>;
        var g_score = {} as Dictionary<Number, Number>;
        var came_from = {} as Dictionary<Number, Number>;

        g_score[start_num] = 0;
        
        // Initiale Heuristik für alle Ziele
        var min_h = 999999;
        var keys = target_dict.keys();
        for (var i = 0; i < keys.size(); i++) {
            var h = manhattanHeuristic(start_num, keys[i]);
            if (h < min_h) {
                min_h = h;
            }
        }
        pq_enqueue(open_queue, min_h, start_num);

        var max_iterations = 200;
        var iterations = 0;
        while (open_queue.size() > 0) {
            iterations += 1;
            if (iterations > max_iterations) {
                return null;
            }
            var current = pq_dequeue(open_queue);
            
            if (target_dict.hasKey(current)) {
                return fromIntPoint2D(reconstructPathFast(came_from, current));
            }

            closed_dict[current] = true;

            var neighbors = getNeighbors(map, current);
            for (var i = 0; i < neighbors.size(); i++) {
                var neighbor = neighbors[i] as Number;
                if (closed_dict[neighbor] != null) {
                    continue;
                }

                var tentative_g_score = g_score[current] + 1;
                var hasKey = g_score[neighbor] != null;
                if (!hasKey || tentative_g_score < g_score[neighbor]) {
                    came_from[neighbor] = current;
                    g_score[neighbor] = tentative_g_score;
                    
                    // Berechne f_score = g + h
                    var best_h = 999999;
                    var tkeys = target_dict.keys();
                    for (var j = 0; j < tkeys.size(); j++) {
                        var h = manhattanHeuristic(neighbor, tkeys[j]);
                        if (h < best_h) {
                            best_h = h;
                        }
                    }
                    var f_score = tentative_g_score + best_h;
                    
                    pq_enqueue(open_queue, f_score, neighbor);
                }
            }
        }

        return null;
    }

    // Gibt den ERSTEN Schritt vom Start aus zurück (kein Array nötig)
    function reconstructPathFast(came_from as Dictionary<Number, Number>, current as Number) as Number {
        while (came_from[current] != null) {
            var prev = current;
            current = came_from[current];
            if (came_from[current] == null) {
                // current ist der Start → prev ist der erste Schritt
                return prev;
            }
        }
        return current;  // Start = Ziel → direkt dort
    }

    // Gibt den kompletten Pfad als Array zurück (Start → Ende)
    function findFullPathToPos(map as Map, start_pos as Point2D, end_pos as Point2D) as Array<Number>? {
        var start_num = toIntPoint2D(start_pos);
        var end_num = toIntPoint2D(end_pos);
        
        var open_queue = [] as Array;
        var closed_dict = {} as Dictionary<Number, Boolean>;
        var g_score = {} as Dictionary<Number, Number>;
        var came_from = {} as Dictionary<Number, Number>;
        
        g_score[start_num] = 0;
        pq_enqueue(open_queue, manhattanHeuristic(start_num, end_num), start_num);
        
        var max_iterations = 200;
        var iterations = 0;
        while (open_queue.size() > 0) {
            iterations += 1;
            if (iterations > max_iterations) {
                return null;
            }
            var current = pq_dequeue(open_queue);
            
            if (current == end_num) {
                // Pfad rekonstruieren
                var path = [] as Array<Number>;
                var c = current;
                path.add(c);
                while (came_from[c] != null) {
                    c = came_from[c];
                    path.add(c);
                }
                // Pfad umkehren (Start → Ende)
                var reversed = [] as Array<Number>;
                for (var i = path.size() - 1; i >= 0; i--) {
                    reversed.add(path[i]);
                }
                return reversed;
            }
            
            closed_dict[current] = true;
            
            var neighbors = getNeighbors(map, current);
            for (var i = 0; i < neighbors.size(); i++) {
                var neighbor = neighbors[i] as Number;
                if (closed_dict[neighbor] != null) {
                    continue;
                }
                
                var tentative_g = g_score[current] + 1;
                var hasKey = g_score[neighbor] != null;
                if (!hasKey || tentative_g < g_score[neighbor]) {
                    came_from[neighbor] = current;
                    g_score[neighbor] = tentative_g;
                    pq_enqueue(open_queue, tentative_g + manhattanHeuristic(neighbor, end_num), neighbor);
                }
            }
        }
        return null;
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

        // EINMAL A* ausführen
        var path = findFullPathToPos(map, pos, player_pos);
        if (path == null || path.size() < 2) {
            return null;
        }

        // Die ersten max_steps Schritte nehmen
        var step = max_steps < path.size() ? max_steps : path.size() - 1;
        return fromIntPoint2D(path[step]);
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
