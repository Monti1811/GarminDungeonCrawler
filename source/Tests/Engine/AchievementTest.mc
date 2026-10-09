import Toybox.Test;
import Toybox.Lang;

// --- Definition integrity ---

(:test)
function achievementDefinitionsValid(logger as Test.Logger) as Boolean {
    var defs = $.Achievements.getDefinitions();
    Test.assertMessage(defs.size() == 49, "expected 49 definitions, got " + defs.size());
    var ids = {} as Dictionary;
    var visible = 0;
    var secret_count = 0;
    for (var i = 0; i < defs.size(); i++) {
        var def = defs[i];
        var id = def["id"] as String;
        var title = def["title"] as String;
        var desc = def["desc"] as String;
        var mode = def["mode"] as Symbol;
        var target = def["target"] as Number;
        Test.assertMessage(id.length() > 0, "definition " + i + " has empty id");
        Test.assertMessage(title.length() > 0, id + " has empty title");
        Test.assertMessage(desc.length() > 0, id + " has empty description");
        Test.assertMessage(target > 0, id + " has target <= 0");
        Test.assertMessage(!ids.hasKey(id), "duplicate id " + id);
        ids[id] = true;
        Test.assertMessage(mode == :counter || mode == :gauge || mode == :set || mode == :flag, id + " has invalid mode");
        if (mode != :flag) {
            Test.assertMessage(def["stat"] != null, id + " is missing a stat");
        }
        if (def["hidden"] as Boolean) {
            secret_count += 1;
        } else {
            visible += 1;
        }
    }
    Test.assertMessage(visible == 38, "expected 38 visible, got " + visible);
    Test.assertMessage(secret_count == 11, "expected 11 hidden, got " + secret_count);
    return true;
}

// --- Counter progress and unlock ---

(:test)
function achievementBumpProgressesAndUnlocks(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    $.Achievements.bump("kills", 1);
    Test.assert($.Achievements.getStat("kills") == 1);
    Test.assert($.Achievements.isUnlocked("first_blood"));
    Test.assert(!$.Achievements.isUnlocked("kill_50"));

    $.Achievements.bump("kills", 49);
    Test.assert($.Achievements.isUnlocked("kill_50"));
    Test.assert(!$.Achievements.isUnlocked("kill_250"));

    var def = $.Achievements.findDefinition("kill_250");
    Test.assert(def != null);
    Test.assert($.Achievements.getProgress(def as Dictionary) == 50);

    var def_done = $.Achievements.findDefinition("first_blood");
    Test.assert($.Achievements.getProgress(def_done as Dictionary) == 1);
    $.Achievements.resetForTest();
    return true;
}

(:test)
function achievementUnlockOnlyOnce(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    $.Achievements.unlock("greedy");
    Test.assert($.Achievements.isUnlocked("greedy"));
    var def = $.Achievements.findDefinition("greedy") as Dictionary;
    Test.assert($.Achievements.getProgress(def) == 5);
    // Second unlock must not change anything
    $.Achievements.unlock("greedy");
    Test.assert($.Achievements.isUnlocked("greedy"));
    Test.assert($.Achievements.getUnlockedCount() == 1);
    $.Achievements.resetForTest();
    return true;
}

// --- Gauges never decrease ---

(:test)
function achievementGaugeIsMonotonic(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    $.Achievements.setGauge("depth", 4);
    $.Achievements.setGauge("depth", 2);
    Test.assert($.Achievements.getStat("depth") == 4);
    Test.assert($.Achievements.isUnlocked("depth_2"));
    Test.assert(!$.Achievements.isUnlocked("depth_5"));
    $.Achievements.setGauge("depth", 5);
    Test.assert($.Achievements.getStat("depth") == 5);
    Test.assert($.Achievements.isUnlocked("depth_5"));
    $.Achievements.resetForTest();
    return true;
}

// --- Sets are idempotent and progress by size ---

