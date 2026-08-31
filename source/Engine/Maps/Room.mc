import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;

enum MapElement {
    N_P, // NON PASSABLE
    WLE, // WALL LEFT
    WRI, // WALL RIGHT
    WTO, // WALL TOP
    WBO, // WALL BOTTOM
    WTL, // WALL TOP LEFT
    WTR, // WALL TOP RIGHT
    WBL, // WALL BOTTOM LEFT
    WBR, // WALL BOTTOM RIGHT
    PAS  // PASSABLE
}

class Room {

    private var _size_x as Number;
    private var _size_y as Number;
    private var _tile_width as Number;
    private var _tile_height as Number;

    private var _map as Map?;
    private var _stairs as Point2D?;

    private var _start_pos as Point2D?;

    private var _items as Dictionary<Point2D, Item>;
    private var _enemies as Dictionary<Point2D, Enemy>;
    private var _npcs as Dictionary<Point2D, NPC>;

    private var _player_pos as Point2D;

    private var _left as Number;
    private var _right as Number;
    private var _top as Number;
    private var _bottom as Number;

    private var _shape as RoomShape?;

    function initialize(options as Dictionary?) {
        _size_x = options[:size_x];
        _size_y = options[:size_y];
        _tile_width = options[:tile_width];
        _tile_height = options[:tile_height];
        _start_pos = options[:start_pos] as Point2D;
        _player_pos = _start_pos;
        _map = options[:map];
        _left = options[:left] as Number;
        _right = options[:right] as Number;
        _top = options[:top] as Number;
        _bottom = options[:bottom] as Number;
        _shape = options[:shape] as RoomShape?;

        System.println("Map size: " + _map.getXSize() + " " + _map.getYSize());
        System.println("Room size: " + _size_x + " " + _size_y);
       
        _items = options[:items];
        _enemies = options[:enemies];
        _npcs = {};
        
        initializeMap();

    }

    function initializeMap() as Void {
        // Add items to map
        var item_keys = _items.keys() as Array<Point2D>;
        for (var i = 0; i < item_keys.size(); i++) {
            var item = _items[item_keys[i]];
            _map.setContent(item_keys[i], item);
        }

        // Add enemies to map
        var enemy_keys = _enemies.keys() as Array<Point2D>;
        for (var i = 0; i < _enemies.size(); i++) {
            var enemy = _enemies[enemy_keys[i]];
            _map.setContent(enemy_keys[i], enemy);
        }
    }

    function getMapChar(tile as Tile?) as Number {
        switch (tile.type) {
            case WALL:
                return 33;
            case PASSABLE:
                return 32;
            case STAIRS:
                return 34;
            default:
                return 36;
        }
    }


    function getMap() as Map {
        return _map;
    }

    function getMapData() as Dictionary {
        return {
            :size_x => _size_x,
            :size_y => _size_y,
            :tile_width => _tile_width,
            :tile_height => _tile_height,
            :start_pos => _start_pos,
            :player_pos => _player_pos,
            :map => _map
        };
    }

    function getSize() as Point2D {
        return [_size_x, _size_y];
    }

    function getLeft() as Number { return _left; }
    function getRight() as Number { return _right; }
    function getTop() as Number { return _top; }
    function getBottom() as Number { return _bottom; }
    function getShape() as RoomShape? { return _shape; }

    function removeItem(item as Item) as Void {
        var item_pos = item.getPos();
        _map.setContent(item_pos, null);
        _items.remove(item_pos);
    }

    function dropLoot(enemy as Enemy) as Void {
        var loot = enemy.getLoot() as Item?;
        if (loot == null) {
            return;
        }
        var new_pos = enemy.getPos();
        loot.setPos(new_pos);
        addItem(loot);
    }

    function removeEnemy(enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        _map.setContent(enemy_pos, null);
        _enemies.remove(enemy_pos);
    }

    function getEnemies() as Dictionary<Point2D, Enemy> {
        return _enemies;
    }

    function getItems() as Dictionary<Point2D, Item> {
        return _items;
    }

    function getNPCs() as Dictionary<Point2D, NPC> {
        return _npcs;
    }

    function moveEnemy(enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        var enemy_next_pos = enemy.getNextPos();
        if (enemy_pos != enemy_next_pos) {
            _map.setContent(enemy_pos, null);
            _map.setContent(enemy_next_pos, enemy);
            _enemies.remove(enemy_pos);
            _enemies.put(enemy_next_pos, enemy);
            enemy.setPos(enemy_next_pos);
            enemy.setHasMoved(true);
        } else {
            enemy.setHasMoved(false);
        }
    }

