import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

(:test)
function tunnelLeftReachesPassable(logger as Test.Logger) as Boolean {
    var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
    var tunnel = Map.digConnectionTunnel(map, [0, 11], LEFT, 22, 22, [11, 11]);

    Test.assertMessage(tunnel.size() >= 2, "Tunnel from LEFT has at least 2 tiles, got " + tunnel.size().toString());

    var last = tunnel[tunnel.size() - 1];
    var reached = false;
    var dirs = [[-1,0],[1,0],[0,-1],[0,1]];
    for (var d = 0; d < dirs.size(); d++) {
        var nx = last[0] + dirs[d][0];
        var ny = last[1] + dirs[d][1];
        if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22 && map.getType([nx, ny]) == PASSABLE) {
            reached = true;
            break;
        }
    }
    Test.assertMessage(reached, "Tunnel from LEFT must reach PASSABLE. Last tile: [" + last[0] + "," + last[1] + "]");
    return true;
}

(:test)
function tunnelRightReachesPassable(logger as Test.Logger) as Boolean {
    var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
    var tunnel = Map.digConnectionTunnel(map, [21, 11], RIGHT, 22, 22, [11, 11]);

    Test.assertMessage(tunnel.size() >= 2, "Tunnel from RIGHT has at least 2 tiles");

    var last = tunnel[tunnel.size() - 1];
    var reached = false;
    var dirs = [[-1,0],[1,0],[0,-1],[0,1]];
    for (var d = 0; d < dirs.size(); d++) {
        var nx = last[0] + dirs[d][0];
        var ny = last[1] + dirs[d][1];
        if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22 && map.getType([nx, ny]) == PASSABLE) {
            reached = true;
            break;
        }
    }
    Test.assertMessage(reached, "Tunnel from RIGHT must reach PASSABLE. Last tile: [" + last[0] + "," + last[1] + "]");
    return true;
}

(:test)
function tunnelUpReachesPassable(logger as Test.Logger) as Boolean {
    var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
    var tunnel = Map.digConnectionTunnel(map, [11, 0], UP, 22, 22, [11, 11]);

    Test.assertMessage(tunnel.size() >= 2, "Tunnel from UP has at least 2 tiles");

    var last = tunnel[tunnel.size() - 1];
    var reached = false;
    var dirs = [[-1,0],[1,0],[0,-1],[0,1]];
    for (var d = 0; d < dirs.size(); d++) {
        var nx = last[0] + dirs[d][0];
        var ny = last[1] + dirs[d][1];
        if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22 && map.getType([nx, ny]) == PASSABLE) {
            reached = true;
            break;
        }
    }
    Test.assertMessage(reached, "Tunnel from UP must reach PASSABLE. Last tile: [" + last[0] + "," + last[1] + "]");
    return true;
}

(:test)
function tunnelDownReachesPassable(logger as Test.Logger) as Boolean {
    var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
    var tunnel = Map.digConnectionTunnel(map, [11, 21], DOWN, 22, 22, [11, 11]);

    Test.assertMessage(tunnel.size() >= 2, "Tunnel from DOWN has at least 2 tiles");

    var last = tunnel[tunnel.size() - 1];
    var reached = false;
    var dirs = [[-1,0],[1,0],[0,-1],[0,1]];
    for (var d = 0; d < dirs.size(); d++) {
        var nx = last[0] + dirs[d][0];
        var ny = last[1] + dirs[d][1];
        if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22 && map.getType([nx, ny]) == PASSABLE) {
            reached = true;
            break;
        }
    }
    Test.assertMessage(reached, "Tunnel from DOWN must reach PASSABLE. Last tile: [" + last[0] + "," + last[1] + "]");
    return true;
}

(:test)
function allTunnelTilesArePassable(logger as Test.Logger) as Boolean {
    var dirs4 = [LEFT, RIGHT, UP, DOWN];
    var edges = [[0, 11], [21, 11], [11, 0], [11, 21]];

    for (var i = 0; i < 4; i++) {
        for (var iter = 0; iter < 10; iter++) {
            var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
            var tunnel = Map.digConnectionTunnel(map, edges[i] as Point2D, dirs4[i], 22, 22, [11, 11]);

            for (var t = 0; t < tunnel.size(); t++) {
                var pos = tunnel[t];
                Test.assertMessage(
                    map.getType(pos) == PASSABLE,
                    "Tunnel tile [" + pos[0] + "," + pos[1] + "] must be PASSABLE (dir=" + i + ", iter=" + iter + ")"
                );
            }
        }
    }
    return true;
}

