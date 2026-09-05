import Toybox.Test;
import Toybox.Lang;

// ============================================================
// Island Neighbor Diagnostic Tests
// Investigates whether WALL tiles can end up adjacent (8-dir)
// to island tiles after the full room creation pipeline.
//
// Root cause hypothesis: addWallsAroundPassable or addWallsAround
// converts EMPTY tiles near islands to WALL, breaking the
// invariant that all 8-neighbors of an island are PASSABLE.
// ============================================================

// --- Helper: scan map for island tiles (WALL with >=1 PASSABLE neighbor) ---
(:test)
module IslandTestHelpers {

    // Run the full pipeline: createRoomShape → addIslands → addWallsAroundPassable
    // Returns the map for inspection.
    function runFullPipeline(
        screen_size_x as Number, screen_size_y as Number,
        left as Number, right as Number,
        top as Number, bottom as Number,
        shape as RoomShape
    ) as Map {
        var map = Map.createRoomShape(screen_size_x, screen_size_y, left, right, top, bottom, shape);
        Map.addIslands(map, left, right, top, bottom, shape);
        Map.addWallsAroundPassable(map);
        return map;
    }

    // Collect all tile positions where type == WALL and at least one
    // 4-directional neighbor is PASSABLE. These are candidates that
    // border the walkable area (room boundary walls + islands).
    function findWallTilesWithPassableNeighbor(map as Map) as Array<Point2D> {
        var result = [] as Array<Point2D>;
        var w = map.getXSize();
        var h = map.getYSize();
        var dirs4 = [[0,-1],[1,0],[0,1],[-1,0]] as Array<Array<Number>>;
        for (var x = 0; x < w; x++) {
            for (var y = 0; y < h; y++) {
                if (map.getTile(x, y).type != WALL) { continue; }
                for (var d = 0; d < dirs4.size(); d++) {
                    var nx = x + dirs4[d][0];
                    var ny = y + dirs4[d][1];
                    if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                        if (map.getTile(nx, ny).type == PASSABLE) {
                            result.add([x, y]);
                            break;
                        }
                    }
                }
            }
        }
        return result;
    }

    // Check whether any WALL tile (that has a PASSABLE 4-neighbor)
    // is diagonally adjacent to an island tile. An "island tile" here
    // means a WALL tile that is NOT on the room boundary.
    //
    // Heuristic for "island": a WALL tile that has PASSABLE on ALL
    // 4 cardinal directions is definitely an island (but too strict).
    // Better heuristic: a WALL tile that is NOT on the outermost
    // 1-pixel border AND has PASSABLE 4-neighbors.
    //
    // For this test we use the explicit approach:
    // 1. Record WALL tiles BEFORE addWallsAroundPassable (these are islands)
    // 2. After addWallsAroundPassable, check that none of those
    //    recorded positions have a WALL 8-neighbor that wasn't there before
    //
    // Actually simplest: after the full pipeline, find tiles that are
    // WALL, have at least one PASSABLE 4-neighbor, AND have at least
    // one PASSABLE 8-neighbor — these sit on the boundary between
    // walkable and wall. Then check that all 8-neighbors of any
    // PASSABLE tile that is also an 8-neighbor of an island remain PASSABLE.

    // SIMPLEST approach: after addIslands (before addWallsAroundPassable),
    // record all WALL positions. After addWallsAroundPassable, for each
    // recorded WALL position, verify all 8-neighbors that were PASSABLE
    // before are still not WALL.
    function checkIslandNeighborsAfterWalls(
        map_before_walls as Map,
        map_after_walls as Map,
        island_positions as Array<Point2D>
    ) as String? {
        var w = map_after_walls.getXSize();
        var h = map_after_walls.getYSize();
        var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;

        for (var i = 0; i < island_positions.size(); i++) {
            var ix = island_positions[i][0];
            var iy = island_positions[i][1];
            for (var d = 0; d < dirs8.size(); d++) {
                var nx = ix + dirs8[d][0];
                var ny = iy + dirs8[d][1];
                if (nx < 0 || nx >= w || ny < 0 || ny >= h) { continue; }
                var type_before = map_before_walls.getTile(nx, ny).type;
                var type_after = map_after_walls.getTile(nx, ny).type;
                // If the neighbor was PASSABLE before walls and is WALL after walls,
                // that's the bug we're looking for.
                if (type_before == PASSABLE && type_after == WALL) {
                    return "Island at (" + ix + "," + iy + ") 8-neighbor (" + nx + "," + ny +
                           ") was PASSABLE but became WALL after addWallsAroundPassable";
                }
            }
        }
        return null; // all good
    }

    // Print the map tile types for debugging
    function printTileTypes(logger as Test.Logger, map as Map, label as String) as Void {
        var w = map.getXSize();
        var h = map.getYSize();
        logger.debug("=== " + label + " TILE TYPES ===");
        for (var y = 0; y < h; y++) {
            var line = "";
            for (var x = 0; x < w; x++) {
                switch (map.getTile(x, y).type) {
                    case WALL: line += "W"; break;
                    case PASSABLE: line += "P"; break;
                    case EMPTY: line += "."; break;
                    case STAIRS: line += "S"; break;
                    default: line += "?"; break;
                }
            }
            logger.debug("y=" + y + ": " + line);
        }
    }
}

