import Toybox.Lang;
import Toybox.Test;

(:test)
function gameInitMapCreatesCorrectDimensions(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.initMap(5, 4);
    Test.assertEqual(Game.map.size(), 5);
    for (var i = 0; i < 5; i++) {
        Test.assertEqual(Game.map[i].size(), 4);
    }
    return true;
}

(:test)
function gameInitMapZeroSize(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.initMap(0, 0);
    Test.assertEqual(Game.map.size(), 0);
    return true;
}

(:test)
function gameAddRoomToMap(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.initMap(5, 5);
    var connections = {:north => true} as Dictionary<WalkDirection, Boolean>;
    Game.addRoomToMap([2, 3], "room_0_0", connections, [10, 10], null);
    var room = Game.map[2][3];
    Test.assertEqual(room[0], "room_0_0");
    return true;
}

(:test)
function gameSetRoomAsVisited(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.initMap(3, 3);
    var connections = {} as Dictionary<WalkDirection, Boolean>;
    Game.addRoomToMap([1, 1], "test_room", connections, [8, 8], null);
    Test.assert(!Game.map[1][1][3]);
    Game.setRoomAsVisited([1, 1]);
    Test.assert(Game.map[1][1][3]);
    return true;
}

(:test)
function gameSetRoomWithFlag(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.initMap(3, 3);
    var connections = {} as Dictionary<WalkDirection, Boolean>;
    Game.addRoomToMap([1, 1], "test_room", connections, [8, 8], null);
    Game.setRoomWithFlag([1, 1], HAS_STAIRS, [5, 5]);
    var flags = Game.map[1][1][4] as Array<Point2D?>;
    Test.assert(flags[HAS_STAIRS] != null);
    return true;
}

(:test)
function gameCreateEmptyFlagsHasCorrectSize(logger as Test.Logger) as Boolean {
    var flags = Game.createEmptyFlags();
    Test.assertEqual(flags.size(), Game.FLAG_SLOTS);
    for (var i = 0; i < flags.size(); i++) {
        Test.assert(flags[i] == null);
    }
    return true;
}

(:test)
function gameNormalizeFlagsAddsMissingFlags(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.initMap(2, 2);
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            Game.map[i][j] = ["room", {}, [8, 8], false, [], null];
        }
    }
    Game.normalizeFlags();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            var flags = Game.map[i][j][4] as Array<Point2D?>;
            Test.assertEqual(flags.size(), Game.FLAG_SLOTS);
        }
    }
    return true;
}

(:test)
function gameNormalizeFlagsAddsRoomShapeIfMissing(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.initMap(1, 1);
    var connections = {} as Dictionary<WalkDirection, Boolean>;
    Game.addRoomToMap([0, 0], "test_room", connections, [8, 8], null);
    var room = Game.map[0][0];
    var flags = room[4] as Array<Point2D?>;
    Test.assertEqual(flags.size(), Game.FLAG_SLOTS);
    return true;
}

(:test)
function gameNormalizeFlagsPreservesExisting(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.initMap(1, 1);
    var existingFlags = [null, [5, 5], null, null] as Array<Point2D?>;
    Game.map[0][0] = ["room", {}, [8, 8], false, existingFlags, null];
    Game.normalizeFlags();
    var flags = Game.map[0][0][4] as Array<Point2D?>;
    Test.assertEqual(flags.size(), Game.FLAG_SLOTS);
    Test.assert(flags[1] != null);
    return true;
}

(:test)
function gameAddToDepth(logger as Test.Logger) as Boolean {
    Game.init(0);
    Test.assertEqual(Game.depth, 0);
    Game.addToDepth(3);
    Test.assertEqual(Game.depth, 3);
    Game.addToDepth(2);
    Test.assertEqual(Game.depth, 5);
    return true;
}

(:test)
function gameSetAndGetTimePlayed(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.setTimePlayed(100);
    Test.assertEqual(Game.getTimePlayed(), 100);
    Game.addToTimePlayed(50);
    Test.assertEqual(Game.getTimePlayed(), 150);
    return true;
}

(:test)
function gameSetAndGetPlayer(logger as Test.Logger) as Boolean {
    Game.init(0);
    Test.assert(Game.getPlayer() == null);
    var player = Players.createPlayerFromId(0, "Test");
    Game.setPlayer(player);
    Test.assertEqual(Game.getPlayer(), player);
    Game.setPlayer(null);
    Test.assert(Game.getPlayer() == null);
    return true;
}

(:test)
function gameSaveAndLoad(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.depth = 5;
    Game.time_played = 200;
    Game.difficulty = HARD;
    var saved = Game.save();
    Test.assertEqual(saved["depth"], 5);
    Test.assertEqual(saved["time_played"], 200);
    Test.assertEqual(saved["difficulty"], HARD);

    Game.init(0);
    Test.assertEqual(Game.depth, 0);
    Game.load(saved);
    Test.assertEqual(Game.depth, 5);
    Test.assertEqual(Game.time_played, 200);
    Test.assertEqual(Game.difficulty, HARD);
    return true;
}

(:test)
function gameLoadNullDoesNotCrash(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.load(null);
    return true;
}
