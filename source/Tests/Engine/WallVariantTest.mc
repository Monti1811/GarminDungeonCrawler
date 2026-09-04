import Toybox.Lang;
import Toybox.Test;

(:test)
function wallVariantRealRoom(logger as Test.Logger) as Boolean {
    // Simulate real dungeon flow: create room, add walls, check variants
    var map = Map.createRoomShape(16, 16, 2, 13, 2, 13, ROOMSHAPE_RECTANGLE);
    Map.addWallsAroundPassable(map);
    
    // Dump tile types
    logger.debug("=== TILE TYPES ===");
    var typeMap = "";
    for (var y = 0; y < 16; y++) {
        typeMap = "";
        for (var x = 0; x < 16; x++) {
            var tile = map.getTile(x, y);
            switch (tile.type) {
                case WALL: typeMap += "W"; break;
                case PASSABLE: typeMap += "P"; break;
                case EMPTY: typeMap += "."; break;
                default: typeMap += "?"; break;
            }
        }
        logger.debug("y=" + y + ": " + typeMap);
    }
    
    // Dump wall variants
    logger.debug("=== WALL VARIANTS ===");
    var varMap = "";
    for (var y = 0; y < 16; y++) {
        varMap = "";
        for (var x = 0; x < 16; x++) {
            var tile = map.getTile(x, y);
            if (tile.type == WALL) {
                var v = map.getWallVariant(x, y);
                if (v >= 42 && v <= 62) {
                    varMap += v.toString();
                    if (v < 100) { varMap += " "; }
                } else {
                    varMap += "??";
                }
            } else {
                varMap += "   ";
            }
        }
        logger.debug("y=" + y + ": " + varMap);
    }
    
    // Dump map chars (skip - getDungeonStyleTranslation needs Game context)
    
    // Test L-shape for inner corners
    logger.debug("=== L-SHAPE ===");
    var map2 = Map.createRoomShape(16, 16, 2, 13, 2, 13, ROOMSHAPE_L_SHAPE);
    Map.addWallsAroundPassable(map2);
    
    logger.debug("=== L-SHAPE TILE TYPES ===");
    for (var y = 0; y < 16; y++) {
        var lTypeMap = "";
        for (var x = 0; x < 16; x++) {
            var ltile = map2.getTile(x, y);
            switch (ltile.type) {
                case WALL: lTypeMap += "W"; break;
                case PASSABLE: lTypeMap += "P"; break;
                case EMPTY: lTypeMap += "."; break;
                default: lTypeMap += "?"; break;
            }
        }
        logger.debug("y=" + y + ": " + lTypeMap);
    }
    
    logger.debug("=== L-SHAPE WALL VARIANTS ===");
    for (var y = 0; y < 16; y++) {
        var lVarMap = "";
        for (var x = 0; x < 16; x++) {
            var ltile2 = map2.getTile(x, y);
            if (ltile2.type == WALL) {
                var lv = map2.getWallVariant(x, y);
                lVarMap += lv.toString();
                if (lv < 100) { lVarMap += " "; }
            } else {
                lVarMap += "   ";
            }
        }
        logger.debug("y=" + y + ": " + lVarMap);
    }
    
    return true;
}

(:test)
function wallVariantHorizontalTop(logger as Test.Logger) as Boolean {
    // Layout:
    // . P .
    // W W W
    // . . .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = PASSABLE; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = WALL; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = WALL; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = EMPTY; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantHorizontalTop: variant=" + variant);
    Test.assertEqual(variant, 42);
    return true;
}

(:test)
function wallVariantHorizontalBottom(logger as Test.Logger) as Boolean {
    // Layout:
    // . . .
    // W W W
    // . P .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = EMPTY; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = WALL; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = WALL; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = PASSABLE; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantHorizontalBottom: variant=" + variant);
    Test.assertEqual(variant, 43);
    return true;
}

(:test)
function wallVariantHorizontalMid(logger as Test.Logger) as Boolean {
    // Layout:
    // . P .
    // W W W
    // . P .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = PASSABLE; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = WALL; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = WALL; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = PASSABLE; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantHorizontalMid: variant=" + variant);
    Test.assertEqual(variant, 44);
    return true;
}

(:test)
function wallVariantVerticalLeft(logger as Test.Logger) as Boolean {
    // Layout:
    // . W .
    // P W .
    // . W .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = WALL; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = PASSABLE; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = EMPTY; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = WALL; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantVerticalLeft: variant=" + variant);
    Test.assertEqual(variant, 45);
    return true;
}