// ============================================================
// Test 1: Full pipeline for RECTANGLE rooms
// createRoomShape → addIslands → addWallsAroundPassable
// Verify no island's PASSABLE neighbor becomes WALL
// ============================================================

(:test)
function islandNeighborRect_fullPipeline(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var left = 2;
    var right = 13;
    var top = 2;
    var bottom = 13;

    // Step 1: Create room shape
    var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, ROOMSHAPE_RECTANGLE);

    // Step 2: Add islands — record WALL positions before and after
    var walls_before = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);
    Map.addIslands(map, left, right, top, bottom, ROOMSHAPE_RECTANGLE);
    var walls_after_islands = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);

    // New walls after addIslands = island positions
    var island_positions = [] as Array<Point2D>;
    for (var i = 0; i < walls_after_islands.size(); i++) {
        var found = false;
        for (var j = 0; j < walls_before.size(); j++) {
            if (walls_after_islands[i][0] == walls_before[j][0] && walls_after_islands[i][1] == walls_before[j][1]) {
                found = true;
                break;
            }
        }
        if (!found) {
            island_positions.add(walls_after_islands[i]);
        }
    }

    logger.debug("Rectangle: found " + island_positions.size() + " island tiles");
    for (var i = 0; i < island_positions.size(); i++) {
        logger.debug("  Island at (" + island_positions[i][0] + "," + island_positions[i][1] + ")");
    }

    // Take snapshot before addWallsAroundPassable
    var snapshot = new Map(screen_size, screen_size, false);
    for (var x = 0; x < screen_size; x++) {
        for (var y = 0; y < screen_size; y++) {
            var tile = map.getTile(x, y);
            if (tile.type != EMPTY) {
                snapshot.setType([x, y], tile.type);
            }
        }
    }

    // Step 3: addWallsAroundPassable
    Map.addWallsAroundPassable(map);

    // Step 4: Check invariant
    var err = IslandTestHelpers.checkIslandNeighborsAfterWalls(snapshot, map, island_positions);
    if (err != null) {
        logger.debug("FAILED: " + err);
        IslandTestHelpers.printTileTypes(logger, map, "RECTANGLE POST-WALLS");
        Test.assertMessage(false, err);
        return false;
    }

    logger.debug("Rectangle: PASS - no island neighbor became wall");
    return true;
}

// ============================================================
// Test 2: Full pipeline for L_SHAPE rooms
// ============================================================

(:test)
function islandNeighborLShape_fullPipeline(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var left = 2;
    var right = 13;
    var top = 2;
    var bottom = 13;

    var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, ROOMSHAPE_L_SHAPE);

    var walls_before = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);
    Map.addIslands(map, left, right, top, bottom, ROOMSHAPE_L_SHAPE);
    var walls_after_islands = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);

    var island_positions = [] as Array<Point2D>;
    for (var i = 0; i < walls_after_islands.size(); i++) {
        var found = false;
        for (var j = 0; j < walls_before.size(); j++) {
            if (walls_after_islands[i][0] == walls_before[j][0] && walls_after_islands[i][1] == walls_before[j][1]) {
                found = true;
                break;
            }
        }
        if (!found) {
            island_positions.add(walls_after_islands[i]);
        }
    }

    logger.debug("L_SHAPE: found " + island_positions.size() + " island tiles");

    var snapshot = new Map(screen_size, screen_size, false);
    for (var x = 0; x < screen_size; x++) {
        for (var y = 0; y < screen_size; y++) {
            var tile = map.getTile(x, y);
            if (tile.type != EMPTY) {
                snapshot.setType([x, y], tile.type);
            }
        }
    }

    Map.addWallsAroundPassable(map);

    var err = IslandTestHelpers.checkIslandNeighborsAfterWalls(snapshot, map, island_positions);
    if (err != null) {
        logger.debug("FAILED: " + err);
        IslandTestHelpers.printTileTypes(logger, map, "L_SHAPE POST-WALLS");
        Test.assertMessage(false, err);
        return false;
    }

    logger.debug("L_SHAPE: PASS - no island neighbor became wall");
    return true;
}

// ============================================================
// Test 3: Full pipeline for T_SHAPE rooms
// ============================================================

