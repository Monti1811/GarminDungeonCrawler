import Toybox.Test;
import Toybox.Lang;

// --- calcDistance ---

(:test)
function calcDistanceSamePointIsZero(logger as Test.Logger) as Boolean {
    var dist = MapUtil.calcDistance([5, 5], [5, 5]);
    Test.assertMessage(dist >= -0.01 && dist <= 0.01, "expected ~0.0, got " + dist);
    return true;
}

(:test)
function calcDistanceHorizontal(logger as Test.Logger) as Boolean {
    var dist = MapUtil.calcDistance([0, 0], [3, 0]);
    Test.assertMessage(dist >= 2.99 && dist <= 3.01, "expected ~3.0, got " + dist);
    return true;
}

(:test)
function calcDistanceVertical(logger as Test.Logger) as Boolean {
    var dist = MapUtil.calcDistance([0, 0], [0, 4]);
    Test.assertMessage(dist >= 3.99 && dist <= 4.01, "expected ~4.0, got " + dist);
    return true;
}

(:test)
function calcDistanceDiagonal345(logger as Test.Logger) as Boolean {
    var dist = MapUtil.calcDistance([0, 0], [3, 4]);
    Test.assertMessage(dist >= 4.99 && dist <= 5.01, "expected ~5.0, got " + dist);
    return true;
}

(:test)
function calcDistanceIsSymmetric(logger as Test.Logger) as Boolean {
    var d1 = MapUtil.calcDistance([1, 2], [5, 8]);
    var d2 = MapUtil.calcDistance([5, 8], [1, 2]);
    Test.assertEqual(d1, d2);
    return true;
}

// --- getCoordInDirection ---

(:test)
function getCoordInDirectionUp(logger as Test.Logger) as Boolean {
    var result = MapUtil.getCoordInDirection([5, 5], UP);
    Test.assertEqual(result[0], 5);
    Test.assertEqual(result[1], 4);
    return true;
}

(:test)
function getCoordInDirectionDown(logger as Test.Logger) as Boolean {
    var result = MapUtil.getCoordInDirection([5, 5], DOWN);
    Test.assertEqual(result[0], 5);
    Test.assertEqual(result[1], 6);
    return true;
}

(:test)
function getCoordInDirectionLeft(logger as Test.Logger) as Boolean {
    var result = MapUtil.getCoordInDirection([5, 5], LEFT);
    Test.assertEqual(result[0], 4);
    Test.assertEqual(result[1], 5);
    return true;
}

(:test)
function getCoordInDirectionRight(logger as Test.Logger) as Boolean {
    var result = MapUtil.getCoordInDirection([5, 5], RIGHT);
    Test.assertEqual(result[0], 6);
    Test.assertEqual(result[1], 5);
    return true;
}

// --- getInversedDirection ---

(:test)
function getInversedDirectionUpIsDown(logger as Test.Logger) as Boolean {
    Test.assertEqual(MapUtil.getInversedDirection(UP), DOWN);
    return true;
}

(:test)
function getInversedDirectionDownIsUp(logger as Test.Logger) as Boolean {
    Test.assertEqual(MapUtil.getInversedDirection(DOWN), UP);
    return true;
}

(:test)
function getInversedDirectionLeftIsRight(logger as Test.Logger) as Boolean {
    Test.assertEqual(MapUtil.getInversedDirection(LEFT), RIGHT);
    return true;
}

(:test)
function getInversedDirectionRightIsLeft(logger as Test.Logger) as Boolean {
    Test.assertEqual(MapUtil.getInversedDirection(RIGHT), LEFT);
    return true;
}

// --- shuffle ---

(:test)
function shufflePreservesAllElements(logger as Test.Logger) as Boolean {
    var arr = [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0]] as Array<Point2D>;
    var original = [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0]] as Array<Point2D>;
    MapUtil.shuffle(arr);

    Test.assertEqual(arr.size(), original.size());
    // Check all original elements are present
    for (var i = 0; i < original.size(); i++) {
        var found = false;
        for (var j = 0; j < arr.size(); j++) {
            if (arr[j][0] == original[i][0] && arr[j][1] == original[i][1]) {
                found = true;
                break;
            }
        }
        Test.assertMessage(found, "element " + original[i][0] + "," + original[i][1] + " missing after shuffle");
    }
    return true;
}

// --- isNarrowPassage ---

(:test)
function isNarrowPassageReturnsTrueForTunnel(logger as Test.Logger) as Boolean {
    // Create a 5x5 map with a narrow passage at [2,2]
    var map = new Map(5, 5, true);
    // walls everywhere except a horizontal tunnel at y=2
    for (var x = 0; x < 5; x++) {
        for (var y = 0; y < 5; y++) {
            if (y == 2) {
                map.setType([x, y], PASSABLE);
            }
        }
    }
    // tile at [2,2] has 2 passable neighbors ([1,2] and [3,2])
    Test.assertMessage(MapUtil.isNarrowPassage(map, [2, 2]), "should be narrow passage");
    return true;
}