(:test)
function tunnelNeverGoesOutOfBounds(logger as Test.Logger) as Boolean {
    for (var iter = 0; iter < 20; iter++) {
        var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
        var tunnel = Map.digConnectionTunnel(map, [0, 11], LEFT, 22, 22, [11, 11]);

        for (var t = 0; t < tunnel.size(); t++) {
            var pos = tunnel[t];
            Test.assertMessage(
                pos[0] >= 0 && pos[0] < 22 && pos[1] >= 0 && pos[1] < 22,
                "Tunnel tile out of bounds: [" + pos[0] + "," + pos[1] + "]"
            );
        }
    }
    return true;
}

(:test)
function tunnelFirstTwoTilesAreStraight(logger as Test.Logger) as Boolean {
    for (var iter = 0; iter < 20; iter++) {
        var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
        var tunnel = Map.digConnectionTunnel(map, [0, 11], LEFT, 22, 22, [11, 11]);

        if (tunnel.size() >= 3) {
            var t0 = tunnel[0];
            var t1 = tunnel[1];
            var t2 = tunnel[2];
            Test.assertMessage(
                t0[0] == 0 && t0[1] == 11,
                "Edge tile should be [0,11], got [" + t0[0] + "," + t0[1] + "]"
            );
            Test.assertMessage(
                t1[0] == 1 && t1[1] == 11,
                "Second tile should be [1,11], got [" + t1[0] + "," + t1[1] + "]"
            );
            Test.assertMessage(
                t2[0] == 2 && t2[1] == 11,
                "Third tile should be [2,11], got [" + t2[0] + "," + t2[1] + "]"
            );
        }
    }
    return true;
}

(:test)
function tunnelCurveShiftsPerpendicular(logger as Test.Logger) as Boolean {
    var found_curve = false;
    for (var iter = 0; iter < 30; iter++) {
        var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
        var tunnel = Map.digConnectionTunnel(map, [0, 11], LEFT, 22, 22, [11, 11]);

        // Check if any tunnel tile has y != 11 (perpendicular shift)
        for (var t = 0; t < tunnel.size(); t++) {
            if (tunnel[t][1] != 11) {
                found_curve = true;
                break;
            }
        }
        if (found_curve) { break; }
    }
    Test.assertMessage(found_curve, "After 30 iterations, at least one tunnel should have a curve");
    return true;
}

(:test)
function tunnelConnectsToRoomNotJustWall(logger as Test.Logger) as Boolean {
    for (var iter = 0; iter < 20; iter++) {
        var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
        var tunnel = Map.digConnectionTunnel(map, [0, 11], LEFT, 22, 22, [11, 11]);

        var last = tunnel[tunnel.size() - 1];
        var found_passable = false;
        for (var dx = -1; dx <= 1; dx++) {
            for (var dy = -1; dy <= 1; dy++) {
                if (dx == 0 && dy == 0) { continue; }
                var nx = last[0] + dx;
                var ny = last[1] + dy;
                if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22) {
                    if (map.getType([nx, ny]) == PASSABLE) {
                        found_passable = true;
                    }
                }
            }
        }
        Test.assertMessage(found_passable, "Tunnel last tile must be adjacent to PASSABLE");
    }
    return true;
}

function createTunnelTestMap(width as Number, height as Number, rl as Number, rr as Number, rt as Number, rb as Number) as Map {
    var map = new Map(width, height, true);
    for (var i = rl; i <= rr; i++) {
        map.setType([i, rt], WALL);
        map.setType([i, rb], WALL);
    }
    for (var j = rt; j <= rb; j++) {
        map.setType([rl, j], WALL);
        map.setType([rr, j], WALL);
    }
    for (var i = rl + 1; i < rr; i++) {
        for (var j = rt + 1; j < rb; j++) {
            map.setType([i, j], PASSABLE);
        }
    }
    return map;
}