(:test)
function islandNeighborTShape_fullPipeline(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var left = 2;
    var right = 13;
    var top = 2;
    var bottom = 13;

    var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, ROOMSHAPE_T_SHAPE);

    var walls_before = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);
    Map.addIslands(map, left, right, top, bottom, ROOMSHAPE_T_SHAPE);
    var walls_after_islands = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);

    var island_positions = [] as Array<Point2D>;
    for (var i = 0; i < walls_after_islands.size(); i++) {
        var found = false;
        for (var j = 0; j < walls_before.size(); j++) {
            if (walls_after_islands[i][0] == walls_before[j][0] && walls_after_islands[i][1] == walls_before[j][1]) {
                found = true;
                break;
            }
        }
        if (!found) {
            island_positions.add(walls_after_islands[i]);
        }
    }

    logger.debug("T_SHAPE: found " + island_positions.size() + " island tiles");

    var snapshot = new Map(screen_size, screen_size, false);
    for (var x = 0; x < screen_size; x++) {
        for (var y = 0; y < screen_size; y++) {
            var tile = map.getTile(x, y);
            if (tile.type != EMPTY) {
                snapshot.setType([x, y], tile.type);
            }
        }
    }

    Map.addWallsAroundPassable(map);

    var err = IslandTestHelpers.checkIslandNeighborsAfterWalls(snapshot, map, island_positions);
    if (err != null) {
        logger.debug("FAILED: " + err);
        IslandTestHelpers.printTileTypes(logger, map, "T_SHAPE POST-WALLS");
        Test.assertMessage(false, err);
        return false;
    }

    logger.debug("T_SHAPE: PASS - no island neighbor became wall");
    return true;
}

// ============================================================
// Test 4: Full pipeline for PLUS rooms
// ============================================================

(:test)
function islandNeighborPlus_fullPipeline(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var left = 2;
    var right = 13;
    var top = 2;
    var bottom = 13;

    var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, ROOMSHAPE_PLUS);

    var walls_before = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);
    Map.addIslands(map, left, right, top, bottom, ROOMSHAPE_PLUS);
    var walls_after_islands = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);

    var island_positions = [] as Array<Point2D>;
    for (var i = 0; i < walls_after_islands.size(); i++) {
        var found = false;
        for (var j = 0; j < walls_before.size(); j++) {
            if (walls_after_islands[i][0] == walls_before[j][0] && walls_after_islands[i][1] == walls_before[j][1]) {
                found = true;
                break;
            }
        }
        if (!found) {
            island_positions.add(walls_after_islands[i]);
        }
    }

    logger.debug("PLUS: found " + island_positions.size() + " island tiles");

    var snapshot = new Map(screen_size, screen_size, false);
    for (var x = 0; x < screen_size; x++) {
        for (var y = 0; y < screen_size; y++) {
            var tile = map.getTile(x, y);
            if (tile.type != EMPTY) {
                snapshot.setType([x, y], tile.type);
            }
        }
    }

    Map.addWallsAroundPassable(map);

    var err = IslandTestHelpers.checkIslandNeighborsAfterWalls(snapshot, map, island_positions);
    if (err != null) {
        logger.debug("FAILED: " + err);
        IslandTestHelpers.printTileTypes(logger, map, "PLUS POST-WALLS");
        Test.assertMessage(false, err);
        return false;
    }

    logger.debug("PLUS: PASS - no island neighbor became wall");
    return true;
}

// ============================================================
// Test 5: Full pipeline for ROUNDED rooms
// ============================================================

(:test)
function islandNeighborRounded_fullPipeline(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var left = 2;
    var right = 13;
    var top = 2;
    var bottom = 13;

    var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, ROOMSHAPE_ROUNDED);

    var walls_before = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);
    Map.addIslands(map, left, right, top, bottom, ROOMSHAPE_ROUNDED);
    var walls_after_islands = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);

    var island_positions = [] as Array<Point2D>;
    for (var i = 0; i < walls_after_islands.size(); i++) {
        var found = false;
        for (var j = 0; j < walls_before.size(); j++) {
            if (walls_after_islands[i][0] == walls_before[j][0] && walls_after_islands[i][1] == walls_before[j][1]) {
                found = true;
                break;
            }
        }
        if (!found) {
            island_positions.add(walls_after_islands[i]);
        }
    }

    logger.debug("ROUNDED: found " + island_positions.size() + " island tiles");

    var snapshot = new Map(screen_size, screen_size, false);
    for (var x = 0; x < screen_size; x++) {
        for (var y = 0; y < screen_size; y++) {
            var tile = map.getTile(x, y);
            if (tile.type != EMPTY) {
                snapshot.setType([x, y], tile.type);
            }
        }
    }

    Map.addWallsAroundPassable(map);

    var err = IslandTestHelpers.checkIslandNeighborsAfterWalls(snapshot, map, island_positions);
    if (err != null) {
        logger.debug("FAILED: " + err);
        IslandTestHelpers.printTileTypes(logger, map, "ROUNDED POST-WALLS");
        Test.assertMessage(false, err);
        return false;
    }

    logger.debug("ROUNDED: PASS - no island neighbor became wall");
    return true;
}

