import Toybox.Lang;
import Toybox.Test;

(:test)
function getRoomNameReturnsExpectedString(logger as Test.Logger) as Boolean {
    $.SaveData.chosen_save = "0";
    var name = SimUtil.getRoomName(1, 2);
    Test.assertEqual(name, "0_dungeon_1_2");
    return true;
}

(:test)
function getRoomNameWithDifferentCoords(logger as Test.Logger) as Boolean {
    $.SaveData.chosen_save = "0";
    var name = SimUtil.getRoomName(3, 7);
    Test.assertEqual(name, "0_dungeon_3_7");
    return true;
}

(:test)
function getPosFromRoomNameParsesCorrectly(logger as Test.Logger) as Boolean {
    var pos = SimUtil.getPosFromRoomName("0_dungeon_1_2");
    Test.assertEqual(pos[0], 1);
    Test.assertEqual(pos[1], 2);
    return true;
}

(:test)
function getRoomNamePosRoundTrip(logger as Test.Logger) as Boolean {
    $.SaveData.chosen_save = "0";
    for (var x = 0; x < 10; x++) {
        for (var y = 0; y < 10; y++) {
            var name = SimUtil.getRoomName(x, y);
            var pos = SimUtil.getPosFromRoomName(name);
            Test.assertEqual(pos[0], x);
            Test.assertEqual(pos[1], y);
        }
    }
    return true;
}

(:test)
function addDictToDictMergesEntries(logger as Test.Logger) as Boolean {
    var dict1 = {} as Dictionary;
    dict1["a"] = 1;
    dict1["b"] = 2;
    var dict2 = {} as Dictionary;
    dict2["c"] = 3;
    dict2["d"] = 4;
    SimUtil.addDictToDict(dict1, dict2);
    Test.assertEqual(dict1["a"], 1);
    Test.assertEqual(dict1["b"], 2);
    Test.assertEqual(dict1["c"], 3);
    Test.assertEqual(dict1["d"], 4);
    return true;
}

(:test)
function addDictToDictOverwritesExisting(logger as Test.Logger) as Boolean {
    var dict1 = {} as Dictionary;
    dict1["a"] = 1;
    dict1["b"] = 2;
    var dict2 = {} as Dictionary;
    dict2["b"] = 99;
    dict2["c"] = 3;
    SimUtil.addDictToDict(dict1, dict2);
    Test.assertEqual(dict1["a"], 1);
    Test.assertEqual(dict1["b"], 99);
    Test.assertEqual(dict1["c"], 3);
    return true;
}

(:test)
function addDictToDictEmptySource(logger as Test.Logger) as Boolean {
    var dict1 = {} as Dictionary;
    dict1["a"] = 1;
    var dict2 = {} as Dictionary;
    SimUtil.addDictToDict(dict1, dict2);
    Test.assertEqual(dict1.size(), 1);
    Test.assertEqual(dict1["a"], 1);
    return true;
}

(:test)
function addDictToDictEmptyTarget(logger as Test.Logger) as Boolean {
    var dict1 = {} as Dictionary;
    var dict2 = {} as Dictionary;
    dict2["a"] = 1;
    dict2["b"] = 2;
    SimUtil.addDictToDict(dict1, dict2);
    Test.assertEqual(dict1.size(), 2);
    Test.assertEqual(dict1["a"], 1);
    Test.assertEqual(dict1["b"], 2);
    return true;
}

(:test)
function getRandomFromArrayReturnsElement(logger as Test.Logger) as Boolean {
    var arr = [10, 20, 30] as Array<Number>;
    var result = SimUtil.getRandomFromArray(arr);
    var found = false;
    if (result == 10 || result == 20 || result == 30) {
        found = true;
    }
    Test.assert(found);
    return true;
}

(:test)
function getRandomFromArraySingleElement(logger as Test.Logger) as Boolean {
    var arr = [42] as Array<Number>;
    var result = SimUtil.getRandomFromArray(arr);
    Test.assertEqual(result, 42);
    return true;
}

(:test)
function getRandomFromDictReturnsValue(logger as Test.Logger) as Boolean {
    var dict = {} as Dictionary;
    dict["a"] = 1;
    dict["b"] = 2;
    dict["c"] = 3;
    var result = SimUtil.getRandomFromDict(dict);
    var found = false;
    if (result == 1 || result == 2 || result == 3) {
        found = true;
    }
    Test.assert(found);
    return true;
}

(:test)
function getRandomKeyFromDictReturnsKey(logger as Test.Logger) as Boolean {
    var dict = {} as Dictionary;
    dict["a"] = 1;
    var result = SimUtil.getRandomKeyFromDict(dict);
    Test.assertEqual(dict[result], 1);
    return true;
}
