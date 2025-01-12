import Toybox.Lang;
import Toybox.Math;

module Pathfinder {

    // Find the next best movement to reach the target the fastest
    function findNextMove(map as Array<Array<Object?>>, start_pos as Point2D, end_pos as Point2D) as Point2D? {
        start_pos = Point2DObject.toPoint2D(start_pos);
        end_pos = Point2DObject.toPoint2D(end_pos);
        var open_list = [start_pos];
        var closed_list = [];
        var g_score = {} as Dictionary<Point2DObject, Number>;
        var came_from = {} as Dictionary<Point2DObject, Point2DObject>;
        g_score[start_pos] = 0;

        while (open_list.size() > 0) {
            var current = getLowestG(open_list, g_score);
            if (current == end_pos) {
                return reconstructPath(came_from, current);
            }

            open_list.remove(current);
            closed_list.add(current);

            var neighbors = getNeighbors(map, current);
            for (var i = 0; i < neighbors.size(); i++) {
                var neighbor = neighbors[i] as Point2DObject;
                if (contains(closed_list, neighbor)) {
                    continue;
                }

                var tentative_g_score = g_score[current] + 1;
                if (!contains(open_list, neighbor) || tentative_g_score < g_score[neighbor]) {
                    came_from[neighbor] = current;
                    g_score[neighbor] = tentative_g_score;
                    if (!contains(open_list, neighbor)) {
                        open_list.add(neighbor);
                    }
                }
            }
        }

        return null;
    }

    function contains(array as Array, element as Point2DObject) as Boolean {
        for (var i = 0; i < array.size(); i++) {
            if (array[i].equals(element)) {
                return true;
            }
        }
        return false;
    }

    function getLowestG(open_list as Array<Point2DObject>, g_score as Dictionary<Point2DObject, Number>) as Point2DObject {
        var lowest = open_list[0];
        for (var i = 1; i < open_list.size(); i++) {
            if (g_score[open_list[i]] < g_score[lowest]) {
                lowest = open_list[i];
            }
        }
        return lowest;
    }

    function getNeighbors(map as Array<Array<Object?>>, pos_obj as Point2DObject) as Array<Point2DObject> {
        var neighbors = [];
        var pos = [pos_obj.x, pos_obj.y];
        if (pos[0] > 0 && MapUtil.canMoveToPoint(map, [pos[0] - 1, pos[1]])) {
            neighbors.add(new Point2DObject(pos[0] - 1, pos[1]));
        }
        if (pos[0] < map.size() - 1 && MapUtil.canMoveToPoint(map, [pos[0] + 1, pos[1]])) {
            neighbors.add(new Point2DObject(pos[0] + 1, pos[1]));
        }
        if (pos[1] > 0 && MapUtil.canMoveToPoint(map, [pos[0], pos[1] - 1])) {
            neighbors.add(new Point2DObject(pos[0], pos[1] - 1));
        }
        if (pos[1] < map[0].size() - 1 && MapUtil.canMoveToPoint(map, [pos[0], pos[1] + 1])) {
            neighbors.add(new Point2DObject(pos[0], pos[1] + 1));
        }
        return neighbors;
    }

    function reconstructPath(came_from as Dictionary<Point2DObject, Point2DObject>, current as Point2DObject) as Point2DObject? {
        var path = current;
        while (came_from[current] != null) {
            current = came_from[current];
            path.add(current);
        }
        return path;
    }
}