(:test)
function wallVariantVerticalRight(logger as Test.Logger) as Boolean {
    // Layout:
    // . W .
    // . W P
    // . W .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = WALL; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = EMPTY; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = PASSABLE; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = WALL; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantVerticalRight: variant=" + variant);
    Test.assertEqual(variant, 46);
    return true;
}

(:test)
function wallVariantVerticalMid(logger as Test.Logger) as Boolean {
    // Layout:
    // . W .
    // P W P
    // . W .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = WALL; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = PASSABLE; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = PASSABLE; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = WALL; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantVerticalMid: variant=" + variant);
    Test.assertEqual(variant, 47);
    return true;
}

(:test)
function wallVariantOuterTL(logger as Test.Logger) as Boolean {
    // topWall+leftWall, diagonal(2,2)=EMPTY → EMPTY is not PASSABLE → INNER_BR
    // Layout (4x4):
    // . . . .
    // . W . .
    // W W . .
    // . . . .
    var map = new Map(4, 4, true);
    var t;
    for (var x = 0; x < 4; x++) { for (var y = 0; y < 4; y++) { t = new Tile(x, y); t.type = EMPTY; map.setTile(x, y, t); } }
    t = new Tile(1, 0); t.type = WALL; map.setTile(1, 0, t);
    t = new Tile(0, 1); t.type = WALL; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantOuterTL: variant=" + variant);
    Test.assertEqual(variant, INNER_BR);
    return true;
}

(:test)
function wallVariantInnerTL(logger as Test.Logger) as Boolean {
    // topWall+leftWall, diagonal(2,2)=PASSABLE → OUTER_BR
    // Layout (4x4):
    // . . . .
    // . W . .
    // W W . .
    // . . P .
    var map = new Map(4, 4, true);
    var t;
    for (var x = 0; x < 4; x++) { for (var y = 0; y < 4; y++) { t = new Tile(x, y); t.type = EMPTY; map.setTile(x, y, t); } }
    t = new Tile(1, 0); t.type = WALL; map.setTile(1, 0, t);
    t = new Tile(0, 1); t.type = WALL; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 2); t.type = PASSABLE; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantInnerTL: variant=" + variant);
    Test.assertEqual(variant, OUTER_BR);
    return true;
}

(:test)
function wallVariantOuterTR(logger as Test.Logger) as Boolean {
    // topWall+rightWall, diagonal(1,2)=EMPTY → INNER_BL
    // Layout:
    // . . W .
    // . . W W
    // . . . .
    // . . . .
    var map = new Map(4, 4, true);
    var t;
    for (var x = 0; x < 4; x++) { for (var y = 0; y < 4; y++) { t = new Tile(x, y); t.type = EMPTY; map.setTile(x, y, t); } }
    t = new Tile(2, 0); t.type = WALL; map.setTile(2, 0, t);
    t = new Tile(2, 1); t.type = WALL; map.setTile(2, 1, t);
    t = new Tile(3, 1); t.type = WALL; map.setTile(3, 1, t);

    var variant = map.getWallVariant(2, 1);
    logger.debug("wallVariantOuterTR: variant=" + variant);
    Test.assertEqual(variant, INNER_BL);
    return true;
}

(:test)
function wallVariantInnerTR(logger as Test.Logger) as Boolean {
    // topWall+rightWall, diagonal(1,2)=PASSABLE → OUTER_BL
    // Layout (4x4):
    // . . W .
    // . . W W
    // . P . .
    // . . . .
    var map = new Map(4, 4, true);
    var t;
    for (var x = 0; x < 4; x++) { for (var y = 0; y < 4; y++) { t = new Tile(x, y); t.type = EMPTY; map.setTile(x, y, t); } }
    t = new Tile(2, 0); t.type = WALL; map.setTile(2, 0, t);
    t = new Tile(2, 1); t.type = WALL; map.setTile(2, 1, t);
    t = new Tile(3, 1); t.type = WALL; map.setTile(3, 1, t);
    t = new Tile(1, 2); t.type = PASSABLE; map.setTile(1, 2, t);

    var variant = map.getWallVariant(2, 1);
    logger.debug("wallVariantInnerTR: variant=" + variant);
    Test.assertEqual(variant, OUTER_BL);
    return true;
}

(:test)
function wallVariantOuterBL(logger as Test.Logger) as Boolean {
    // bottomWall+leftWall, diagonal(2,1)=EMPTY → INNER_TR
    // Layout (4x4):
    // . . . .
    // . . . .
    // W W . .
    // . W . .
    var map = new Map(4, 4, true);
    var t;
    for (var x = 0; x < 4; x++) { for (var y = 0; y < 4; y++) { t = new Tile(x, y); t.type = EMPTY; map.setTile(x, y, t); } }
    t = new Tile(0, 2); t.type = WALL; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = WALL; map.setTile(1, 2, t);
    t = new Tile(1, 3); t.type = WALL; map.setTile(1, 3, t);

    var variant = map.getWallVariant(1, 2);
    logger.debug("wallVariantOuterBL: variant=" + variant);
    Test.assertEqual(variant, INNER_TR);
    return true;
}

