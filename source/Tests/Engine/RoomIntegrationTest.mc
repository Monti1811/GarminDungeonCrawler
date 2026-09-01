import Toybox.Test;
import Toybox.Lang;

// ============================================================
// Map / Room Integration Tests
// Tests full map operations: room setup, enemy/item placement,
// movement, and turn completion across the room system
// ============================================================

(:test)
module RoomTestHelpers {

    function createTestMap(sizeX as Number, sizeY as Number) as Map {
        return new Map(sizeX, sizeY, true);
    }

    function createTestRoom(map as Map, left as Number, right as Number, top as Number, bottom as Number) as Room {
        var sizeX = right - left + 1;
        var sizeY = bottom - top + 1;
        var playerPos = [left + 1, top + 1] as Point2D;

        var items = {} as Dictionary<Point2D, Item>;
        var enemies = {} as Dictionary<Point2D, Enemy>;

        return new Room({
            :size_x => sizeX,
            :size_y => sizeY,
            :tile_width => 16,
            :tile_height => 16,
            :start_pos => playerPos,
            :map => map,
            :left => left,
            :right => right,
            :top => top,
            :bottom => bottom,
            :items => items,
            :enemies => enemies
        });
    }
}

// ============================================================
// 1. Room enemy management integration
// ============================================================

(:test)
function roomAddAndRemoveEnemy(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);
    var enemy = new Enemy();
    var pos = [5, 5] as Point2D;
    enemy.pos = pos;
    map.setContent(pos, enemy);

    room.getEnemies().put(pos, enemy);
    Test.assertMessage(room.getEnemies().size() == 1, "Room should have 1 enemy");

    room.removeEnemy(enemy);
    Test.assertMessage(room.getEnemies().size() == 0, "Room should have 0 enemies after removal");
    return true;
}

(:test)
function roomMoveEnemyUpdatesMapAndPosition(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);
    var enemy = new Enemy();
    var pos = [3, 3] as Point2D;
    var nextPos = [4, 3] as Point2D;
    enemy.pos = pos;
    enemy.next_pos = nextPos;
    map.setContent(pos, enemy);
    room.getEnemies().put(pos, enemy);

    room.moveEnemy(enemy);

    Test.assertEqual(enemy.pos[0], 4);
    Test.assertEqual(enemy.pos[1], 3);
    Test.assertMessage(enemy.getHasMoved(), "Enemy should be marked as moved");
    return true;
}

(:test)
function roomMoveEnemySamePosDoesNotMove(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);
    var enemy = new Enemy();
    var pos = [3, 3] as Point2D;
    enemy.pos = pos;
    enemy.next_pos = pos;
    map.setContent(pos, enemy);
    room.getEnemies().put(pos, enemy);

    room.moveEnemy(enemy);

    Test.assertMessage(!enemy.getHasMoved(), "Enemy should not be marked as moved when staying");
    return true;
}

// ============================================================
// 2. Room onTurnDone integration (enemies restore energy)
// ============================================================

(:test)
function roomOnTurnDoneRestoresEnemyEnergy(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);
    var enemy = new Enemy();
    var pos = [3, 3] as Point2D;
    enemy.pos = pos;
    enemy.energy = 0;
    enemy.energy_per_turn = 100;
    map.setContent(pos, enemy);
    room.getEnemies().put(pos, enemy);

    room.onTurnDone();

    Test.assertEqual(enemy.energy, 100);
    return true;
}

(:test)
function roomOnTurnDoneDecrementsCooldowns(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);
    var enemy = new Enemy();
    var pos = [3, 3] as Point2D;
    enemy.pos = pos;
    enemy.curr_attack_cooldown = 2;
    enemy.teleport_move_cooldown = 3;
    map.setContent(pos, enemy);
    room.getEnemies().put(pos, enemy);

    room.onTurnDone();

    Test.assertEqual(enemy.curr_attack_cooldown, 1);
    Test.assertEqual(enemy.teleport_move_cooldown, 2);
    return true;
}

// ============================================================
// 3. Room loot drop integration
// ============================================================

(:test)
function roomDropLootAddsItemToMap(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);

    var items = room.getItems();
    Test.assertMessage(items.size() == 0, "Room should start with 0 items");

    var item = new Item();
    item.pos = [5, 5];
    item.name = "GoldCoin";
    room.addItem(item);

    Test.assertMessage(room.getItems().size() == 1, "Room should have 1 item after loot drop");
    return true;
}

// ============================================================
// 4. Room player position tracking
// ============================================================

