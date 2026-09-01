import Toybox.Test;
import Toybox.Lang;

// --- Tile constructor ---

(:test)
function tileConstructorSetsXY(logger as Test.Logger) as Boolean {
    var tile = new Tile(3, 5);
    Test.assertEqual(tile.x, 3);
    Test.assertEqual(tile.y, 5);
    return true;
}

(:test)
function tileDefaultTypeIsEmpty(logger as Test.Logger) as Boolean {
    var tile = new Tile(0, 0);
    Test.assertEqual(tile.type, EMPTY);
    return true;
}

(:test)
function tileDefaultPlayerIsFalse(logger as Test.Logger) as Boolean {
    var tile = new Tile(0, 0);
    Test.assertMessage(!tile.player, "default player should be false");
    return true;
}

(:test)
function tileDefaultContentIsNull(logger as Test.Logger) as Boolean {
    var tile = new Tile(0, 0);
    Test.assertMessage(tile.content == null, "default content should be null");
    return true;
}

// --- deepcopy ---

(:test)
function deepcopyCreatesIndependentTile(logger as Test.Logger) as Boolean {
    var original = new Tile(1, 2);
    original.type = WALL;
    original.player = true;
    original.content = "test";

    var copy = original.deepcopy();

    Test.assertEqual(copy.x, 1);
    Test.assertEqual(copy.y, 2);
    Test.assertEqual(copy.type, WALL);
    Test.assertMessage(copy.player, "copied player should be true");
    Test.assertEqual(copy.content, "test");

    // Modify copy, original should be unchanged
    copy.type = PASSABLE;
    copy.player = false;
    Test.assertEqual(original.type, WALL);
    Test.assertMessage(original.player, "original player should still be true");
    return true;
}

// --- save/load ---

(:test)
function tileSaveLoadRoundTrip(logger as Test.Logger) as Boolean {
    var tile = new Tile(4, 7);
    tile.type = PASSABLE;

    var saved = tile.save();
    var loaded = Tile.load(saved);

    Test.assertEqual(loaded.x, 4);
    Test.assertEqual(loaded.y, 7);
    Test.assertEqual(loaded.type, PASSABLE);
    return true;
}

(:test)
function tileSaveLoadWallType(logger as Test.Logger) as Boolean {
    var tile = new Tile(0, 0);
    tile.type = WALL;

    var saved = tile.save();
    var loaded = Tile.load(saved);

    Test.assertEqual(loaded.type, WALL);
    return true;
}

(:test)
function tileSaveLoadStairsType(logger as Test.Logger) as Boolean {
    var tile = new Tile(2, 3);
    tile.type = STAIRS;

    var saved = tile.save();
    var loaded = Tile.load(saved);

    Test.assertEqual(loaded.type, STAIRS);
    Test.assertEqual(loaded.x, 2);
    Test.assertEqual(loaded.y, 3);
    return true;
}