(:test)
function isNarrowPassageReturnsFalseForOpenArea(logger as Test.Logger) as Boolean {
    var map = new Map(7, 7, true);
    for (var x = 1; x < 6; x++) {
        for (var y = 1; y < 6; y++) {
            map.setType([x, y], PASSABLE);
        }
    }
    // tile at [3,3] has 4 passable neighbors
    Test.assertMessage(!MapUtil.isNarrowPassage(map, [3, 3]), "should not be narrow passage");
    return true;
}

(:test)
function isNarrowPassageReturnsFalseForWall(logger as Test.Logger) as Boolean {
    var map = new Map(5, 5, true);
    Test.assertMessage(!MapUtil.isNarrowPassage(map, [2, 2]), "wall should not be narrow passage");
    return true;
}

(:test)
function isNarrowPassageReturnsFalseForOutOfBounds(logger as Test.Logger) as Boolean {
    var map = new Map(5, 5, true);
    Test.assertMessage(!MapUtil.isNarrowPassage(map, [10, 10]), "out of bounds should not be narrow passage");
    return true;
}

// --- hasAllOpenNeighbors ---

(:test)
function hasAllOpenNeighborsReturnsTrueInOpenArea(logger as Test.Logger) as Boolean {
    var map = new Map(7, 7, true);
    for (var x = 0; x < 7; x++) {
        for (var y = 0; y < 7; y++) {
            map.setType([x, y], PASSABLE);
        }
    }
    Test.assertMessage(MapUtil.hasAllOpenNeighbors(map, 3, 3), "center of open area");
    return true;
}

(:test)
function hasAllOpenNeighborsReturnsFalseNearWall(logger as Test.Logger) as Boolean {
    var map = new Map(5, 5, true);
    for (var x = 0; x < 5; x++) {
        for (var y = 0; y < 5; y++) {
            map.setType([x, y], PASSABLE);
        }
    }
    map.setType([0, 0], WALL);
    // [1,1] has [0,0] as a wall neighbor
    Test.assertMessage(!MapUtil.hasAllOpenNeighbors(map, 1, 1), "near corner wall");
    return true;
}

(:test)
function hasAllOpenNeighborsReturnsFalseAtBorder(logger as Test.Logger) as Boolean {
    var map = new Map(5, 5, true);
    for (var x = 0; x < 5; x++) {
        for (var y = 0; y < 5; y++) {
            map.setType([x, y], PASSABLE);
        }
    }
    // [0,0] is at border — out-of-bounds neighbors fail
    Test.assertMessage(!MapUtil.hasAllOpenNeighbors(map, 0, 0), "at border");
    return true;
}

// --- clearAround ---

(:test)
function clearAroundConvertsWallsToPassable(logger as Test.Logger) as Boolean {
    var map = new Map(5, 5, true);
    map.setType([2, 2], PASSABLE);
    // Set all neighbors to wall
    map.setType([1, 1], WALL);
    map.setType([2, 1], WALL);
    map.setType([3, 1], WALL);
    map.setType([1, 2], WALL);
    map.setType([3, 2], WALL);
    map.setType([1, 3], WALL);
    map.setType([2, 3], WALL);
    map.setType([3, 3], WALL);

    MapUtil.clearAround(map, 2, 2);

    // All neighbors should now be PASSABLE
    Test.assertEqual(map.getType([1, 1]), PASSABLE);
    Test.assertEqual(map.getType([2, 1]), PASSABLE);
    Test.assertEqual(map.getType([3, 1]), PASSABLE);
    Test.assertEqual(map.getType([1, 2]), PASSABLE);
    Test.assertEqual(map.getType([3, 2]), PASSABLE);
    Test.assertEqual(map.getType([1, 3]), PASSABLE);
    Test.assertEqual(map.getType([2, 3]), PASSABLE);
    Test.assertEqual(map.getType([3, 3]), PASSABLE);
    return true;
}

(:test)
function clearAroundSkipsOutOfBoundNeighbors(logger as Test.Logger) as Boolean {
    var map = new Map(3, 3, true);
    map.setType([0, 0], PASSABLE);
    map.setType([1, 0], WALL);
    map.setType([0, 1], WALL);
    map.setType([1, 1], WALL);

    // Should not crash on out-of-bounds neighbors
    MapUtil.clearAround(map, 0, 0);
    Test.assertEqual(map.getType([1, 0]), PASSABLE);
    Test.assertEqual(map.getType([0, 1]), PASSABLE);
    return true;
}

// --- canMoveToPoint ---

(:test)
function canMoveToPointTrueForEmptyPassable(logger as Test.Logger) as Boolean {
    var map = new Map(5, 5, true);
    map.setType([2, 2], PASSABLE);
    Test.assertMessage(MapUtil.canMoveToPoint(map, [2, 2]), "should move to passable");
    return true;
}

(:test)
function canMoveToPointFalseForWall(logger as Test.Logger) as Boolean {
    var map = new Map(5, 5, true);
    map.setType([2, 2], WALL);
    Test.assertMessage(!MapUtil.canMoveToPoint(map, [2, 2]), "should not move to wall");
    return true;
}

(:test)
function canMoveToPointFalseForOutOfBounds(logger as Test.Logger) as Boolean {
    var map = new Map(5, 5, true);
    Test.assertMessage(!MapUtil.canMoveToPoint(map, [10, 10]), "should not move out of bounds");
    return true;
}