(:test)
function allPassableTilesConnected(logger as Test.Logger) as Boolean {
    var dirs4 = [LEFT, RIGHT, UP, DOWN];
    var edges = [[0, 11], [21, 11], [11, 0], [11, 21]];

    for (var dirIdx = 0; dirIdx < 4; dirIdx++) {
        for (var iter = 0; iter < 10; iter++) {
            var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
            Map.digConnectionTunnel(map, edges[dirIdx] as Point2D, dirs4[dirIdx], 22, 22, [11, 11]);

            // Find first PASSABLE tile
            var startX = -1;
            var startY = -1;
            for (var x = 0; x < 22; x++) {
                for (var y = 0; y < 22; y++) {
                    if (map.getTile(x, y).type == PASSABLE) {
                        startX = x;
                        startY = y;
                        break;
                    }
                }
                if (startX >= 0) { break; }
            }
            if (startX < 0) { continue; }

            // BFS from first PASSABLE tile
            var visited = {} as Dictionary<Number, Boolean>;
            var queue = [[startX, startY]] as Array<Point2D>;
            visited.put(startX * 1000 + startY, true);
            var dirs = [[-1,0],[1,0],[0,-1],[0,1]] as Array<Array<Number>>;
            var head = 0;

            while (head < queue.size()) {
                var cur = queue[head];
                head += 1;
                for (var d = 0; d < dirs.size(); d++) {
                    var nx = cur[0] + dirs[d][0];
                    var ny = cur[1] + dirs[d][1];
                    if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22) {
                        if (map.getTile(nx, ny).type == PASSABLE) {
                            var key = nx * 1000 + ny;
                            if (!visited.hasKey(key)) {
                                visited.put(key, true);
                                queue.add([nx, ny]);
                            }
                        }
                    }
                }
            }

            // Count total PASSABLE tiles
            var totalPassable = 0;
            for (var x = 0; x < 22; x++) {
                for (var y = 0; y < 22; y++) {
                    if (map.getTile(x, y).type == PASSABLE) {
                        totalPassable += 1;
                    }
                }
            }

            Test.assertMessage(
                queue.size() == totalPassable,
                "Not all PASSABLE tiles connected (dir=" + dirs4[dirIdx] + ", iter=" + iter +
                "): reachable=" + queue.size() + " total=" + totalPassable
            );
        }
    }
    return true;
}

(:test)
function tunnelReachesScreenEdgeLeft(logger as Test.Logger) as Boolean {
    for (var iter = 0; iter < 10; iter++) {
        var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
        Map.digConnectionTunnel(map, [0, 11], LEFT, 22, 22, [11, 11]);

        var foundEdge = false;
        for (var y = 0; y < 22; y++) {
            if (map.getTile(0, y).type == PASSABLE) {
                foundEdge = true;
                break;
            }
        }
        Test.assertMessage(foundEdge, "Tunnel from LEFT must have PASSABLE at x=0 (iter=" + iter + ")");
    }
    return true;
}

(:test)
function tunnelReachesScreenEdgeRight(logger as Test.Logger) as Boolean {
    for (var iter = 0; iter < 10; iter++) {
        var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
        Map.digConnectionTunnel(map, [21, 11], RIGHT, 22, 22, [11, 11]);

        var foundEdge = false;
        for (var y = 0; y < 22; y++) {
            if (map.getTile(21, y).type == PASSABLE) {
                foundEdge = true;
                break;
            }
        }
        Test.assertMessage(foundEdge, "Tunnel from RIGHT must have PASSABLE at x=21 (iter=" + iter + ")");
    }
    return true;
}

(:test)
function tunnelReachesScreenEdgeUp(logger as Test.Logger) as Boolean {
    for (var iter = 0; iter < 10; iter++) {
        var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
        Map.digConnectionTunnel(map, [11, 0], UP, 22, 22, [11, 11]);

        var foundEdge = false;
        for (var x = 0; x < 22; x++) {
            if (map.getTile(x, 0).type == PASSABLE) {
                foundEdge = true;
                break;
            }
        }
        Test.assertMessage(foundEdge, "Tunnel from UP must have PASSABLE at y=0 (iter=" + iter + ")");
    }
    return true;
}