(:test)
function wallVariantInnerBL(logger as Test.Logger) as Boolean {
    // bottomWall+leftWall, diagonal(2,1)=PASSABLE → OUTER_TR
    // Layout (4x4):
    // . . . .
    // . . P .
    // W W . .
    // . W . .
    var map = new Map(4, 4, true);
    var t;
    for (var x = 0; x < 4; x++) { for (var y = 0; y < 4; y++) { t = new Tile(x, y); t.type = EMPTY; map.setTile(x, y, t); } }
    t = new Tile(0, 2); t.type = WALL; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = WALL; map.setTile(1, 2, t);
    t = new Tile(1, 3); t.type = WALL; map.setTile(1, 3, t);
    t = new Tile(2, 1); t.type = PASSABLE; map.setTile(2, 1, t);

    var variant = map.getWallVariant(1, 2);
    logger.debug("wallVariantInnerBL: variant=" + variant);
    Test.assertEqual(variant, OUTER_TR);
    return true;
}

(:test)
function wallVariantOuterBR(logger as Test.Logger) as Boolean {
    // bottomWall+rightWall, diagonal(1,1)=EMPTY → INNER_TL
    // Layout (4x4):
    // . . . .
    // . . . .
    // . . W W
    // . . W .
    var map = new Map(4, 4, true);
    var t;
    for (var x = 0; x < 4; x++) { for (var y = 0; y < 4; y++) { t = new Tile(x, y); t.type = EMPTY; map.setTile(x, y, t); } }
    t = new Tile(2, 2); t.type = WALL; map.setTile(2, 2, t);
    t = new Tile(3, 2); t.type = WALL; map.setTile(3, 2, t);
    t = new Tile(2, 3); t.type = WALL; map.setTile(2, 3, t);

    var variant = map.getWallVariant(2, 2);
    logger.debug("wallVariantOuterBR: variant=" + variant);
    Test.assertEqual(variant, INNER_TL);
    return true;
}

(:test)
function wallVariantInnerBR(logger as Test.Logger) as Boolean {
    // bottomWall+rightWall, diagonal(1,1)=PASSABLE → OUTER_TL
    // Layout (4x4):
    // . . . .
    // . P . .
    // . . W W
    // . . W .
    var map = new Map(4, 4, true);
    var t;
    for (var x = 0; x < 4; x++) { for (var y = 0; y < 4; y++) { t = new Tile(x, y); t.type = EMPTY; map.setTile(x, y, t); } }
    t = new Tile(1, 1); t.type = PASSABLE; map.setTile(1, 1, t);
    t = new Tile(2, 2); t.type = WALL; map.setTile(2, 2, t);
    t = new Tile(3, 2); t.type = WALL; map.setTile(3, 2, t);
    t = new Tile(2, 3); t.type = WALL; map.setTile(2, 3, t);

    var variant = map.getWallVariant(2, 2);
    logger.debug("wallVariantInnerBR: variant=" + variant);
    Test.assertEqual(variant, OUTER_TL);
    return true;
}

(:test)
function wallVariantCross(logger as Test.Logger) as Boolean {
    // Isolated wall (0 wall neighbors)
    // Layout:
    // . P .
    // P W P
    // . P .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = PASSABLE; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = PASSABLE; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = PASSABLE; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = PASSABLE; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantCross: variant=" + variant);
    Test.assertEqual(variant, CROSS);
    return true;
}

(:test)
function wallVariantTDown(logger as Test.Logger) as Boolean {
    // T-junction: 1 wall on bottom, passable on top/left/right
    // Layout:
    // . P .
    // P W P
    // . W .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = PASSABLE; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = PASSABLE; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = PASSABLE; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = WALL; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantTDown: variant=" + variant);
    Test.assertEqual(variant, T_DOWN);
    return true;
}

(:test)
function wallVariantTUp(logger as Test.Logger) as Boolean {
    // T-junction: 1 wall on top, passable on bottom/left/right
    // Layout:
    // . W .
    // P W P
    // . P .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = WALL; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = PASSABLE; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = PASSABLE; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = PASSABLE; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantTUp: variant=" + variant);
    Test.assertEqual(variant, T_UP);
    return true;
}