(:test)
function achievementSetMembersAreUnique(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    $.Achievements.mark("classes_played", "0");
    $.Achievements.mark("classes_played", "0");
    $.Achievements.mark("classes_played", "1");
    Test.assert($.Achievements.getSetSize("classes_played") == 2);
    Test.assert(!$.Achievements.isUnlocked("play_3_classes"));
    $.Achievements.mark("classes_played", "2");
    Test.assert($.Achievements.getSetSize("classes_played") == 3);
    Test.assert($.Achievements.isUnlocked("play_3_classes"));
    Test.assert(!$.Achievements.isUnlocked("play_all_classes"));
    $.Achievements.resetForTest();
    return true;
}

// --- Hidden visibility ---

(:test)
function achievementHiddenVisibility(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    var def = $.Achievements.findDefinition("greedy") as Dictionary;
    Test.assert(!$.Achievements.isVisible(def));
    Test.assert(!$.Achievements.isVisible($.Achievements.findDefinition("not_a_scratch") as Dictionary));
    var visible = $.Achievements.getVisibleDefinitions();
    Test.assert(visible.size() == 38);
    Test.assert($.Achievements.getHiddenCount() == 0);
    Test.assert($.Achievements.getHiddenTotal() == 11);

    $.Achievements.unlock("greedy");
    Test.assert($.Achievements.isVisible(def));
    visible = $.Achievements.getVisibleDefinitions();
    Test.assert(visible.size() == 39);
    Test.assert($.Achievements.getHiddenCount() == 1);
    $.Achievements.resetForTest();
    return true;
}

// --- Floor checks ---

(:test)
function achievementFloorChecksUnlockCorrectly(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    $.Game.depth = $.Constants.ACHV_FLOOR_MIN_DEPTH;
    $.Achievements.resetFloor();
    $.Achievements.bump("floor_damage", 10);
    $.Achievements.checkFloorComplete();
    Test.assert(!$.Achievements.isUnlocked("not_a_scratch"));
    Test.assert($.Achievements.isUnlocked("pacifist"));

    $.Achievements.resetForTest();
    $.Achievements.resetFloor();
    $.Achievements.checkFloorComplete();
    Test.assert($.Achievements.isUnlocked("not_a_scratch"));
    Test.assert($.Achievements.isUnlocked("pacifist"));
    $.Game.depth = 0;
    $.Achievements.resetForTest();
    return true;
}

(:test)
function achievementFloorChecksRequireMinDepth(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    $.Game.depth = $.Constants.ACHV_FLOOR_MIN_DEPTH - 1;
    $.Achievements.resetFloor();
    $.Achievements.checkFloorComplete();
    Test.assert(!$.Achievements.isUnlocked("not_a_scratch"));
    Test.assert(!$.Achievements.isUnlocked("pacifist"));
    $.Game.depth = 0;
    $.Achievements.resetForTest();
    return true;
}

(:test)
function achievementResetFloorClearsCounters(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    $.Achievements.bump("floor_damage", 7);
    $.Achievements.bump("room_items", 3);
    $.Achievements.resetRoom();
    Test.assert($.Achievements.getStat("room_items") == 0);
    Test.assert($.Achievements.getStat("floor_damage") == 7);
    $.Achievements.resetFloor();
    Test.assert($.Achievements.getStat("floor_damage") == 0);
    Test.assert($.Achievements.getStat("floor_kills") == 0);
    Test.assert($.Achievements.getStat("room_items") == 0);
    $.Achievements.resetForTest();
    return true;
}

// --- Run start: classes and hidden class achievements ---

(:test)
function achievementRunStartMarksClass(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    var warrior = $.Players.createPlayerFromId(0, null);
    $.Achievements.onRunStart(warrior);
    Test.assert($.Achievements.getSetSize("classes_played") == 1);
    Test.assert(!$.Achievements.isUnlocked("who_am_i"));
    Test.assert(!$.Achievements.isUnlocked("play_3_classes"));

    var nameless = $.Players.createPlayerFromId(3, null);
    $.Achievements.onRunStart(nameless);
    Test.assert($.Achievements.getSetSize("classes_played") == 2);
    Test.assert($.Achievements.isUnlocked("who_am_i"));

    // God is not part of the normal game: no class credit, no achievement.
    var god = $.Players.createPlayerFromId(999, null);
    $.Achievements.onRunStart(god);
    Test.assert($.Achievements.getSetSize("classes_played") == 2);
    Test.assert(!$.Achievements.isUnlocked("divine"));

    $.Achievements.resetForTest();
    return true;
}