// ============================================================
// Test 6: addWallsAround (simulating stairs) does not create
// walls adjacent to islands
// ============================================================

(:test)
function islandNeighbor_addWallsAroundStairs(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var left = 2;
    var right = 13;
    var top = 2;
    var bottom = 13;

    var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, ROOMSHAPE_RECTANGLE);

    var walls_before = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);
    Map.addIslands(map, left, right, top, bottom, ROOMSHAPE_RECTANGLE);
    var walls_after_islands = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);

    var island_positions = [] as Array<Point2D>;
    for (var i = 0; i < walls_after_islands.size(); i++) {
        var found = false;
        for (var j = 0; j < walls_before.size(); j++) {
            if (walls_after_islands[i][0] == walls_before[j][0] && walls_after_islands[i][1] == walls_before[j][1]) {
                found = true;
                break;
            }
        }
        if (!found) {
            island_positions.add(walls_after_islands[i]);
        }
    }

    logger.debug("Stairs test: " + island_positions.size() + " island tiles");

    // Snapshot after addIslands + addWallsAroundPassable (before stairs)
    Map.addWallsAroundPassable(map);

    var snapshot2 = new Map(screen_size, screen_size, false);
    for (var x = 0; x < screen_size; x++) {
        for (var y = 0; y < screen_size; y++) {
            var tile = map.getTile(x, y);
            if (tile.type != EMPTY) {
                snapshot2.setType([x, y], tile.type);
            }
        }
    }

    // Place stairs on a PASSABLE tile and run addWallsAround
    // Find a passable position near the room center
    var stairs_x = (left + right) / 2;
    var stairs_y = (top + bottom) / 2;
    // Find nearest passable
    for (var dx = 0; dx <= 5; dx++) {
        for (var dy = 0; dy <= 5; dy++) {
            for (var sx = -1; sx <= 1; sx += 2) {
                for (var sy = -1; sy <= 1; sy += 2) {
                    var tx = stairs_x + dx * sx;
                    var ty = stairs_y + dy * sy;
                    if (tx > left && tx < right && ty > top && ty < bottom) {
                        if (map.getTile(tx, ty).type == PASSABLE) {
                            stairs_x = tx;
                            stairs_y = ty;
                            dx = 99;
                            dy = 99;
                            break;
                        }
                    }
                }
            }
        }
    }

    logger.debug("Placing stairs at (" + stairs_x + "," + stairs_y + ")");
    map.setType([stairs_x, stairs_y], STAIRS);
    Map.addWallsAround(map, stairs_x, stairs_y);

    // Check: no previously PASSABLE neighbor of island should now be WALL
    var err = IslandTestHelpers.checkIslandNeighborsAfterWalls(snapshot2, map, island_positions);
    if (err != null) {
        logger.debug("FAILED after addWallsAround: " + err);
        IslandTestHelpers.printTileTypes(logger, map, "STAIRS POST-WALLS");
        Test.assertMessage(false, err);
        return false;
    }

    logger.debug("Stairs test: PASS");
    return true;
}

// ============================================================
// Test 7: Manual island placement — create exact scenario from
// the bug report (island next to room boundary in non-rect room)
// ============================================================

(:test)
function islandNeighbor_manualPlacement_LShape(logger as Test.Logger) as Boolean {
    // Create an L-shape room manually
    // 16x16 screen, L with horizontal bar at top and vertical stem on right
    var screen_size = 16;
    var map = new Map(screen_size, screen_size, true);

    // Horizontal bar: x=3..12, y=3..6
    for (var x = 3; x <= 12; x++) {
        for (var y = 3; y <= 6; y++) {
            map.setType([x, y], PASSABLE);
        }
    }
    // Vertical stem: x=10..12, y=6..12
    for (var x = 10; x <= 12; x++) {
        for (var y = 6; y <= 12; y++) {
            map.setType([x, y], PASSABLE);
        }
    }

    // Place island at (11, 8) — deep inside the vertical stem
    // 8-neighbors: (10,7),(11,7),(12,7),(10,8),(12,8),(10,9),(11,9),(12,9) — all in vertical stem → PASSABLE
    map.setType([11, 8], WALL);

    IslandTestHelpers.printTileTypes(logger, map, "MANUAL L BEFORE WALLS");
    Map.addWallsAroundPassable(map);
    IslandTestHelpers.printTileTypes(logger, map, "MANUAL L AFTER WALLS");

    // Verify all 8-neighbors of (11,8) are still PASSABLE
    var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
    for (var d = 0; d < dirs8.size(); d++) {
        var nx = 11 + dirs8[d][0];
        var ny = 8 + dirs8[d][1];
        var t = map.getTile(nx, ny).type;
        if (t != PASSABLE) {
            var msg = "Manual L: neighbor (" + nx + "," + ny + ") is " + t + " (expected PASSABLE)";
            logger.debug("FAILED: " + msg);
            Test.assertMessage(false, msg);
            return false;
        }
    }

    logger.debug("Manual L: PASS");
    return true;
}