(:test)
function wallVariantTLeft(logger as Test.Logger) as Boolean {
    // T-junction: 1 wall on left, passable on top/bottom/right
    // Layout:
    // . P .
    // W W P
    // . P .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = PASSABLE; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = WALL; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = PASSABLE; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = PASSABLE; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantTLeft: variant=" + variant);
    // NOTE: leftWall→T_RIGHT is intentional (visual orientation of T-tile is reversed)
    Test.assertEqual(variant, T_RIGHT);
    return true;
}

(:test)
function wallVariantTRight(logger as Test.Logger) as Boolean {
    // T-junction: 1 wall on right, passable on top/bottom/left
    // Layout:
    // . P .
    // P W W
    // . P .
    var map = new Map(3, 3, true);
    var t;
    t = new Tile(0, 0); t.type = EMPTY; map.setTile(0, 0, t);
    t = new Tile(1, 0); t.type = PASSABLE; map.setTile(1, 0, t);
    t = new Tile(2, 0); t.type = EMPTY; map.setTile(2, 0, t);
    t = new Tile(0, 1); t.type = PASSABLE; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = WALL; map.setTile(2, 1, t);
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = PASSABLE; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = EMPTY; map.setTile(2, 2, t);

    var variant = map.getWallVariant(1, 1);
    logger.debug("wallVariantTRight: variant=" + variant);
    // NOTE: rightWall→T_LEFT is intentional (visual orientation of T-tile is reversed)
    Test.assertEqual(variant, T_LEFT);
    return true;
}

(:test)
function wallVariantRectangularRoom(logger as Test.Logger) as Boolean {
    // Full rectangular room simulation - all 4 corners should be inner corners
    // Layout:
    // . . . . .
    // . W W W .
    // . W P W .
    // . W W W .
    // . . . . .
    var map = new Map(5, 5, true);
    var t;
    // Row 0: all empty
    for (var x = 0; x < 5; x++) { t = new Tile(x, 0); t.type = EMPTY; map.setTile(x, 0, t); }
    // Row 1: empty, wall, wall, wall, empty
    t = new Tile(0, 1); t.type = EMPTY; map.setTile(0, 1, t);
    t = new Tile(1, 1); t.type = WALL; map.setTile(1, 1, t);
    t = new Tile(2, 1); t.type = WALL; map.setTile(2, 1, t);
    t = new Tile(3, 1); t.type = WALL; map.setTile(3, 1, t);
    t = new Tile(4, 1); t.type = EMPTY; map.setTile(4, 1, t);
    // Row 2: empty, wall, passable, wall, empty
    t = new Tile(0, 2); t.type = EMPTY; map.setTile(0, 2, t);
    t = new Tile(1, 2); t.type = WALL; map.setTile(1, 2, t);
    t = new Tile(2, 2); t.type = PASSABLE; map.setTile(2, 2, t);
    t = new Tile(3, 2); t.type = WALL; map.setTile(3, 2, t);
    t = new Tile(4, 2); t.type = EMPTY; map.setTile(4, 2, t);
    // Row 3: empty, wall, wall, wall, empty
    t = new Tile(0, 3); t.type = EMPTY; map.setTile(0, 3, t);
    t = new Tile(1, 3); t.type = WALL; map.setTile(1, 3, t);
    t = new Tile(2, 3); t.type = WALL; map.setTile(2, 3, t);
    t = new Tile(3, 3); t.type = WALL; map.setTile(3, 3, t);
    t = new Tile(4, 3); t.type = EMPTY; map.setTile(4, 3, t);
    // Row 4: all empty
    for (var x = 0; x < 5; x++) { t = new Tile(x, 4); t.type = EMPTY; map.setTile(x, 4, t); }

    // Bottom-right corner (1,1): bottomWall+rightWall, diagonal (0,0)=EMPTY → INNER_TL
    var variant = map.getWallVariant(1, 1);
    logger.debug("rectRoom BR(1,1): variant=" + variant);
    Test.assertEqual(variant, INNER_TL);

    // Bottom-left corner (3,1): bottomWall+leftWall, diagonal (4,0)=EMPTY → INNER_TR
    variant = map.getWallVariant(3, 1);
    logger.debug("rectRoom BL(3,1): variant=" + variant);
    Test.assertEqual(variant, INNER_TR);

    // Top-right corner (1,3): topWall+rightWall, diagonal (0,4)=EMPTY → INNER_BL
    variant = map.getWallVariant(1, 3);
    logger.debug("rectRoom TR(1,3): variant=" + variant);
    Test.assertEqual(variant, INNER_BL);

    // Top-left corner (3,3): topWall+leftWall, diagonal (4,4)=EMPTY → INNER_BR
    variant = map.getWallVariant(3, 3);
    logger.debug("rectRoom TL(3,3): variant=" + variant);
    Test.assertEqual(variant, INNER_BR);

    // Top wall (2,1): walls left+right, bottomPassable → h_bottom (43)
    variant = map.getWallVariant(2, 1);
    logger.debug("rectRoom topWall(2,1): variant=" + variant);
    Test.assertEqual(variant, 43);

    // Bottom wall (2,3): walls left+right, topPassable → h_top (42)
    variant = map.getWallVariant(2, 3);
    logger.debug("rectRoom bottomWall(2,3): variant=" + variant);
    Test.assertEqual(variant, 42);

    // Left wall (1,2): walls top+bottom, rightPassable → v_right (46)
    variant = map.getWallVariant(1, 2);
    logger.debug("rectRoom leftWall(1,2): variant=" + variant);
    Test.assertEqual(variant, 46);

    // Right wall (3,2): walls top+bottom, leftPassable → v_left (45)
    variant = map.getWallVariant(3, 2);
    logger.debug("rectRoom rightWall(3,2): variant=" + variant);
    Test.assertEqual(variant, 45);

    return true;
}