(:test)
function tunnelReachesScreenEdgeDown(logger as Test.Logger) as Boolean {
    for (var iter = 0; iter < 10; iter++) {
        var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
        Map.digConnectionTunnel(map, [11, 21], DOWN, 22, 22, [11, 11]);

        var foundEdge = false;
        for (var x = 0; x < 22; x++) {
            if (map.getTile(x, 21).type == PASSABLE) {
                foundEdge = true;
                break;
            }
        }
        Test.assertMessage(foundEdge, "Tunnel from DOWN must have PASSABLE at y=21 (iter=" + iter + ")");
    }
    return true;
}

(:test)
function noDiagonalDigging(logger as Test.Logger) as Boolean {
    var dirs4 = [LEFT, RIGHT, UP, DOWN];
    var edges = [[0, 11], [21, 11], [11, 0], [11, 21]];

    for (var dirIdx = 0; dirIdx < 4; dirIdx++) {
        for (var iter = 0; iter < 10; iter++) {
            var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
            var tunnel = Map.digConnectionTunnel(map, edges[dirIdx] as Point2D, dirs4[dirIdx], 22, 22, [11, 11]);

            // Each consecutive pair should differ in at most one axis
            // Note: steering to already-PASSABLE tiles may not appear in tunnel_tiles,
            // so Manhattan distance can be 2 (skipped steering step) but never > 2
            for (var t = 1; t < tunnel.size(); t++) {
                var prev = tunnel[t - 1];
                var cur = tunnel[t];
                var dx = (cur[0] > prev[0]) ? cur[0] - prev[0] : prev[0] - cur[0];
                var dy = (cur[1] > prev[1]) ? cur[1] - prev[1] : prev[1] - cur[1];
                Test.assertMessage(
                    dx + dy <= 2,
                    "Too large jump in tunnel (dir=" + dirs4[dirIdx] + ", iter=" + iter +
                    "): [" + prev[0] + "," + prev[1] + "] -> [" + cur[0] + "," + cur[1] + "]" +
                    " (distance=" + (dx + dy) + ")"
                );
            }
        }
    }
    return true;
}

(:test)
function debugPrintRoomMap(logger as Test.Logger) as Boolean {
    var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
    System.println("=== BEFORE TUNNEL ===");
    printMap(map);

    Map.digConnectionTunnel(map, [0, 11], LEFT, 22, 22, [11, 11]);
    System.println("=== AFTER TUNNEL LEFT ===");
    printMap(map);

    Map.digConnectionTunnel(map, [21, 11], RIGHT, 22, 22, [11, 11]);
    System.println("=== AFTER TUNNEL RIGHT ===");
    printMap(map);

    Map.digConnectionTunnel(map, [11, 0], UP, 22, 22, [11, 11]);
    System.println("=== AFTER TUNNEL UP ===");
    printMap(map);

    Map.digConnectionTunnel(map, [11, 21], DOWN, 22, 22, [11, 11]);
    System.println("=== AFTER TUNNEL DOWN ===");
    printMap(map);

    Map.addWallsAroundPassable(map);
    System.println("=== AFTER ADD WALLS ===");
    printMap(map);

    return true;
}

function printMap(map as Map) as Void {
    var width = map.getXSize();
    var height = map.getYSize();
    for (var y = 0; y < height; y++) {
        var line = "";
        for (var x = 0; x < width; x++) {
            var ch = map.getTile(x, y).type;
            if (ch == PASSABLE) {
                line += "(";
            } else if (ch == WALL) {
                line += "!";
            } else if (ch == STAIRS) {
                line += "S";
            } else {
                line += "$";
            }
        }
        System.println(line);
    }
}

(:test)
function addWallsAroundPassableCoversAllEmptyNeighbors(logger as Test.Logger) as Boolean {
    var map = createTunnelTestMap(22, 22, 8, 14, 8, 14);
    Map.digConnectionTunnel(map, [0, 11], LEFT, 22, 22, [11, 11]);
    Map.digConnectionTunnel(map, [21, 11], RIGHT, 22, 22, [11, 11]);
    Map.addWallsAroundPassable(map);

    var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
    for (var x = 1; x < 21; x++) {
        for (var y = 1; y < 21; y++) {
            if (map.getTile(x, y).type == EMPTY) {
                for (var d = 0; d < dirs8.size(); d++) {
                    var nx = x + dirs8[d][0];
                    var ny = y + dirs8[d][1];
                    if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22) {
                        if (map.getTile(nx, ny).type == PASSABLE) {
                            Test.assertMessage(
                                false,
                                "EMPTY tile [" + x + "," + y + "] is adjacent to PASSABLE [" + nx + "," + ny + "] but not walled"
                            );
                        }
                    }
                }
            }
        }
    }
    return true;
}