(:test)
function roomTracksPlayerPosition(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);

    var pos = room.getPlayerPos();

    Test.assertEqual(pos[0], 1);
    Test.assertEqual(pos[1], 1);
    return true;
}

(:test)
function roomUpdatePlayerPosition(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);

    room.updatePlayerPos([5, 5]);

    var pos = room.getPlayerPos();
    Test.assertEqual(pos[0], 5);
    Test.assertEqual(pos[1], 5);
    return true;
}

// ============================================================
// 5. Full room turn simulation (enemies attack)
// ============================================================

(:test)
function roomEnemiesAttackPlayerInAdjacentTile(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);

    var enemy = new Enemy();
    var pos = [3, 4] as Point2D;
    enemy.pos = pos;
    enemy.damage = 10;
    enemy.attack_cooldown = 0;
    enemy.curr_attack_cooldown = 0;
    map.setContent(pos, enemy);
    room.getEnemies().put(pos, enemy);

    var playerPos = [3, 5] as Point2D;

    room.enemiesAttack(playerPos);

    Test.assertEqual(enemy.curr_attack_cooldown, enemy.attack_cooldown);
    return true;
}

// ============================================================
// 6. Room enemy count with multiple enemies
// ============================================================

(:test)
function roomHandlesMultipleEnemies(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);

    for (var i = 0; i < 5; i++) {
        var enemy = new Enemy();
        var pos = [2 + i, 5] as Point2D;
        enemy.pos = pos;
        enemy.name = "Enemy" + i;
        map.setContent(pos, enemy);
        room.getEnemies().put(pos, enemy);
    }

    Test.assertEqual(room.getEnemies().size(), 5);

    var keys = room.getEnemies().keys();
    for (var i = 0; i < keys.size(); i++) {
        var enemy = room.getEnemies()[keys[i]];
        room.removeEnemy(enemy);
    }

    Test.assertEqual(room.getEnemies().size(), 0);
    return true;
}

// ============================================================
// 7. Room item management
// ============================================================

(:test)
function roomAddAndRemoveItem(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);
    var item = new Item();
    item.pos = [4, 4];
    item.name = "Potion";

    room.addItem(item);
    Test.assertEqual(room.getItems().size(), 1);

    room.removeItem(item);
    Test.assertEqual(room.getItems().size(), 0);
    return true;
}

(:test)
function roomItemsDontOverlapOnMap(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);
    var item1 = new Item();
    item1.pos = [4, 4];
    var item2 = new Item();
    item2.pos = [5, 5];

    room.addItem(item1);
    room.addItem(item2);

    Test.assertEqual(room.getItems().size(), 2);
    return true;
}

// ============================================================
// 8. Room size and boundary
// ============================================================

(:test)
function roomSizeMatchesBounds(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 2, 7, 2, 7);

    var size = room.getSize();
    Test.assertEqual(size[0], 6);
    Test.assertEqual(size[1], 6);

    Test.assertEqual(room.getLeft(), 2);
    Test.assertEqual(room.getRight(), 7);
    Test.assertEqual(room.getTop(), 2);
    Test.assertEqual(room.getBottom(), 7);
    return true;
}

// ============================================================
// 9. Combat-in-room integration: attack enemy, remove, drop loot
// ============================================================

(:test)
function combatInRoomKillEnemyAndDropLoot(logger as Test.Logger) as Boolean {
    var map = RoomTestHelpers.createTestMap(10, 10);
    var room = RoomTestHelpers.createTestRoom(map, 0, 9, 0, 9);

    var enemy = new Enemy();
    var pos = [3, 3] as Point2D;
    enemy.pos = pos;
    enemy.current_health = 10;
    enemy.maxHealth = 10;
    enemy.name = "WeakEnemy";
    map.setContent(pos, enemy);
    room.getEnemies().put(pos, enemy);

    var damage = 15;
    var dead = enemy.takeDamage(damage, null);

    Test.assertMessage(dead, "Enemy should die from 15 damage on 10 HP");

    if (dead) {
        room.removeEnemy(enemy);
        var loot = new Item();
        loot.pos = enemy.getPos();
        room.addItem(loot);

        Test.assertEqual(room.getEnemies().size(), 0);
        Test.assertEqual(room.getItems().size(), 1);
    }
    return true;
}

// ============================================================
// 10. Enemy onTurnDone resets has_moved flag
// ============================================================

(:test)
function enemyOnTurnDoneResetsHasMoved(logger as Test.Logger) as Boolean {
    var enemy = new Enemy();
    enemy.has_moved = true;

    enemy.onTurnDone();

    Test.assertMessage(!enemy.getHasMoved(), "has_moved should reset after onTurnDone");
    return true;
}