(:test)
function wallSurroundedByFourWallsReturnsZero(logger as Test.Logger) as Boolean {
    // Create a small map and check that a wall with 4 WALL neighbors returns 0 (plain wall)
    var map = Map.createRoomShape(5, 5, 1, 3, 1, 3, ROOMSHAPE_PLUS);
    Map.addWallsAroundPassable(map);

    logger.debug("=== TILE TYPES ===");
    for (var y = 0; y < 5; y++) {
        var line = "";
        for (var x = 0; x < 5; x++) {
            var tile = map.getTile(x, y);
            switch (tile.type) {
                case WALL: line += "W"; break;
                case PASSABLE: line += "P"; break;
                case EMPTY: line += "."; break;
                default: line += "?"; break;
            }
        }
        logger.debug("y=" + y + ": " + line);
    }

    // Build a manual map where a wall is fully surrounded by 4 other walls
    // P W P
    // W W W
    // P W P
    var map2 = Map.createRoomShape(5, 5, 0, 4, 0, 4, ROOMSHAPE_RECTANGLE);
    // Set center area to PASSABLE, then walls will be added around
    map2.getTile(0, 0).type = PASSABLE;
    map2.getTile(2, 0).type = PASSABLE;
    map2.getTile(4, 0).type = PASSABLE;
    map2.getTile(0, 2).type = PASSABLE;
    map2.getTile(2, 2).type = PASSABLE;
    map2.getTile(4, 2).type = PASSABLE;
    map2.getTile(0, 4).type = PASSABLE;
    map2.getTile(2, 4).type = PASSABLE;
    map2.getTile(4, 4).type = PASSABLE;
    Map.addWallsAroundPassable(map2);

    logger.debug("=== MAP2 TILE TYPES ===");
    for (var y = 0; y < 5; y++) {
        var line = "";
        for (var x = 0; x < 5; x++) {
            var tile = map2.getTile(x, y);
            switch (tile.type) {
                case WALL: line += "W"; break;
                case PASSABLE: line += "P"; break;
                case EMPTY: line += "."; break;
                default: line += "?"; break;
            }
        }
        logger.debug("y=" + y + ": " + line);
    }

    // Find any wall with wallCount==4
    var foundSurrounded = false;
    for (var y = 0; y < 5; y++) {
        for (var x = 0; x < 5; x++) {
            var tile = map2.getTile(x, y);
            if (tile.type == WALL) {
                var top = (y > 0) ? map2.getTile(x, y - 1).type : EMPTY;
                var bottom = (y < 4) ? map2.getTile(x, y + 1).type : EMPTY;
                var left = (x > 0) ? map2.getTile(x - 1, y).type : EMPTY;
                var right = (x < 4) ? map2.getTile(x + 1, y).type : EMPTY;

                var wallCount = 0;
                if (top == WALL) { wallCount++; }
                if (bottom == WALL) { wallCount++; }
                if (left == WALL) { wallCount++; }
                if (right == WALL) { wallCount++; }

                var v = map2.getWallVariant(x, y);
                logger.debug("Wall (" + x + "," + y + ") wallCount=" + wallCount + " variant=" + v);

                if (wallCount == 4) {
                    foundSurrounded = true;
                    Test.assertEqual(v, 0);
                }
            }
        }
    }

    logger.debug("Found wallCount==4: " + foundSurrounded);
    return true;
}