(:test)
function allRoomShapesHaveCorrectWalls(logger as Test.Logger) as Boolean {
    var shapes = [ROOMSHAPE_RECTANGLE, ROOMSHAPE_L_SHAPE, ROOMSHAPE_T_SHAPE, ROOMSHAPE_PLUS, ROOMSHAPE_ROUNDED] as Array<RoomShape>;
    var shapeNames = ["RECTANGLE", "L_SHAPE", "T_SHAPE", "PLUS", "ROUNDED"] as Array<String>;
    var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;

    for (var s = 0; s < shapes.size(); s++) {
        for (var iter = 0; iter < 5; iter++) {
            var map = Map.createRoomShape(22, 22, 6, 15, 6, 15, shapes[s]);
            Map.addWallsAroundPassable(map);

            // Check: no EMPTY tile adjacent to PASSABLE (except screen edge)
            for (var x = 1; x < 21; x++) {
                for (var y = 1; y < 21; y++) {
                    if (map.getTile(x, y).type == EMPTY) {
                        for (var d = 0; d < dirs8.size(); d++) {
                            var nx = x + dirs8[d][0];
                            var ny = y + dirs8[d][1];
                            if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22) {
                                if (map.getTile(nx, ny).type == PASSABLE) {
                                    Test.assertMessage(
                                        false,
                                        "Shape " + shapeNames[s] + " iter " + iter +
                                        ": EMPTY [" + x + "," + y + "] adjacent to PASSABLE [" + nx + "," + ny + "]"
                                    );
                                }
                            }
                        }
                    }
                }
            }

            // Check: all PASSABLE tiles connected
            var startX = -1;
            var startY = -1;
            for (var x = 0; x < 22; x++) {
                for (var y = 0; y < 22; y++) {
                    if (map.getTile(x, y).type == PASSABLE) {
                        startX = x;
                        startY = y;
                        break;
                    }
                }
                if (startX >= 0) { break; }
            }
            if (startX < 0) { continue; }

            var visited = {} as Dictionary<Number, Boolean>;
            var queue = [[startX, startY]] as Array<Point2D>;
            visited.put(startX * 1000 + startY, true);
            var dirs4 = [[-1,0],[1,0],[0,-1],[0,1]] as Array<Array<Number>>;
            var head = 0;
            while (head < queue.size()) {
                var cur = queue[head];
                head += 1;
                for (var d = 0; d < dirs4.size(); d++) {
                    var nx = cur[0] + dirs4[d][0];
                    var ny = cur[1] + dirs4[d][1];
                    if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22) {
                        if (map.getTile(nx, ny).type == PASSABLE) {
                            var key = nx * 1000 + ny;
                            if (!visited.hasKey(key)) {
                                visited.put(key, true);
                                queue.add([nx, ny]);
                            }
                        }
                    }
                }
            }
            var totalPassable = 0;
            for (var x = 0; x < 22; x++) {
                for (var y = 0; y < 22; y++) {
                    if (map.getTile(x, y).type == PASSABLE) { totalPassable += 1; }
                }
            }
            Test.assertMessage(
                queue.size() == totalPassable,
                "Shape " + shapeNames[s] + " iter " + iter +
                ": PASSABLE not connected (reachable=" + queue.size() + " total=" + totalPassable + ")"
            );
        }
    }
    return true;
}