// --- Compendium discovery helpers ---

(:test)
function achievementDiscoveryCountsOnce(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    var old_items = $.SaveData.discovered_items;
    var old_enemies = $.SaveData.discovered_enemies;
    $.SaveData.discovered_items = {};
    $.SaveData.discovered_enemies = {};

    $.Achievements.discoverItem(1);
    $.Achievements.discoverItem(1);
    $.Achievements.discoverItem(2);
    Test.assert($.Achievements.getStat("items_found") == 2);

    $.Achievements.discoverEnemy(5);
    $.Achievements.discoverEnemy(5);
    Test.assert($.Achievements.getStat("enemies_seen") == 1);

    $.SaveData.discovered_items = old_items;
    $.SaveData.discovered_enemies = old_enemies;
    $.Achievements.resetForTest();
    return true;
}

// --- pack_rat tracks item units, not weight ---

(:test)
function achievementPackRatTracksItemUnits(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    var inv = new Inventory(1000);
    var sword = $.Items.createItemFromId(8) as Item;
    sword.amount = 29;
    Test.assert(inv.add(sword));
    Test.assert($.Achievements.getStat("max_items_held") == 29);
    Test.assert(!$.Achievements.isUnlocked("pack_rat"));

    var sword2 = $.Items.createItemFromId(8) as Item;
    Test.assert(inv.add(sword2));
    Test.assert($.Achievements.getStat("max_items_held") == 30);
    Test.assert($.Achievements.isUnlocked("pack_rat"));
    $.Achievements.resetForTest();
    return true;
}

// --- Persistence roundtrip ---

(:test)
function achievementStatsSurviveFlushAndInit(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    var snap = $.Achievements.snapshotStorage();
    $.Achievements.bump("kills", 42);
    $.Achievements.mark("classes_played", "7");
    $.Achievements.unlock("first_blood");
    $.Achievements.flushForTest();

    $.Achievements.init();
    var kills = $.Achievements.getStat("kills");
    var classes = $.Achievements.getSetSize("classes_played");
    var first_blood = $.Achievements.isUnlocked("first_blood");
    var kill_50 = $.Achievements.isUnlocked("kill_50");

    // Restore the player's real storage BEFORE asserting, so a failing
    // assert can never leave test data behind in the app's storage.
    $.Achievements.resetForTest();
    $.Achievements.restoreStorage(snap);
    $.Achievements.init();

    Test.assert(kills == 42);
    Test.assert(classes == 1);
    Test.assert(first_blood);
    Test.assert(!kill_50);
    return true;
}

// --- Archivist target: shields and backpacks must spawn (dungeon + merchant) ---

(:test)
function achievementArchivistItemsAreReachable(logger as Test.Logger) as Boolean {
    $.Achievements.resetForTest();
    Test.assertEqual($.Constants.ACHV_ITEMS_TOTAL, 173);

    var result = new ItemSpecificValues(0).getDungeonItemWeightsForClass(0);
    var pools = result[0] as Array;
    var armor_pool = pools[1] as Dictionary;
    var merchant_pool = pools[4] as Dictionary;

    var ids = [1200, 1201, 1202, 1203, 1250, 1251, 1252];
    for (var i = 0; i < ids.size(); i++) {
        Test.assertMessage(armor_pool.hasKey(ids[i]), "armor pool missing " + ids[i]);
        Test.assertMessage(merchant_pool.hasKey(ids[i]), "merchant pool missing " + ids[i]);
    }
    Test.assert(armor_pool[1200] > 0);
    Test.assert(armor_pool[1250] > 0);

    $.Achievements.resetForTest();
    return true;
}
