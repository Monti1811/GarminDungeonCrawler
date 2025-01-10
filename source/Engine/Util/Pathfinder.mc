import Toybox.Lang;
import Toybox.Math;

module Pathfinder {

	// Find the next best movement to reach the target the fastest
	function findNextMove(map as Array<Array<Object?>>, start_pos as Point2D, end_pos as Point2D) as Point2D? {
		var open_list = [start_pos];
		var closed_list = [];
		var g_score = {} as Dictionary<Point2D, Number>;
		var f_score = {} as Dictionary<Point2D, Number>;
		var came_from = {} as Dictionary<Point2D, Point2D>;
		g_score[start_pos] = 0;
		f_score[start_pos] = g_score[start_pos] + heuristic(start_pos, end_pos);

		while (open_list.size() > 0) {
			var current = getLowestF(open_list, f_score);
			if (current == end_pos) {
				return reconstructPath(came_from, current);
			}

			open_list.remove(current);
			closed_list.add(current);

			var neighbors = getNeighbors(map, current);
			for (var i = 0; i < neighbors.size(); i++) {
				var neighbor = neighbors[i] as Point2D;
				if (closed_list.indexOf(neighbor) != null) {
					continue;
				}

				var tentative_g_score = g_score[current] + 1;
				if (!(open_list.indexOf(neighbor) != null) || tentative_g_score < g_score[neighbor]) {
					came_from[neighbor] = current;
					g_score[neighbor] = tentative_g_score;
					f_score[neighbor] = g_score[neighbor] + heuristic(neighbor, end_pos);
					if (!open_list.indexOf(neighbor) != null) {
						open_list.add(neighbor);
					}
				}
			}
		}

		return null;
	}

	function getLowestF(open_list as Array<Point2D>, f_score as Dictionary<Point2D, Number>) as Point2D {
		var lowest = open_list[0];
		for (var i = 1; i < open_list.size(); i++) {
			if (f_score[open_list[i]] < f_score[lowest]) {
				lowest = open_list[i];
			}
		}
		return lowest;
	}

	function heuristic(start_pos as Point2D, end_pos as Point2D) as Number {
		return MathUtil.abs(start_pos[0] - end_pos[0]) + MathUtil.abs(start_pos[1] - end_pos[1]);
	}

	function getNeighbors(map as Array<Array<Object?>>, pos as Point2D) as Array<Point2D> {
		var neighbors = [];
		if (pos[0] > 0 && MapUtil.canMoveToPoint(map, [pos[0] - 1, pos[1]])) {
			neighbors.add([pos[0] - 1, pos[1]]);
		}
		if (pos[0] < map.size() - 1 && MapUtil.canMoveToPoint(map, [pos[0] + 1, pos[1]])) {
			neighbors.add([pos[0] + 1, pos[1]]);
		}
		if (pos[1] > 0 && MapUtil.canMoveToPoint(map, [pos[0], pos[1] - 1])) {
			neighbors.add([pos[0], pos[1] - 1]);
		}
		if (pos[1] < map[0].size() - 1 && MapUtil.canMoveToPoint(map, [pos[0], pos[1] + 1])) {
			neighbors.add([pos[0], pos[1] + 1]);
		}
		return neighbors;
	}

	function reconstructPath(came_from as Dictionary<Point2D, Point2D>, current as Point2D) as Point2D? {
		var path = current;
		while (came_from[current] != null) {
			current = came_from[current];
			path.add(current);
		}
		return path;
	}
}