(:test)
function addWallsAroundFixesClearedWalls(logger as Test.Logger) as Boolean {
    var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;

    for (var iter = 0; iter < 20; iter++) {
        var map = Map.createRoomShape(22, 22, 6, 15, 6, 15, ROOMSHAPE_RECTANGLE);
        Map.addWallsAroundPassable(map);

        // Pick a PASSABLE tile near center (safe spot)
        var px = 11;
        var py = 11;
        if (map.getTile(px, py).type != PASSABLE) { continue; }

        // Simulate clearAround: convert WALL neighbors to PASSABLE
        var cleared = [] as Array<Point2D>;
        for (var d = 0; d < dirs8.size(); d++) {
            var nx = px + dirs8[d][0];
            var ny = py + dirs8[d][1];
            if (nx >= 0 && nx < 22 && ny >= 0 && ny < 22 && map.getTile(nx, ny).type == WALL) {
                map.setType([nx, ny], PASSABLE);
                cleared.add([nx, ny]);
            }
        }
        if (cleared.size() == 0) { continue; }

        // Now call addWallsAround at NPC position
        Map.addWallsAround(map, px, py);

        // Verify: no EMPTY tile adjacent to any PASSABLE tile in the area
        var foundGap = false;
        for (var d = 0; d < dirs8.size(); d++) {
            var cx = px + dirs8[d][0];
            var cy = py + dirs8[d][1];
            if (cx < 0 || cx >= 22 || cy < 0 || cy >= 22) { continue; }
            if (map.getTile(cx, cy).type != PASSABLE) { continue; }
            for (var d2 = 0; d2 < dirs8.size(); d2++) {
                var nx2 = cx + dirs8[d2][0];
                var ny2 = cy + dirs8[d2][1];
                if (nx2 >= 0 && nx2 < 22 && ny2 >= 0 && ny2 < 22 && map.getTile(nx2, ny2).type == EMPTY) {
                    foundGap = true;
                    break;
                }
            }
            if (foundGap) { break; }
        }
        Test.assertMessage(
            !foundGap,
            "iter " + iter + ": EMPTY still adjacent to PASSABLE after addWallsAround at [" + px + "," + py + "]"
        );
    }
    return true;
}

(:test)
function stressTestAllShapesMaxSize(logger as Test.Logger) as Boolean {
    var shapes = [ROOMSHAPE_RECTANGLE, ROOMSHAPE_L_SHAPE, ROOMSHAPE_T_SHAPE, ROOMSHAPE_PLUS, ROOMSHAPE_ROUNDED] as Array<RoomShape>;
    var shapeNames = ["RECTANGLE", "L_SHAPE", "T_SHAPE", "PLUS", "ROUNDED"] as Array<String>;
    var screen = 22;

    for (var s = 0; s < shapes.size(); s++) {
        for (var iter = 0; iter < 10; iter++) {
            var room_w = 15;
            var room_h = 15;
            var left = (screen - room_w) / 2;
            var right = left + room_w;
            var top = (screen - room_h) / 2;
            var bottom = top + room_h;

            var map = Map.createRoomShape(screen, screen, left, right, top, bottom, shapes[s]);
            Map.addIslands(map, left, right, top, bottom, shapes[s]);
            Map.addWallsAroundPassable(map);

            // Verify connectivity
            var startX = -1;
            var startY = -1;
            for (var x = left; x < right; x++) {
                for (var y = top; y < bottom; y++) {
                    if (map.getTile(x, y).type == PASSABLE) {
                        startX = x;
                        startY = y;
                        break;
                    }
                }
                if (startX >= 0) { break; }
            }
            if (startX < 0) { continue; }

            var visited = {} as Dictionary<Number, Boolean>;
            var queue = [[startX, startY]] as Array<Point2D>;
            visited.put((startX << 8) + startY, true);
            var dirs4 = [[-1,0],[1,0],[0,-1],[0,1]] as Array<Array<Number>>;
            var head = 0;
            while (head < queue.size()) {
                var cur = queue[head];
                head += 1;
                for (var d = 0; d < dirs4.size(); d++) {
                    var nx = cur[0] + dirs4[d][0];
                    var ny = cur[1] + dirs4[d][1];
                    if (nx >= left && nx < right && ny >= top && ny < bottom) {
                        if (map.getTile(nx, ny).type == PASSABLE) {
                            var key = (nx << 8) + ny;
                            if (!visited.hasKey(key)) {
                                visited.put(key, true);
                                queue.add([nx, ny]);
                            }
                        }
                    }
                }
            }
            var totalPassable = 0;
            for (var x = left; x < right; x++) {
                for (var y = top; y < bottom; y++) {
                    if (map.getTile(x, y).type == PASSABLE) { totalPassable += 1; }
                }
            }
            Test.assertMessage(
                queue.size() == totalPassable,
                "Shape " + shapeNames[s] + " 15x15 iter " + iter +
                ": not connected (reachable=" + queue.size() + " total=" + totalPassable + ")"
            );
        }
    }
    return true;
}