    function getNextEnemyMoves() as Dictionary<Point2D, Enemy> {
        var next_moves = {} as Dictionary<Point2D, Enemy>;
        var enemies = _enemies.values() as Array<Enemy>;
        for (var i = 0; i < enemies.size(); i++) {
            var enemy = enemies[i];
            enemy.findNextMove(_map);
            next_moves.put(enemy.getNextPos(), enemy);
        }
        return next_moves;
    }


    function moveEnemies(player_pos as Point2D) as Void {
        var enemies_values = _enemies.values() as Array<Enemy>;
        for (var i = 0; i < enemies_values.size(); i++) {
            var enemy = enemies_values[i];
            enemy.findNextMove(_map);
            moveEnemy(enemy);
        }
    }

    function enemiesAttack(player_pos as Point2D) as Void {
        var enemy_keys = _enemies.keys() as Array<Point2D>;
        for (var i = 0; i < enemy_keys.size(); i++) {
            var enemy = _enemies[enemy_keys[i]];
            if (enemy != null && !enemy.getHasMoved()) {
                _enemies[enemy_keys[i]].attackNearbyPlayer(_map, player_pos);
            }
        }
    }

    function onTurnDone() as Void {
        var enemy_keys = _enemies.keys() as Array<Point2D>;
        for (var i = 0; i < enemy_keys.size(); i++) {
            var enemy = _enemies[enemy_keys[i]];
            enemy.onTurnDone();
        }
    }

    function setStartPos(pos as Point2D) as Void {
        _start_pos = pos;
    }

    function updatePlayerPos(new_pos as Point2D) as Void {
        _map.setPlayer(_player_pos, false);
        _map.setPlayer(new_pos, true);
        _player_pos = new_pos;
    }

    function getPlayerPos() as Point2D {
        return _player_pos;
    }

    function addItem(item as Item) as Void {
        var item_pos = item.getPos();
        _items.put(item_pos, item);
        _map.setContent(item_pos, item);
    }

    function addEnemy(enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        _enemies.put(enemy_pos, enemy);
        _map.setContent(enemy_pos, enemy);
    }

    function addNPC(npc as NPC) as Void {
        var npc_pos = npc.getPos();
        _npcs.put(npc_pos, npc);
        _map.setContent(npc_pos, npc);
    }

    function findNearestPointFromEdge(direction as WalkDirection, pos as Point2D, screen_size_x as Number, screen_size_y as Number) as Point2D? {
        var x = pos[0];
        var y = pos[1];
        var dx = 0, dy = 0;
        if (direction == UP) {
            dy = 1;
        } else if (direction == DOWN) {
            dy = -1;
        } else if (direction == LEFT) {
            dx = 1;
        } else if (direction == RIGHT) {
            dx = -1;
        }
        while (x >= 0 && x < screen_size_x && y >= 0 && y < screen_size_y) {
            if (_map.getTile(x, y).type == WALL) {
                return [x, y];
            }
            x += dx;
            y += dy;
        }
        return null;
    }

    function addConnection(direction as WalkDirection) as Void {
        var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
        var screen_size_x = Math.ceil(Constants.SCREEN_WIDTH/tile_width).toNumber();
		var screen_size_y = Math.ceil(Constants.SCREEN_HEIGHT/tile_height).toNumber();

        // Use room center as target for the tunnel
        var room_center_x = (_left + _right) / 2;
        var room_center_y = (_top + _bottom) / 2;

        // Edge position (at screen border), aligned to room center
        var edge_pos = [0, 0] as Point2D;
        if (direction == UP) { edge_pos = [room_center_x, 0]; }
        else if (direction == DOWN) { edge_pos = [room_center_x, screen_size_y - 1]; }
        else if (direction == LEFT) { edge_pos = [0, room_center_y]; }
        else if (direction == RIGHT) { edge_pos = [screen_size_x - 1, room_center_y]; }

        Map.digConnectionTunnel(_map, edge_pos, direction, screen_size_x, screen_size_y, [room_center_x, room_center_y]);
    }

    function createStairs(room_pos as Point2D) as Void {
        addStairs(null, false);
        $.Game.setRoomWithFlag(room_pos, HAS_STAIRS, _stairs);
    }