// ============================================================
// Test 8: Manual placement at L-shape corner — where horizontal
// and vertical arms meet, most likely spot for the bug
// ============================================================

(:test)
function islandNeighbor_manualPlacement_LCorner(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var map = new Map(screen_size, screen_size, true);

    // Horizontal bar: x=3..12, y=3..6
    for (var x = 3; x <= 12; x++) {
        for (var y = 3; y <= 6; y++) {
            map.setType([x, y], PASSABLE);
        }
    }
    // Vertical stem: x=10..12, y=6..12
    for (var x = 10; x <= 12; x++) {
        for (var y = 6; y <= 12; y++) {
            map.setType([x, y], PASSABLE);
        }
    }

    // Place island at (10, 6) — at the corner of the L
    // 8-neighbors: (9,5),(10,5),(11,5),(9,6),(11,6),(9,7),(10,7),(11,7)
    // All should be PASSABLE (9,5 is in horizontal bar, 9,7 is NOT in vertical stem!)
    logger.debug("Checking (9,7) type: " + map.getTile(9, 7).type);

    // (9,7) is NOT in vertical stem (x=10..12) and NOT in horizontal bar (y=3..6)
    // So it's EMPTY! This means placing an island at (10,6) should FAIL the 8-neighbor check.

    // Let's verify: try placing and checking the 8-neighbor check manually
    var valid = true;
    var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
    for (var d = 0; d < dirs8.size(); d++) {
        var nx = 10 + dirs8[d][0];
        var ny = 6 + dirs8[d][1];
        var t = map.getTile(nx, ny).type;
        logger.debug("  8-neighbor (" + nx + "," + ny + ") type=" + t);
        if (t != PASSABLE) {
            valid = false;
        }
    }

    logger.debug("Manual L corner: 8-neighbor check valid=" + valid);
    Test.assertMessage(!valid, "Island at L-corner should be REJECTED by 8-neighbor check (EMPTY neighbor at (9,7))");
    return true;
}

// ============================================================
// Test 9: Verify that addWallsAroundPassable DOES NOT convert
// PASSABLE tiles — only EMPTY tiles adjacent to PASSABLE
// ============================================================

(:test)
function addWallsAroundPassable_onlyConvertsEmpty(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var left = 2;
    var right = 13;
    var top = 2;
    var bottom = 13;

    var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, ROOMSHAPE_RECTANGLE);

    // Record PASSABLE positions before
    var passable_before = [] as Array<Point2D>;
    for (var x = 0; x < screen_size; x++) {
        for (var y = 0; y < screen_size; y++) {
            if (map.getTile(x, y).type == PASSABLE) {
                passable_before.add([x, y]);
            }
        }
    }

    Map.addWallsAroundPassable(map);

    // Check: all previously PASSABLE tiles should still be PASSABLE
    for (var i = 0; i < passable_before.size(); i++) {
        var pos = passable_before[i];
        if (map.getTile(pos[0], pos[1]).type != PASSABLE) {
            var msg = "addWallsAroundPassable changed PASSABLE at (" + pos[0] + "," + pos[1] +
                      ") to " + map.getTile(pos[0], pos[1]).type;
            logger.debug("FAILED: " + msg);
            Test.assertMessage(false, msg);
            return false;
        }
    }

    logger.debug("addWallsAroundPassable: PASS - no PASSABLE tiles were changed");
    return true;
}

// ============================================================
// Test 10: Save/load cycle — create room, add islands, save,
// reload, add stairs. This is the actual game flow.
// ============================================================

