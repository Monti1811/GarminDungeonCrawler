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
    function findPathToPos(map as Array<Array<Object?>>, start_pos as Point2D, end_pos as Point2D) as Point2D? {
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


    function getNeighbors(map as Array<Array<Object?>>, pos_num as Number) as Array<Number> {
        var neighbors = [];
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

	function findSimplePathToPos(map as Array<Array<Object?>>, start_pos as Point2D, end_pos as Point2D) as Point2D? {
		var current_pos = start_pos;
		var x_diff = end_pos[0] - current_pos[0];
		var y_diff = end_pos[1] - current_pos[1];
		if (MathUtil.abs(x_diff) > MathUtil.abs(y_diff)) {
			if (x_diff > 0) {
				current_pos = [current_pos[0] + 1, current_pos[1]];
			} else {
				current_pos = [current_pos[0] - 1, current_pos[1]];
			}
		} else {
			if (y_diff > 0) {
				current_pos = [current_pos[0], current_pos[1] + 1];
			} else {
				current_pos = [current_pos[0], current_pos[1] - 1];
			}
		}
		if (MapUtil.canMoveToPlayer(map, current_pos) || MapUtil.canMoveToPoint(map, current_pos)) {
			return current_pos;
		}
		return null;
	}
}