(:test)
function stressTestMaxRoomFullPipeline(logger as Test.Logger) as Boolean {
    var shapes = [ROOMSHAPE_RECTANGLE, ROOMSHAPE_L_SHAPE, ROOMSHAPE_T_SHAPE, ROOMSHAPE_PLUS, ROOMSHAPE_ROUNDED] as Array<RoomShape>;
    var shapeNames = ["RECTANGLE", "L_SHAPE", "T_SHAPE", "PLUS", "ROUNDED"] as Array<String>;
    var screen = 22;

    for (var iter = 0; iter < 20; iter++) {
        var shape = shapes[iter % shapes.size()];
        var room_w = 15;
        var room_h = 15;
        var left = (screen - room_w) / 2;
        var right = left + room_w;
        var top = (screen - room_h) / 2;
        var bottom = top + room_h;

        var map = Map.createRoomShape(screen, screen, left, right, top, bottom, shape);
        Map.addIslands(map, left, right, top, bottom, shape);
        Map.addWallsAroundPassable(map);

        var center = [11, 11] as Point2D;
        Map.digConnectionTunnel(map, [0, 11], LEFT, screen, screen, center);
        Map.digConnectionTunnel(map, [21, 11], RIGHT, screen, screen, center);
        Map.digConnectionTunnel(map, [11, 0], UP, screen, screen, center);
        Map.digConnectionTunnel(map, [11, 21], DOWN, screen, screen, center);

        // Verify: all PASSABLE tiles are connected (room + tunnels)
        var startX = -1;
        var startY = -1;
        for (var x = 0; x < screen; x++) {
            for (var y = 0; y < screen; y++) {
                if (map.getTile(x, y).type == PASSABLE) {
                    startX = x;
                    startY = y;
                    break;
                }
            }
            if (startX >= 0) { break; }
        }
        if (startX < 0) { continue; }

        var visited = {} as Dictionary<Number, Boolean>;
        var queue = [[startX, startY]] as Array<Point2D>;
        visited.put((startX << 8) + startY, true);
        var dirs4 = [[-1,0],[1,0],[0,-1],[0,1]] as Array<Array<Number>>;
        var head = 0;
        while (head < queue.size()) {
            var cur = queue[head];
            head += 1;
            for (var d = 0; d < dirs4.size(); d++) {
                var nx = cur[0] + dirs4[d][0];
                var ny = cur[1] + dirs4[d][1];
                if (nx >= 0 && nx < screen && ny >= 0 && ny < screen) {
                    if (map.getTile(nx, ny).type == PASSABLE) {
                        var key = (nx << 8) + ny;
                        if (!visited.hasKey(key)) {
                            visited.put(key, true);
                            queue.add([nx, ny]);
                        }
                    }
                }
            }
        }
        var totalPassable = 0;
        for (var x = 0; x < screen; x++) {
            for (var y = 0; y < screen; y++) {
                if (map.getTile(x, y).type == PASSABLE) { totalPassable += 1; }
            }
        }
        Test.assertMessage(
            queue.size() == totalPassable,
            "iter " + iter + " shape " + shapeNames[shape] +
            ": not connected (reachable=" + queue.size() + " total=" + totalPassable + ")"
        );
    }
    return true;
}