    function addStairs(pos as Point2D?, reload as Boolean?) as Void {
        if (pos == null) {
            var map_data = getMapData();
            var coords = MapUtil.getCoordOfRoom(map_data[:size_x], map_data[:size_y]);
            pos = MapUtil.getOpenPos(_map, coords[0], coords[1], coords[2], coords[3]);
        }
        System.println("Stairs pos: " + pos);
        _map.setType(pos, STAIRS);
        _stairs = pos;
        Map.addWallsAround(_map, pos[0], pos[1]);
        if (reload) {
            _map.mapToString();
        }
    }

    function addMerchant(room_pos as Point2D) as Void {
        var map_data = getMapData();
        var coords = MapUtil.getCoordOfRoom(map_data[:size_x], map_data[:size_y]);
        var pos = MapUtil.getOpenPos(_map, coords[0], coords[1], coords[2], coords[3]);
        var merchant = new Merchant();
        merchant.setPos(pos);
        $.Game.setRoomWithFlag(room_pos, HAS_MERCHANT, pos);
        _map.setContent(pos, merchant);
        addNPC(merchant);
        Map.addWallsAround(_map, pos[0], pos[1]);
    }

    function addQuestGiver(room_pos as Point2D) as Void {
        var map_data = getMapData();
        var coords = MapUtil.getCoordOfRoom(map_data[:size_x], map_data[:size_y]);
        var pos = MapUtil.getOpenPos(_map, coords[0], coords[1], coords[2], coords[3]);
        var npc = new QuestGiver();
        npc.setPos(pos);
        $.Game.setRoomWithFlag(room_pos, HAS_QUEST_GIVER, pos);
        _map.setContent(pos, npc);
        addNPC(npc);
        Map.addWallsAround(_map, pos[0], pos[1]);
    }

    function freeMemory() as Void {
        _items = {};
        _enemies = {};
        _npcs = {};
        _map = null;
    }
    
    function saveEntityDict(dict) as Array<Dictionary> {
        dict = dict as Dictionary<Point2D, Entity>;
        var entities = [];
        var entity_keys = dict.keys() as Array<Point2D>;
        for (var i = 0; i < entity_keys.size(); i++) {
            var entity = dict[entity_keys[i]];
            if (entity != null) {
                entities.add(entity.save());
            }
        }
        return entities;
    }


    function save() as Dictionary {
        var items = saveEntityDict(_items);
        var enemies = saveEntityDict(_enemies);
        var npcs = saveEntityDict(_npcs);

        // TODO: player pos is not correctly saved and loaded
        System.println("Save player pos: " + _player_pos);
        return {
            "size_x" => _size_x,
            "size_y" => _size_y,
            "tile_width" => _tile_width,
            "tile_height" => _tile_height,
            "start_pos" => _start_pos,
            "player_pos" => _player_pos,
            "stairs" => _stairs,
            "map" => _map.save(),
            "items" => items,
            "enemies" => enemies,
            "npcs" => npcs,
            "left" => _left,
            "right" => _right,
            "top" => _top,
            "bottom" => _bottom,
            "shape" => _shape
        };
    }

    static function load(data as Dictionary) as Room {
        var room = new Room({
            :size_x => data["size_x"],
            :size_y => data["size_y"],
            :tile_width => data["tile_width"],
            :tile_height => data["tile_height"],
            :start_pos => data["start_pos"],
            :map => Map.load(data["map"]),
            :items => {},
            :enemies => {},
            :left => data["left"],
            :right => data["right"],
            :top => data["top"],
            :bottom => data["bottom"],
            :shape => data["shape"]
        });
        room.onLoad(data);
        return room;
    }

    function onLoad(data as Dictionary) as Void {
        if (data["player_pos"] != null) {
            System.println("Set Player pos: " + data["player_pos"]);
            updatePlayerPos(data["player_pos"]);
        }
        if (data["stairs"] != null) {
            addStairs(data["stairs"], false);
        }
        _items = {};
        var data_items = data["items"] as Array<Dictionary>;
        for (var i = 0; i < data_items.size(); i++) {
            var item = Item.load(data_items[i] as Dictionary);
            if (item == null) {
                continue;
            }
            addItem(item);
        }
        _enemies = {};
        var data_enemies = data["enemies"] as Array<Dictionary>;
        for (var i = 0; i < data_enemies.size(); i++) {
            var enemy = Enemy.load(data_enemies[i] as Dictionary);
            addEnemy(enemy);
        }
        _npcs = {};
        var data_npcs = data["npcs"] as Array<Dictionary>;
        for (var i = 0; i < data_npcs.size(); i++) {
            var npc = NPC.load(data_npcs[i] as Dictionary);
            addNPC(npc);
        }
    }

}
