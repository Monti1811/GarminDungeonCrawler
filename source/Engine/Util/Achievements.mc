import Toybox.Lang;
import Toybox.Application.Storage;
import Toybox.WatchUi;

module Achievements {

    const STATS_KEY as String = "achv_stats";
    const SETS_KEY as String = "achv_sets";
    const DONE_KEY as String = "achv_done";

    var stats as Dictionary = {};
    var sets as Dictionary = {};
    var done as Dictionary = {};
    var _dirty as Boolean = false;
    var _test_mode as Boolean = false;

    // mode: :counter (bump), :gauge (monotonic max), :set (distinct members), :flag (direct unlock)
    var definitions as Array<Dictionary> = [
        // --- Combat (9) ---
        {"id"=>"first_blood", "title"=>"First Blood", "desc"=>"Defeat your first enemy.", "stat"=>"kills", "target"=>1, "mode"=>:counter, "hidden"=>false},
        {"id"=>"kill_50", "title"=>"Monster Hunter", "desc"=>"Defeat 50 enemies.", "stat"=>"kills", "target"=>50, "mode"=>:counter, "hidden"=>false},
        {"id"=>"kill_250", "title"=>"Exterminator", "desc"=>"Defeat 250 enemies.", "stat"=>"kills", "target"=>250, "mode"=>:counter, "hidden"=>false},
        {"id"=>"kill_1000", "title"=>"Slayer", "desc"=>"Defeat 1,000 enemies.", "stat"=>"kills", "target"=>1000, "mode"=>:counter, "hidden"=>false},
        {"id"=>"dmg_5000", "title"=>"Berserker", "desc"=>"Deal 5,000 total damage.", "stat"=>"damage_dealt", "target"=>5000, "mode"=>:counter, "hidden"=>false},
        {"id"=>"dmg_50000", "title"=>"Walking Calamity", "desc"=>"Deal 50,000 total damage.", "stat"=>"damage_dealt", "target"=>50000, "mode"=>:counter, "hidden"=>false},
        {"id"=>"heavy_hits", "title"=>"Heavy Hitter", "desc"=>"Land 100 hits of 25 or more damage.", "stat"=>"heavy_hits", "target"=>100, "mode"=>:counter, "hidden"=>false},
        {"id"=>"absorb_5000", "title"=>"Iron Body", "desc"=>"Survive 5,000 total damage.", "stat"=>"damage_taken", "target"=>5000, "mode"=>:counter, "hidden"=>false},
        {"id"=>"never_give_up", "title"=>"Never Give Up", "desc"=>"Fall in battle 10 times.", "stat"=>"deaths", "target"=>10, "mode"=>:counter, "hidden"=>false},
        // --- Dungeon (7) ---
        {"id"=>"depth_2", "title"=>"Deeper", "desc"=>"Reach dungeon depth 2.", "stat"=>"depth", "target"=>2, "mode"=>:gauge, "hidden"=>false},
        {"id"=>"depth_5", "title"=>"Into the Dark", "desc"=>"Reach dungeon depth 5.", "stat"=>"depth", "target"=>5, "mode"=>:gauge, "hidden"=>false},
        {"id"=>"depth_10", "title"=>"Abyss Walker", "desc"=>"Reach dungeon depth 10.", "stat"=>"depth", "target"=>10, "mode"=>:gauge, "hidden"=>false},
        {"id"=>"depth_50", "title"=>"Hellmarch", "desc"=>"Reach dungeon depth 50.", "stat"=>"depth", "target"=>50, "mode"=>:gauge, "hidden"=>false},
        {"id"=>"stairs_100", "title"=>"Stairmaster", "desc"=>"Climb 100 stairs.", "stat"=>"stairs", "target"=>100, "mode"=>:counter, "hidden"=>false},
        {"id"=>"steps_10000", "title"=>"Wanderer", "desc"=>"Walk 10,000 steps.", "stat"=>"steps", "target"=>10000, "mode"=>:counter, "hidden"=>false},
        {"id"=>"steps_100000", "title"=>"Marathoner", "desc"=>"Walk 100,000 steps.", "stat"=>"steps", "target"=>100000, "mode"=>:counter, "hidden"=>false},
        // --- Level & classes (7) ---
        {"id"=>"level_5", "title"=>"Apprentice", "desc"=>"Reach level 5.", "stat"=>"level", "target"=>5, "mode"=>:gauge, "hidden"=>false},
        {"id"=>"level_10", "title"=>"Veteran", "desc"=>"Reach level 10.", "stat"=>"level", "target"=>10, "mode"=>:gauge, "hidden"=>false},
        {"id"=>"level_20", "title"=>"Champion", "desc"=>"Reach level 20.", "stat"=>"level", "target"=>20, "mode"=>:gauge, "hidden"=>false},
        {"id"=>"level_50", "title"=>"Legend", "desc"=>"Reach level 50.", "stat"=>"level", "target"=>50, "mode"=>:gauge, "hidden"=>false},
        {"id"=>"play_3_classes", "title"=>"Trying On Shoes", "desc"=>"Play 3 different classes.", "stat"=>"classes_played", "target"=>3, "mode"=>:set, "hidden"=>false},
        {"id"=>"play_all_classes", "title"=>"Chameleon", "desc"=>"Play all 8 classes.", "stat"=>"classes_played", "target"=>8, "mode"=>:set, "hidden"=>false},
        {"id"=>"second_bar_10", "title"=>"Overcharged", "desc"=>"Fill your second bar to the maximum 10 times.", "stat"=>"second_bar_max", "target"=>10, "mode"=>:counter, "hidden"=>false},
        // --- Items & compendium (9) ---
        {"id"=>"first_item", "title"=>"Grabber", "desc"=>"Pick up your first item.", "stat"=>"items_picked", "target"=>1, "mode"=>:counter, "hidden"=>false},
        {"id"=>"items_250", "title"=>"Loot Goblin", "desc"=>"Pick up 250 items.", "stat"=>"items_picked", "target"=>250, "mode"=>:counter, "hidden"=>false},
        {"id"=>"all_slots", "title"=>"Fully Geared", "desc"=>"Equip an item in every slot.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>false},
        {"id"=>"upgrade_10", "title"=>"Apprentice Smith", "desc"=>"Upgrade items 10 times.", "stat"=>"upgrades", "target"=>10, "mode"=>:counter, "hidden"=>false},
        {"id"=>"masterwork", "title"=>"Masterwork", "desc"=>"Upgrade an item to the maximum level.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>false},
        {"id"=>"comp_items_50", "title"=>"Collector", "desc"=>"Discover 50 items.", "stat"=>"items_found", "target"=>50, "mode"=>:counter, "hidden"=>false},
        {"id"=>"comp_items_all", "title"=>"Archivist", "desc"=>"Discover all items.", "stat"=>"items_found", "target"=>173, "mode"=>:counter, "hidden"=>false},
        {"id"=>"comp_enemies_20", "title"=>"Naturalist", "desc"=>"Discover 20 enemies.", "stat"=>"enemies_seen", "target"=>20, "mode"=>:counter, "hidden"=>false},
        {"id"=>"comp_enemies_all", "title"=>"Bestiary Master", "desc"=>"Discover all enemies.", "stat"=>"enemies_seen", "target"=>39, "mode"=>:counter, "hidden"=>false},
        // --- Economy & quests (6) ---
        {"id"=>"gold_1000", "title"=>"Purse", "desc"=>"Earn 1,000 gold.", "stat"=>"gold_earned", "target"=>1000, "mode"=>:counter, "hidden"=>false},
        {"id"=>"gold_10000", "title"=>"Tycoon", "desc"=>"Earn 10,000 gold.", "stat"=>"gold_earned", "target"=>10000, "mode"=>:counter, "hidden"=>false},
        {"id"=>"buy_25", "title"=>"Regular", "desc"=>"Buy 25 items from merchants.", "stat"=>"buys", "target"=>25, "mode"=>:counter, "hidden"=>false},
        {"id"=>"quest_1", "title"=>"First Errand", "desc"=>"Claim your first quest reward.", "stat"=>"quests_done", "target"=>1, "mode"=>:counter, "hidden"=>false},
        {"id"=>"quest_25", "title"=>"Quest Lord", "desc"=>"Claim 25 quest rewards.", "stat"=>"quests_done", "target"=>25, "mode"=>:counter, "hidden"=>false},
        {"id"=>"quest_types_7", "title"=>"Well Rounded", "desc"=>"Complete one quest of every type.", "stat"=>"quest_types", "target"=>7, "mode"=>:set, "hidden"=>false},
        // --- Hidden (11) ---
        {"id"=>"not_a_scratch", "title"=>"Not A Scratch", "desc"=>"Descend a floor without taking damage.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>true},
        {"id"=>"close_call", "title"=>"Close Call", "desc"=>"Defeat an enemy while having only 1 HP.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>true},
        {"id"=>"pacifist", "title"=>"Pacifist", "desc"=>"Descend a floor without killing anyone.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>true},
        {"id"=>"greedy", "title"=>"Greedy", "desc"=>"Pick up 5 items in a single room.", "stat"=>"room_items", "target"=>5, "mode"=>:counter, "hidden"=>true},
        {"id"=>"big_spender", "title"=>"Big Spender", "desc"=>"Spend 500 gold in a single purchase.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>true},
        {"id"=>"demon_country", "title"=>"Demon Country", "desc"=>"Reach dungeon depth 70.", "stat"=>"depth", "target"=>70, "mode"=>:gauge, "hidden"=>true},
        {"id"=>"blood_depths", "title"=>"Blood Depths", "desc"=>"Reach dungeon depth 80.", "stat"=>"depth", "target"=>80, "mode"=>:gauge, "hidden"=>true},
        {"id"=>"who_am_i", "title"=>"Who Am I?", "desc"=>"Start a run as the Nameless class.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>true},
        {"id"=>"pack_rat", "title"=>"Pack Rat", "desc"=>"Carry 30 items at once.", "stat"=>"max_items_held", "target"=>30, "mode"=>:gauge, "hidden"=>true},
        {"id"=>"devastating", "title"=>"Devastating", "desc"=>"Defeat an enemy in a single hit.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>true},
        {"id"=>"read_the_manual", "title"=>"Read The Manual", "desc"=>"Read the abilities page of your character.", "stat"=>null, "target"=>1, "mode"=>:flag, "hidden"=>true},
    ];

    function init() as Void {
        var stored_stats = Storage.getValue(STATS_KEY) as Dictionary?;
        stats = stored_stats != null ? stored_stats : {};
        var stored_sets = Storage.getValue(SETS_KEY) as Dictionary?;
        sets = stored_sets != null ? stored_sets : {};
        var stored_done = Storage.getValue(DONE_KEY) as Dictionary?;
        done = stored_done != null ? stored_done : {};
        _dirty = false;
        // Central targets from Constants (module load order makes direct use in the
        // definitions array unsafe, so patch them at init time).
        var items_def = findDefinition("comp_items_all");
        if (items_def != null) {
            items_def["target"] = $.Constants.ACHV_ITEMS_TOTAL;
        }
        var enemies_def = findDefinition("comp_enemies_all");
        if (enemies_def != null) {
            enemies_def["target"] = $.Constants.ACHV_ENEMIES_TOTAL;
        }
    }

    function getDefinitions() as Array<Dictionary> {
        return definitions;
    }

    function findDefinition(id as String) as Dictionary? {
        for (var i = 0; i < definitions.size(); i++) {
            if ((definitions[i]["id"] as String).equals(id)) {
                return definitions[i];
            }
        }
        return null;
    }

    function isUnlocked(id as String) as Boolean {
        return done.hasKey(id);
    }

    function getStat(stat as String) as Number {
        if (stats.hasKey(stat)) {
            return stats[stat] as Number;
        }
        return 0;
    }

    function getSetSize(set_name as String) as Number {
        if (sets.hasKey(set_name)) {
            var arr = sets[set_name] as Array?;
            if (arr != null) {
                return arr.size();
            }
        }
        return 0;
    }

    // Progress towards the target, clamped. Unlocked achievements show their full target.
    function getProgress(def as Dictionary) as Number {
        var target = def["target"] as Number;
        if (isUnlocked(def["id"] as String)) {
            return target;
        }
        var mode = def["mode"] as Symbol;
        if (mode == :flag) {
            return 0;
        }
        var stat = def["stat"] as String?;
        if (stat == null) {
            return 0;
        }
        if (mode == :set) {
            var size = getSetSize(stat);
            return size > target ? target : size;
        }
        var value = getStat(stat);
        return value > target ? target : value;
    }

    // Hidden achievements are invisible until unlocked.
    function isVisible(def as Dictionary) as Boolean {
        if (!(def["hidden"] as Boolean)) {
            return true;
        }
        return isUnlocked(def["id"] as String);
    }

    function getVisibleDefinitions() as Array<Dictionary> {
        var visible = [] as Array<Dictionary>;
        for (var i = 0; i < definitions.size(); i++) {
            if (isVisible(definitions[i])) {
                visible.add(definitions[i]);
            }
        }
        return visible;
    }

    function getUnlockedCount() as Number {
        var count = 0;
        for (var i = 0; i < definitions.size(); i++) {
            if (isUnlocked(definitions[i]["id"] as String)) {
                count += 1;
            }
        }
        return count;
    }

    function getHiddenCount() as Number {
        var count = 0;
        for (var i = 0; i < definitions.size(); i++) {
            if (definitions[i]["hidden"] as Boolean && isUnlocked(definitions[i]["id"] as String)) {
                count += 1;
            }
        }
        return count;
    }

    function getHiddenTotal() as Number {
        var count = 0;
        for (var i = 0; i < definitions.size(); i++) {
            if (definitions[i]["hidden"] as Boolean) {
                count += 1;
            }
        }
        return count;
    }

    function bump(stat as String, amount as Number) as Void {
        if (amount == 0) {
            return;
        }
        var current = getStat(stat);
        stats[stat] = current + amount;
        _dirty = true;
        checkStat(stat);
    }

    // Monotonic: never decreases (level, depth are per-run but achievements track the best ever).
    function setGauge(stat as String, value as Number) as Void {
        if (value <= getStat(stat)) {
            return;
        }
        stats[stat] = value;
        _dirty = true;
        checkStat(stat);
    }

    function mark(set_name as String, member as String) as Void {
        var arr = [] as Array<String>;
        if (sets.hasKey(set_name)) {
            var existing = sets[set_name] as Array?;
            if (existing != null) {
                arr = existing;
            }
        }
        for (var i = 0; i < arr.size(); i++) {
            if (arr[i].equals(member)) {
                return;
            }
        }
        arr.add(member);
        sets[set_name] = arr;
        _dirty = true;
        checkStat(set_name);
    }

    function unlock(id as String) as Void {
        if (done.hasKey(id)) {
            return;
        }
        var def = findDefinition(id);
        if (def == null) {
            return;
        }
        done[id] = true;
        _dirty = true;
        if (!_test_mode) {
            WatchUi.showToast("Achievement: " + (def["title"] as String), {:icon=>$.Rez.Drawables.aboutToastIcon});
        }
    }

    function checkStat(stat as String) as Void {
        for (var i = 0; i < definitions.size(); i++) {
            var def = definitions[i];
            if (def["stat"] == null || !(def["stat"] as String).equals(stat)) {
                continue;
            }
            if (getProgress(def) >= (def["target"] as Number)) {
                unlock(def["id"] as String);
            }
        }
    }

    // Floor/room scoped counters (persisted, reset on transitions).
    function resetFloor() as Void {
        stats["floor_damage"] = 0;
        stats["floor_kills"] = 0;
        stats["room_items"] = 0;
        _dirty = true;
    }

    function resetRoom() as Void {
        stats["room_items"] = 0;
        _dirty = true;
    }

    function checkFloorComplete() as Void {
        // Too easy on early floors - only count from depth 20 on.
        if ($.Game.depth < $.Constants.ACHV_FLOOR_MIN_DEPTH) {
            return;
        }
        if (getStat("floor_damage") <= 0) {
            unlock("not_a_scratch");
        }
        if (getStat("floor_kills") <= 0) {
            unlock("pacifist");
        }
    }

    function onRunStart(player as Player) as Void {
        // God (999) is not part of the normal game and never counts as a class.
        if (player.getId() != 999) {
            mark("classes_played", player.getId().toString());
        }
        if (player.getId() == 3) {
            unlock("who_am_i");
        }
        resetFloor();
    }

    function discoverItem(item_id as Number) as Void {
        if ($.SaveData.discovered_items.hasKey(item_id)) {
            return;
        }
        $.SaveData.discovered_items[item_id] = true;
        bump("items_found", 1);
    }

    function discoverEnemy(enemy_id as Number) as Void {
        if ($.SaveData.discovered_enemies.hasKey(enemy_id)) {
            return;
        }
        $.SaveData.discovered_enemies[enemy_id] = true;
        bump("enemies_seen", 1);
    }

    function flush() as Void {
        // Never touch real storage from a test session (resetForTest sets _test_mode).
        if (_test_mode) {
            return;
        }
        if (!_dirty) {
            return;
        }
        Storage.setValue(STATS_KEY, stats);
        Storage.setValue(SETS_KEY, sets);
        Storage.setValue(DONE_KEY, done);
        _dirty = false;
    }

    // Clears achievement progress only (saves/settings untouched).
    function resetAchievements() as Void {
        Storage.deleteValue(STATS_KEY);
        Storage.deleteValue(SETS_KEY);
        Storage.deleteValue(DONE_KEY);
        stats = {};
        sets = {};
        done = {};
        _dirty = false;
    }

    (:debug)
    function flushForTest() as Void {
        Storage.setValue(STATS_KEY, stats);
        Storage.setValue(SETS_KEY, sets);
        Storage.setValue(DONE_KEY, done);
        _dirty = false;
    }

    (:debug)
    function snapshotStorage() as Dictionary {
        var snap = {} as Dictionary;
        var s = Storage.getValue(STATS_KEY);
        if (s != null) {
            snap["stats"] = s;
        }
        var st = Storage.getValue(SETS_KEY);
        if (st != null) {
            snap["sets"] = st;
        }
        var d = Storage.getValue(DONE_KEY);
        if (d != null) {
            snap["done"] = d;
        }
        return snap;
    }

    (:debug)
    function restoreStorage(snap as Dictionary) as Void {
        restoreKey(STATS_KEY, snap["stats"]);
        restoreKey(SETS_KEY, snap["sets"]);
        restoreKey(DONE_KEY, snap["done"]);
    }

    (:debug)
    function restoreKey(key as String, value as Object?) as Void {
        if (value == null) {
            Storage.deleteValue(key);
        } else {
            Storage.setValue(key, value);
        }
    }

    (:debug)
    function resetForTest() as Void {
        stats = {};
        sets = {};
        done = {};
        _dirty = false;
        _test_mode = true;
    }
}