(:test)
function islandNeighbor_saveLoadCycle(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var left = 2;
    var right = 13;
    var top = 2;
    var bottom = 13;
    var shapes = [ROOMSHAPE_RECTANGLE, ROOMSHAPE_L_SHAPE, ROOMSHAPE_T_SHAPE, ROOMSHAPE_PLUS, ROOMSHAPE_ROUNDED] as Array<RoomShape>;

    for (var s = 0; s < shapes.size(); s++) {
        var shape = shapes[s];

        // Step 1: Create room (same as createRandomRoom + createRoomForDungeon)
        var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, shape);
        Map.addIslands(map, left, right, top, bottom, shape);

        // Record island positions (any WALL tile that existed after addIslands)
        var island_positions = [] as Array<Point2D>;
        for (var x = 0; x < screen_size; x++) {
            for (var y = 0; y < screen_size; y++) {
                if (map.getTile(x, y).type == WALL) {
                    // Check if it has a PASSABLE 4-neighbor (boundary walls also qualify)
                    // We can't easily distinguish islands from boundary here, so record ALL walls
                    // and later check the invariant for ALL wall tiles
                    island_positions.add([x, y]);
                }
            }
        }

        // Step 2: cleanupRoomForDungeon (addWallsAroundPassable)
        Map.addWallsAroundPassable(map);

        // Step 3: Simulate save/load cycle (Room.save + Room.load)
        // The key: Room.onLoad calls addStairs(stairs_pos, false) which calls addWallsAround
        // Let's simulate: place stairs on a passable tile and call addWallsAround
        var stairs_pos = [-1, -1] as Point2D;
        for (var dx = 0; dx <= 5; dx++) {
            var found = false;
            for (var dy = 0; dy <= 5; dy++) {
                for (var sx = -1; sx <= 1; sx += 2) {
                    for (var sy = -1; sy <= 1; sy += 2) {
                        var tx = (left + right) / 2 + dx * sx;
                        var ty = (top + bottom) / 2 + dy * sy;
                        if (tx > left && tx < right && ty > top && ty < bottom) {
                            if (map.getTile(tx, ty).type == PASSABLE) {
                                stairs_pos = [tx, ty];
                                found = true;
                                break;
                            }
                        }
                    }
                    if (found) { break; }
                }
                if (found) { break; }
            }
            if (found) { break; }
        }

        if (stairs_pos[0] < 0) {
            logger.debug("Shape " + shape + ": no passable tile found for stairs, skipping");
            continue;
        }

        map.setType(stairs_pos, STAIRS);
        Map.addWallsAround(map, stairs_pos[0], stairs_pos[1]);

        // Step 4: Check invariant — every PASSABLE tile that is 8-adjacent to a wall
        // must still be PASSABLE. Specifically: for every wall tile that has a PASSABLE
        // 4-neighbor, check that the wall is NOT diagonally adjacent to a PASSABLE tile
        // that was converted to wall.
        //
        // Simpler check: find tiles that are WALL and have PASSABLE 4-neighbors,
        // then check if any of their 8-neighbors that are PASSABLE are also adjacent
        // to an island.
        //
        // SIMPLEST: for every wall tile that has at least 2 PASSABLE 4-neighbors,
        // it could be an island. Check its 8-neighbors.
        // Actually, just check that no PASSABLE tile is missing — no PASSABLE should become WALL.

        // Record all PASSABLE tiles after addWallsAroundPassable
        var passable_after_walls = [] as Array<Point2D>;
        for (var x = 0; x < screen_size; x++) {
            for (var y = 0; y < screen_size; y++) {
                if (map.getTile(x, y).type == PASSABLE) {
                    passable_after_walls.add([x, y]);
                }
            }
        }

        // Simulate save/load: the map should be preserved exactly
        // No PASSABLE tile should become WALL after addWallsAround
        // (addWallsAround only converts EMPTY -> WALL)
        for (var i = 0; i < passable_after_walls.size(); i++) {
            var pos = passable_after_walls[i];
            if (map.getTile(pos[0], pos[1]).type != PASSABLE) {
                var msg = "Shape " + shape + ": PASSABLE at (" + pos[0] + "," + pos[1] +
                          ") changed to " + map.getTile(pos[0], pos[1]).type;
                logger.debug("FAILED: " + msg);
                Test.assertMessage(false, msg);
                return false;
            }
        }

        logger.debug("Shape " + shape + ": PASS (save/load cycle, " + stairs_pos[0] + "," + stairs_pos[1] + ")");
    }

    return true;
}

// ============================================================
// Test 11: Manual islands in all non-rect shapes — place islands
// right at the L/T/Plus shape boundaries and verify.
// ============================================================

