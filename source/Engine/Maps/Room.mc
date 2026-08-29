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

    function initialize(options as Dictionary?) {
        _size_x = options[:size_x];
        _size_y = options[:size_y];
        _tile_width = options[:tile_width];
        _tile_height = options[:tile_height];
        _start_pos = options[:start_pos] as Point2D;
        _player_pos = _start_pos;
        _map = options[:map];

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
            if (_map.getType([x, y]) == WALL) {
                return [x, y];
            }
            x += dx;
            y += dy;
        }
        return null;
    }

    function addConnection(direction as WalkDirection) as Void {
        // TODO: check if size_y is correct for up/down or not because of the way the map is drawn
        var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
        var index = Constants.ROOM_CENTER_INDEX;
        var screen_size_x = Math.ceil(Constants.SCREEN_WIDTH/tile_width).toNumber();
		var screen_size_y = Math.ceil(Constants.SCREEN_HEIGHT/tile_height).toNumber();
        var index_edge = [0, 0];
        if (direction == UP) {
            index_edge = [index, 0];
        } else if (direction == DOWN) {
            index_edge = [index, screen_size_y - 1];
        } else if (direction == LEFT) {
            index_edge = [0, index];
        } else if (direction == RIGHT) {
            index_edge = [screen_size_x - 1, index];
        }
        var pos_room_edge = findNearestPointFromEdge(direction, index_edge as Point2D, screen_size_x, screen_size_y);
        
        // Choose random tunnel shape
        var tunnel_shape = chooseRandomTunnelShape();
        createTunnelWithShape(direction, pos_room_edge, index_edge as Point2D, screen_size_x, screen_size_y, tunnel_shape);
    }

    function chooseRandomTunnelShape() as TunnelShape {
        var chances = {
            TUNNEL_STRAIGHT => 50,   // 50% straight (most common)
            TUNNEL_L_SHAPED => 35,   // 35% L-shaped
            TUNNEL_ZIGZAG => 15      // 15% zigzag (rare)
        };
        return $.MathUtil.weighted_random(chances) as TunnelShape;
    }

    function createTunnelWithShape(direction as WalkDirection, start_pos as Point2D, end_pos as Point2D, screen_size_x as Number, screen_size_y as Number, shape as TunnelShape) as Void {
        if (shape == TUNNEL_STRAIGHT) {
            createTunnel(direction, start_pos, end_pos, screen_size_x, screen_size_y);
            return;
        }

        // Calculate the perpendicular axis for bending
        var is_vertical = (direction == UP || direction == DOWN);
        
        if (shape == TUNNEL_L_SHAPED) {
            // L-shaped: Go partially in one direction, then turn 90 degrees
            createTunnelLShaped(direction, start_pos, end_pos, screen_size_x, screen_size_y, is_vertical);
        } else if (shape == TUNNEL_ZIGZAG) {
            // Zigzag: Multiple turns
            createTunnelZigZag(direction, start_pos, end_pos, screen_size_x, screen_size_y, is_vertical);
        }
    }

    function createTunnelLShaped(direction as WalkDirection, start_pos as Point2D, end_pos as Point2D, screen_size_x as Number, screen_size_y as Number, is_vertical as Boolean) as Void {
        var x = start_pos[0];
        var y = start_pos[1];
        
        // Determine bend point (random offset from center)
        var bend_offset = $.MathUtil.random(1, 3);
        
        if (is_vertical) {
            // Vertical tunnel with horizontal bend
            var bend_y = (start_pos[1] + end_pos[1]) / 2;
            var bend_x = start_pos[0] + ($.MathUtil.random(0, 1) == 0 ? -bend_offset : bend_offset);
            bend_x = $.MathUtil.clamp(bend_x, 1, screen_size_x - 2);
            
            // First segment: horizontal to bend point
            var dx = (bend_x > x) ? 1 : -1;
            while (x != bend_x) {
                addTunnelTile(x, y, false, screen_size_x, screen_size_y);
                x += dx;
            }
            addTunnelTile(x, y, false, screen_size_x, screen_size_y);
            
            // Second segment: vertical from bend to end
            var dy = (end_pos[1] > y) ? 1 : -1;
            while (y != end_pos[1]) {
                addTunnelTile(x, y, true, screen_size_x, screen_size_y);
                y += dy;
            }
            addTunnelTile(x, y, true, screen_size_x, screen_size_y);
        } else {
            // Horizontal tunnel with vertical bend
            var bend_x = (start_pos[0] + end_pos[0]) / 2;
            var bend_y = start_pos[1] + ($.MathUtil.random(0, 1) == 0 ? -bend_offset : bend_offset);
            bend_y = $.MathUtil.clamp(bend_y, 1, screen_size_y - 2);
            
            // First segment: vertical to bend point
            var dy = (bend_y > y) ? 1 : -1;
            while (y != bend_y) {
                addTunnelTile(x, y, true, screen_size_x, screen_size_y);
                y += dy;
            }
            addTunnelTile(x, y, true, screen_size_x, screen_size_y);
            
            // Second segment: horizontal from bend to end
            var dx = (end_pos[0] > x) ? 1 : -1;
            while (x != end_pos[0]) {
                addTunnelTile(x, y, false, screen_size_x, screen_size_y);
                x += dx;
            }
            addTunnelTile(x, y, false, screen_size_x, screen_size_y);
        }
    }

    function createTunnelZigZag(direction as WalkDirection, start_pos as Point2D, end_pos as Point2D, screen_size_x as Number, screen_size_y as Number, is_vertical as Boolean) as Void {
        var x = start_pos[0];
        var y = start_pos[1];
        var num_bends = $.MathUtil.random(2, 3);
        
        if (is_vertical) {
            // Vertical tunnel with horizontal zigzags
            var total_dy = end_pos[1] - start_pos[1];
            var segment_length = $.MathUtil.max(1, $.MathUtil.abs(total_dy) / (num_bends + 1));
            
            // First segment: go partway vertically
            var dy = (total_dy > 0) ? 1 : -1;
            for (var i = 0; i < segment_length; i++) {
                if (y == end_pos[1]) { break; }
                addTunnelTile(x, y, true, screen_size_x, screen_size_y);
                y += dy;
            }
            addTunnelTile(x, y, true, screen_size_x, screen_size_y);
            
            // Alternating horizontal and vertical segments
            for (var bend = 0; bend < num_bends; bend++) {
                // Horizontal segment
                var h_offset = $.MathUtil.random(1, 3);
                var h_dir = ($.MathUtil.random(0, 1) == 0) ? -1 : 1;
                var target_x = $.MathUtil.clamp(x + h_dir * h_offset, 1, screen_size_x - 2);
                
                var h_dx = (target_x > x) ? 1 : -1;
                while (x != target_x) {
                    addTunnelTile(x, y, false, screen_size_x, screen_size_y);
                    x += h_dx;
                }
                addTunnelTile(x, y, false, screen_size_x, screen_size_y);
                
                // Vertical segment
                for (var i = 0; i < segment_length; i++) {
                    if (y == end_pos[1]) { break; }
                    addTunnelTile(x, y, true, screen_size_x, screen_size_y);
                    y += dy;
                }
                addTunnelTile(x, y, true, screen_size_x, screen_size_y);
            }
            
            // Final vertical segment to end
            while (y != end_pos[1]) {
                addTunnelTile(x, y, true, screen_size_x, screen_size_y);
                y += dy;
            }
            addTunnelTile(x, y, true, screen_size_x, screen_size_y);
        } else {
            // Horizontal tunnel with vertical zigzags
            var total_dx = end_pos[0] - start_pos[0];
            var segment_length = $.MathUtil.max(1, $.MathUtil.abs(total_dx) / (num_bends + 1));
            
            // First segment: go partway horizontally
            var dx = (total_dx > 0) ? 1 : -1;
            for (var i = 0; i < segment_length; i++) {
                if (x == end_pos[0]) { break; }
                addTunnelTile(x, y, false, screen_size_x, screen_size_y);
                x += dx;
            }
            addTunnelTile(x, y, false, screen_size_x, screen_size_y);
            
            // Alternating vertical and horizontal segments
            for (var bend = 0; bend < num_bends; bend++) {
                // Vertical segment
                var v_offset = $.MathUtil.random(1, 3);
                var v_dir = ($.MathUtil.random(0, 1) == 0) ? -1 : 1;
                var target_y = $.MathUtil.clamp(y + v_dir * v_offset, 1, screen_size_y - 2);
                
                var v_dy = (target_y > y) ? 1 : -1;
                while (y != target_y) {
                    addTunnelTile(x, y, true, screen_size_x, screen_size_y);
                    y += v_dy;
                }
                addTunnelTile(x, y, true, screen_size_x, screen_size_y);
                
                // Horizontal segment
                for (var i = 0; i < segment_length; i++) {
                    if (x == end_pos[0]) { break; }
                    addTunnelTile(x, y, false, screen_size_x, screen_size_y);
                    x += dx;
                }
                addTunnelTile(x, y, false, screen_size_x, screen_size_y);
            }
            
            // Final horizontal segment to end
            while (x != end_pos[0]) {
                addTunnelTile(x, y, false, screen_size_x, screen_size_y);
                x += dx;
            }
            addTunnelTile(x, y, false, screen_size_x, screen_size_y);
        }
    }

    function createTunnel(direction as WalkDirection, start_pos as Point2D, end_pos as Point2D, screen_size_x as Number, screen_size_y as Number) as Void {
        var x = start_pos[0];
        var y = start_pos[1];
        var dx = 0, dy = 0;

        if (direction == UP) {dy = -1;}
        else if (direction == DOWN) {dy = 1;}
        else if (direction == LEFT) {dx = -1;}
        else if (direction == RIGHT) {dx = 1;}

        var left_right = (direction == UP || direction == DOWN);

        addTunnelTile(x, y, left_right, screen_size_x, screen_size_y);
        do {
            x += dx;
            y += dy;
            addTunnelTile(x, y, left_right, screen_size_x, screen_size_y);
        } while (x != end_pos[0] || y != end_pos[1]);
    }

    function removeFromArray(array as Array<Point2D>, pos as Array<Number>) as Boolean {
        for (var i = 0; i < array.size(); i++) {
            if (array[i][0] == pos[0] && array[i][1] == pos[1]) {
                array.remove(array[i]);
                return true;
            }
        }
        return false;
    }

    function addTunnelTile(x as Number, y as Number, left_right as Boolean, screen_size_x as Number, screen_size_y as Number) as Void {
        if (_map.getType([x, y]) != PASSABLE) {
            _map.setType([x, y], PASSABLE);
        }
        

        if (left_right) {
            if (x > 0) { 
                _map.setType([x - 1, y], WALL);
            }
            if (x < screen_size_x - 1) {
                _map.setType([x + 1, y], WALL);
            }
        } else {
            if (y > 0) {
                _map.setType([x, y - 1], WALL);
            }
            if (y < screen_size_y - 1) {
                _map.setType([x, y + 1], WALL);
            }
        }
    }

    function createStairs(room_pos as Point2D) as Void {
        addStairs(null, false);
        $.Game.setRoomWithFlag(room_pos, HAS_STAIRS, _stairs);
    }

    function addStairs(pos as Point2D?, reload as Boolean?) as Void {
        if (pos == null) {
            pos = MapUtil.getRandomPosFromRoom(self);
        }
        System.println("Stairs pos: " + pos);
        _map.setType(pos, STAIRS);
        _stairs = pos;
        if (reload) {
            _map.mapToString();
        }
    }

    function addMerchant(room_pos as Point2D) as Void {
        var pos = MapUtil.getRandomPosFromRoom(self);
        if (pos[0] == Constants.ROOM_CENTER_INDEX || pos[1] == Constants.ROOM_CENTER_INDEX) {
            System.println("WTF????");
        }
        var merchant = new Merchant();
        merchant.setPos(pos);
        $.Game.setRoomWithFlag(room_pos, HAS_MERCHANT, pos);
        _map.setContent(pos, merchant);
        addNPC(merchant);
    }

    function addQuestGiver(room_pos as Point2D) as Void {
        var pos = MapUtil.getRandomPosFromRoom(self);
        var npc = new QuestGiver();
        npc.setPos(pos);
        $.Game.setRoomWithFlag(room_pos, HAS_QUEST_GIVER, pos);
        _map.setContent(pos, npc);
        addNPC(npc);
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
            "npcs" => npcs
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
            :enemies => {}
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