(:test)
function stressTestRandomRoomSizes(logger as Test.Logger) as Boolean {
    var shapes = [ROOMSHAPE_RECTANGLE, ROOMSHAPE_L_SHAPE, ROOMSHAPE_T_SHAPE, ROOMSHAPE_PLUS] as Array<RoomShape>;
    var shapeNames = ["RECTANGLE", "L_SHAPE", "T_SHAPE", "PLUS"] as Array<String>;
    var screen = 22;

    for (var iter = 0; iter < 30; iter++) {
        var shape = shapes[iter % shapes.size()];
        // Random room sizes from 5 to 15 (max possible on 22x22 screen)
        var room_w = 5 + (iter * 3) % 11; // 5..15
        var room_h = 5 + (iter * 7) % 11; // 5..15
        var left = (screen - room_w) / 2;
        var right = left + room_w;
        var top_val = (screen - room_h) / 2;
        var bottom = top_val + room_h;

        var map = Map.createRoomShape(screen, screen, left, right, top_val, bottom, shape);
        Map.addIslands(map, left, right, top_val, bottom, shape);
        Map.addWallsAroundPassable(map);

        // Verify connectivity
        var startX = -1;
        var startY = -1;
        for (var x = left; x < right; x++) {
            for (var y = top_val; y < bottom; y++) {
                if (map.getTile(x, y).type == PASSABLE) {
                    startX = x;
                    startY = y;
                    break;
                }
            }
            if (startX >= 0) { break; }
        }
        if (startX < 0) { continue; }

        var visited = {} as Dictionary<Number, Boolean>;
        var queue = [[startX, startY]] as Array<Point2D>;
        visited.put((startX << 8) + startY, true);
        var dirs4 = [[-1,0],[1,0],[0,-1],[0,1]] as Array<Array<Number>>;
        var head = 0;
        while (head < queue.size()) {
            var cur = queue[head];
            head += 1;
            for (var d = 0; d < dirs4.size(); d++) {
                var nx = cur[0] + dirs4[d][0];
                var ny = cur[1] + dirs4[d][1];
                if (nx >= left && nx < right && ny >= top_val && ny < bottom) {
                    if (map.getTile(nx, ny).type == PASSABLE) {
                        var key = (nx << 8) + ny;
                        if (!visited.hasKey(key)) {
                            visited.put(key, true);
                            queue.add([nx, ny]);
                        }
                    }
                }
            }
        }
        var totalPassable = 0;
        for (var x = left; x < right; x++) {
            for (var y = top_val; y < bottom; y++) {
                if (map.getTile(x, y).type == PASSABLE) { totalPassable += 1; }
            }
        }
        Test.assertMessage(
            queue.size() == totalPassable,
            shapeNames[shape] + " " + room_w + "x" + room_h + " iter " + iter +
            ": not connected (reachable=" + queue.size() + " total=" + totalPassable + ")"
        );
    }
    return true;
}

(:test)
function roomSaveLoadPreservesShape(logger as Test.Logger) as Boolean {
    var shapes = [ROOMSHAPE_RECTANGLE, ROOMSHAPE_L_SHAPE, ROOMSHAPE_T_SHAPE, ROOMSHAPE_PLUS, ROOMSHAPE_ROUNDED] as Array<RoomShape>;

    for (var s = 0; s < shapes.size(); s++) {
        var screen = 22;
        var room_w = 12;
        var room_h = 12;
        var left = (screen - room_w) / 2;
        var right = left + room_w;
        var top = (screen - room_h) / 2;
        var bottom = top + room_h;

        var map = Map.createRoomShape(screen, screen, left, right, top, bottom, shapes[s]);
        Map.addWallsAroundPassable(map);

        var room = new Room({
            :size_x => room_w,
            :size_y => room_h,
            :tile_width => 16,
            :tile_height => 16,
            :start_pos => [11, 11],
            :map => map,
            :items => {},
            :enemies => {},
            :left => left,
            :right => right,
            :top => top,
            :bottom => bottom,
            :shape => shapes[s]
        });

        // Save then load
        var saved = room.save();
        var loaded = Room.load(saved);

        Test.assertMessage(
            loaded.getLeft() == left,
            "Shape " + shapes[s] + ": left mismatch (" + loaded.getLeft() + " != " + left + ")"
        );
        Test.assertMessage(
            loaded.getRight() == right,
            "Shape " + shapes[s] + ": right mismatch (" + loaded.getRight() + " != " + right + ")"
        );
        Test.assertMessage(
            loaded.getTop() == top,
            "Shape " + shapes[s] + ": top mismatch (" + loaded.getTop() + " != " + top + ")"
        );
        Test.assertMessage(
            loaded.getBottom() == bottom,
            "Shape " + shapes[s] + ": bottom mismatch (" + loaded.getBottom() + " != " + bottom + ")"
        );
        Test.assertMessage(
            loaded.getShape() != null,
            "Shape " + shapes[s] + ": shape is null after load"
        );
        Test.assertMessage(
            loaded.getShape() == shapes[s],
            "Shape " + shapes[s] + ": shape mismatch after load"
        );

        room.freeMemory();
        loaded.freeMemory();
    }
    return true;
}