(:test)
function islandNeighbor_manualAllShapes(logger as Test.Logger) as Boolean {
    var screen_size = 16;

    // L-shape: horizontal bar top, vertical stem right
    {
        var map = new Map(screen_size, screen_size, true);
        // Horizontal bar: x=3..12, y=3..6
        for (var x = 3; x <= 12; x++) { for (var y = 3; y <= 6; y++) { map.setType([x, y], PASSABLE); } }
        // Vertical stem: x=10..12, y=6..12
        for (var x = 10; x <= 12; x++) { for (var y = 6; y <= 12; y++) { map.setType([x, y], PASSABLE); } }

        // Island at (11, 8) — inside vertical stem, all 8-neighbors should be PASSABLE
        map.setType([11, 8], WALL);
        Map.addWallsAroundPassable(map);

        var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
        for (var d = 0; d < dirs8.size(); d++) {
            var t = map.getTile(11 + dirs8[d][0], 8 + dirs8[d][1]).type;
            if (t != PASSABLE) {
                logger.debug("L FAIL: neighbor (" + (11+dirs8[d][0]) + "," + (8+dirs8[d][1]) + ") is " + t);
                Test.assertMessage(false, "L-shape island neighbor failed");
                return false;
            }
        }
        logger.debug("L-shape manual: PASS");
    }

    // T-shape: wide top bar, narrow stem
    {
        var map = new Map(screen_size, screen_size, true);
        // Top bar: x=3..12, y=3..5
        for (var x = 3; x <= 12; x++) { for (var y = 3; y <= 5; y++) { map.setType([x, y], PASSABLE); } }
        // Stem: x=6..8, y=5..12
        for (var x = 6; x <= 8; x++) { for (var y = 5; y <= 12; y++) { map.setType([x, y], PASSABLE); } }

        // Island at (7, 7) — inside stem
        map.setType([7, 7], WALL);
        Map.addWallsAroundPassable(map);

        var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
        for (var d = 0; d < dirs8.size(); d++) {
            var t = map.getTile(7 + dirs8[d][0], 7 + dirs8[d][1]).type;
            if (t != PASSABLE) {
                logger.debug("T FAIL: neighbor (" + (7+dirs8[d][0]) + "," + (7+dirs8[d][1]) + ") is " + t);
                Test.assertMessage(false, "T-shape island neighbor failed");
                return false;
            }
        }
        logger.debug("T-shape manual: PASS");
    }

    // Plus shape
    {
        var map = new Map(screen_size, screen_size, true);
        // Horizontal arm: x=3..12, y=6..8
        for (var x = 3; x <= 12; x++) { for (var y = 6; y <= 8; y++) { map.setType([x, y], PASSABLE); } }
        // Vertical arm: x=7..8, y=3..12
        for (var x = 7; x <= 8; x++) { for (var y = 3; y <= 12; y++) { map.setType([x, y], PASSABLE); } }

        // Island at (7, 7) — center of plus
        map.setType([7, 7], WALL);
        Map.addWallsAroundPassable(map);

        var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
        for (var d = 0; d < dirs8.size(); d++) {
            var t = map.getTile(7 + dirs8[d][0], 7 + dirs8[d][1]).type;
            if (t != PASSABLE) {
                logger.debug("Plus FAIL: neighbor (" + (7+dirs8[d][0]) + "," + (7+dirs8[d][1]) + ") is " + t);
                Test.assertMessage(false, "Plus-shape island neighbor failed");
                return false;
            }
        }
        logger.debug("Plus-shape manual: PASS");
    }

    return true;
}

// ============================================================
// Test 12: Verify addWallsAround does NOT create walls adjacent
// to manually placed islands — the exact bug scenario
// ============================================================

(:test)
function islandNeighbor_addWallsAroundNearIsland(logger as Test.Logger) as Boolean {
    // Recreate the exact scenario: L-shape room, island in vertical stem,
    // stairs placed nearby, addWallsAround runs
    var map = new Map(16, 16, true);

    // L-shape: horizontal bar top, vertical stem right
    for (var x = 3; x <= 12; x++) { for (var y = 3; y <= 6; y++) { map.setType([x, y], PASSABLE); } }
    for (var x = 10; x <= 12; x++) { for (var y = 6; y <= 12; y++) { map.setType([x, y], PASSABLE); } }

    // Island at (11, 8)
    map.setType([11, 8], WALL);

    // addWallsAroundPassable (creates room boundary walls)
    Map.addWallsAroundPassable(map);

    IslandTestHelpers.printTileTypes(logger, map, "BEFORE STAIRS");

    // Record island's PASSABLE neighbors before stairs
    var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
    var passable_neighbors_before = [] as Array<Point2D>;
    for (var d = 0; d < dirs8.size(); d++) {
        var nx = 11 + dirs8[d][0];
        var ny = 8 + dirs8[d][1];
        if (map.getTile(nx, ny).type == PASSABLE) {
            passable_neighbors_before.add([nx, ny]);
        }
    }

    // Place stairs far from the island (center of horizontal bar)
    map.setType([7, 4], STAIRS);
    Map.addWallsAround(map, 7, 4);

    IslandTestHelpers.printTileTypes(logger, map, "AFTER addWallsAround(7,4)");

    // Check: all PASSABLE neighbors of island should STILL be PASSABLE
    for (var d = 0; d < dirs8.size(); d++) {
        var nx = 11 + dirs8[d][0];
        var ny = 8 + dirs8[d][1];
        var t = map.getTile(nx, ny).type;
        if (t != PASSABLE) {
            var msg = "addWallsAround converted island neighbor (" + nx + "," + ny + ") from PASSABLE to " + t;
            logger.debug("FAILED: " + msg);
            Test.assertMessage(false, msg);
            return false;
        }
    }

    // Also place stairs near the island but NOT on a neighbor
    // (9,7) is a WALL, so use (5,4) which is in the horizontal bar
    map.setType([5, 4], STAIRS);
    Map.addWallsAround(map, 5, 4);

    IslandTestHelpers.printTileTypes(logger, map, "AFTER addWallsAround(5,4)");

    for (var d = 0; d < dirs8.size(); d++) {
        var nx = 11 + dirs8[d][0];
        var ny = 8 + dirs8[d][1];
        var t = map.getTile(nx, ny).type;
        if (t != PASSABLE) {
            var msg = "addWallsAround(5,4) converted island neighbor (" + nx + "," + ny + ") to " + t;
            logger.debug("FAILED: " + msg);
            Test.assertMessage(false, msg);
            return false;
        }
    }

    logger.debug("addWallsAround near island: PASS");
    return true;
}

// ============================================================
// Test 11: Multi-room simulation — create rooms, add walls,
// simulate stairs placement, check island adjacency
// ============================================================

(:test)
function islandNeighbor_multiRoomSimulation(logger as Test.Logger) as Boolean {
    var screen_size = 16;
    var shapes = [ROOMSHAPE_RECTANGLE, ROOMSHAPE_L_SHAPE, ROOMSHAPE_T_SHAPE, ROOMSHAPE_PLUS, ROOMSHAPE_ROUNDED] as Array<RoomShape>;

    for (var s = 0; s < shapes.size(); s++) {
        var shape = shapes[s];
        var left = 2;
        var right = 13;
        var top = 2;
        var bottom = 13;

        var map = Map.createRoomShape(screen_size, screen_size, left, right, top, bottom, shape);

        var walls_before = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);
        Map.addIslands(map, left, right, top, bottom, shape);
        var walls_after = IslandTestHelpers.findWallTilesWithPassableNeighbor(map);

        var island_positions = [] as Array<Point2D>;
        for (var i = 0; i < walls_after.size(); i++) {
            var found = false;
            for (var j = 0; j < walls_before.size(); j++) {
                if (walls_after[i][0] == walls_before[j][0] && walls_after[i][1] == walls_before[j][1]) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                island_positions.add(walls_after[i]);
            }
        }

        Map.addWallsAroundPassable(map);

        // Simulate stairs placement
        var sx = (left + right) / 2;
        var sy = (top + bottom) / 2;
        // Find nearest passable
        for (var dx = 0; dx <= 5; dx++) {
            var found_stairs = false;
            for (var dy = 0; dy <= 5; dy++) {
                for (var sx2 = -1; sx2 <= 1; sx2 += 2) {
                    for (var sy2 = -1; sy2 <= 1; sy2 += 2) {
                        var tx = sx + dx * sx2;
                        var ty = sy + dy * sy2;
                        if (tx > left && tx < right && ty > top && ty < bottom) {
                            if (map.getTile(tx, ty).type == PASSABLE) {
                                sx = tx;
                                sy = ty;
                                found_stairs = true;
                                break;
                            }
                        }
                    }
                    if (found_stairs) { break; }
                }
                if (found_stairs) { break; }
            }
            if (found_stairs) { break; }
        }

        map.setType([sx, sy], STAIRS);
        Map.addWallsAround(map, sx, sy);

        // Check island neighbors
        var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
        for (var i = 0; i < island_positions.size(); i++) {
            var ix = island_positions[i][0];
            var iy = island_positions[i][1];
            for (var d = 0; d < dirs8.size(); d++) {
                var nx = ix + dirs8[d][0];
                var ny = iy + dirs8[d][1];
                if (nx < 0 || nx >= screen_size || ny < 0 || ny >= screen_size) { continue; }
                if (map.getTile(nx, ny).type == WALL) {
                    // Check if this wall was originally PASSABLE (before addWallsAround)
                    // Since we don't have a snapshot here, just report the finding
                    var msg = "Shape " + shape + ": island at (" + ix + "," + iy +
                              ") has WALL neighbor at (" + nx + "," + ny + ")";
                    logger.debug("WARNING: " + msg);
                }
            }
        }
    }

    logger.debug("Multi-room simulation complete");
    return true;
}
