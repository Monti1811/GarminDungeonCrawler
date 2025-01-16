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

    private var _map as Array<Array<Tile>>;
    private var _map_string as Array<String>;
    private var _stairs as Point2D?;

    private var _start_pos as Point2D?;

    private var _items as Dictionary<Point2D, Item>;
    private var _enemies as Dictionary<Point2D, Enemy>;

    private var _player_pos as Point2D;

    function initialize(options as Dictionary?) {
        _size_x = options[:size_x];
        _size_y = options[:size_y];
        _tile_width = options[:tile_width];
        _tile_height = options[:tile_height];
        _start_pos = options[:start_pos] as Point2D;
        _player_pos = _start_pos;
        _map = options[:map];
        _map_string = mapToString();

        System.println("Map size: " + _map.size() + " " + _map[0].size());
        System.println("Room size: " + _size_x + " " + _size_y);
       
        _items = options[:items];
        _enemies = options[:enemies];
        
        initializeMap();

    }

    function initializeMap() as Void {
        // Add items to map
        var item_keys = _items.keys() as Array<Point2D>;
        for (var i = 0; i < item_keys.size(); i++) {
            var item = _items[item_keys[i]];
            _map[item_keys[i][0]][item_keys[i][1]].content = item;
        }

        // Add enemies to map
        var enemy_keys = _enemies.keys() as Array<Point2D>;
        for (var i = 0; i < _enemies.size(); i++) {
            var enemy = _enemies[enemy_keys[i]];
            _map[enemy_keys[i][0]][enemy_keys[i][1]].content = enemy;
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

    function mapToString() as Array<String> {
        var map_string = [] as Array<String>;
        for (var i = 0; i < _map.size(); i++) {
            var row = "";
            for (var j = 0; j < _map[i].size(); j++) {
                row += getMapChar(_map[j][i]).toChar();
            }
            map_string.add(row);
        }
        return map_string; 
    }

    function getMapData() as Dictionary {
        return {
            :size_x => _size_x,
            :size_y => _size_y,
            :tile_width => _tile_width,
            :tile_height => _tile_height,
            :start_pos => _start_pos,
            :player_pos => _player_pos,
            :map => _map,
            :map_string => _map_string,
        };
    }

    function removeItem(item as Item) as Void {
        var item_pos = item.getPos();
        _map[item_pos[0]][item_pos[1]].content = null;
        _items.remove(item_pos);
    }

    function dropLoot(enemy as Enemy) as Void {
        var loot = enemy.getLoot() as Item?;
        if (loot == null) {
            return;
        }
        var new_pos = enemy.getPos();
        loot.setPos(new_pos);
        _items.put(new_pos, loot);
        _map[new_pos[0]][new_pos[1]].content = loot;
    }

    function removeEnemy(enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        _map[enemy_pos[0]][enemy_pos[1]].content = null;
        _enemies.remove(enemy_pos);
    }

    function getEnemies() as Dictionary<Point2D, Enemy> {
        return _enemies;
    }

    function getItems() as Dictionary<Point2D, Item> {
        return _items;
    }

    function moveEnemy(enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        var enemy_next_pos = enemy.getNextPos();
        if (enemy_pos != enemy_next_pos) {
            _map[enemy_pos[0]][enemy_pos[1]].content = null;
            _map[enemy_next_pos[0]][enemy_next_pos[1]].content = enemy;
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
        for (var i = 0; i < _enemies.size(); i++) {
            var enemy_pos = _enemies.keys()[i];
            if (_enemies[enemy_pos] != null) {
                var enemy = _enemies[enemy_pos];
                enemy.findNextMove(_map);
                moveEnemy(enemy);
            }
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

    function setStartPos(pos as Point2D) as Void {
        _start_pos = pos;
    }

    function updatePlayerPos(new_pos as Point2D) as Void {
        _player_pos = new_pos;
    }

    function getPlayerPos() as Point2D {
        return _player_pos;
    }

    function getNearbyFreePos(pos as Point2D) as Point2D? {
        var new_pos = [pos[0], pos[1] - 1];
        if (new_pos[1] >= 0 && _map[new_pos[0]][new_pos[1]].content == null) {
            return new_pos;
        }
        new_pos = [pos[0], pos[1] + 1];
        if (new_pos[1] < _size_y && _map[new_pos[0]][new_pos[1]].content == null) {
            return new_pos;
        }
        new_pos = [pos[0] - 1, pos[1]];
        if (new_pos[0] >= 0 && _map[new_pos[0]][new_pos[1]].content == null) {
            return new_pos;
        }
        new_pos = [pos[0] + 1, pos[1]];
        if (new_pos[0] < _size_x && _map[new_pos[0]][new_pos[1]].content == null) {
            return new_pos;
        }
        return null;
    }

    function addItem(item as Item) as Void {
        var item_pos = item.getPos();
        _items.put(item_pos, item);
        _map[item_pos[0]][item_pos[1]].content = item;
    }

    function addEnemy(enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        _enemies.put(enemy_pos, enemy);
        _map[enemy_pos[0]][enemy_pos[1]].content = enemy;
    }

    function addConnection(direction as WalkDirection, room as Room?) as Void {
        // TODO: check if size_y is correct for up/down or not because of the way the map is drawn
        var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
        var index = 11; // Middle of the room, as 180/16 = 11.25
        var screen_size_x = Math.ceil(360.0/tile_width).toNumber();
		var screen_size_y = Math.ceil(360.0/tile_height).toNumber();
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
        createTunnel(direction, pos_room_edge, index_edge as Point2D, screen_size_x, screen_size_y);
        
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
            if (_map[x][y].type == WALL) {
                return [x, y];
            }
            x += dx;
            y += dy;
        }
        return null;
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
        if (_map[x][y].type != PASSABLE) {
            _map[x][y].type = PASSABLE;
        }
        

        if (left_right) {
            if (x > 0) { 
                _map[x - 1][y].type = WALL;
            }
            if (x < screen_size_x - 1) {
                _map[x + 1][y].type = WALL;
            }
        } else {
            if (y > 0) {
                _map[x][y - 1].type = WALL;
            }
            if (y < screen_size_y - 1) {
                _map[x][y + 1].type = WALL; 
            }
        }
    }

    function addStairs(pos as Point2D?, reload as Boolean?) as Void {
        if (pos == null) {
            pos = MapUtil.getRandomPosFromRoom(self);
        }
        System.println("Stairs pos: " + pos);
        if (pos != null) {
            _map[pos[0]][pos[1]].type = STAIRS;
            _stairs = pos;
        }
        if (reload) {
            _map_string = mapToString();
        }
    }


    function save() as Dictionary {
        var items = [];
        var item_keys = _items.keys() as Array<Point2D>;
        for (var i = 0; i < item_keys.size(); i++) {
            var item = _items[item_keys[i]];
            if (item != null) {
                items.add(item.save());
            }
        }
        var enemies = [];
        var enemy_keys = _enemies.keys() as Array<Point2D>;
        for (var i = 0; i < enemy_keys.size(); i++) {
            var enemy = _enemies[enemy_keys[i]];
            if (enemy != null) {
                enemies.add(enemy.save());
            }
        }
        var screensize = MapUtil.getNumTilesForScreensize();
        var map = [];
        for (var i = 0; i < screensize[0]; i++) {
            var row = [];
            for (var j = 0; j < screensize[1]; j++) {
                row.add(_map[i][j].type as Number);
            }
            map.add(row);
        }
        return {
            "size_x" => _size_x,
            "size_y" => _size_y,
            "tile_width" => _tile_width,
            "tile_height" => _tile_height,
            "start_pos" => _start_pos,
            "player_pos" => _player_pos,
            "stairs" => _stairs,
            "map" => map,
            "map_string" => _map_string,
            "items" => items,
            "enemies" => enemies
        };
    }

    static var num_to_enum as Array<TileType> = [
        EMPTY,
        WALL,
        PASSABLE,
        STAIRS
    ];

    static function loadMap(map_data as Array<Array<Number>>) as Array<Array<Tile>> {

        var map = [];
        for (var i = 0; i < map_data.size(); i++) {
            var row = [];
            for (var j = 0; j < map_data[i].size(); j++) {
                var tile = new Tile(i, j);
                tile.type = num_to_enum[map_data[i][j]];
                row.add(tile);
            }
            map.add(row);
        }
        return map;
    }

    static function load(data as Dictionary) as Room {
        var room = new Room({
            :size_x => data["size_x"],
            :size_y => data["size_y"],
            :tile_width => data["tile_width"],
            :tile_height => data["tile_height"],
            :start_pos => data["start_pos"],
            :map => Room.loadMap(data["map"]),
            :map_string => data["map_string"],
            :items => {},
            :enemies => {}
        });
        if (data["player_pos"] != null) {
            System.println("Set Player pos: " + data["player_pos"]);
            room.updatePlayerPos(data["player_pos"]);
        }
        if (data["stairs"] != null) {
            room.addStairs(data["stairs"], false);
        }
        var items_data = data["items"] as Array<Dictionary>?;
        if (items_data != null) {
            for (var i = 0; i < items_data.size(); i++) {
                var item = Item.load(items_data[i]);
                room.addItem(item);
            }
        }
        var enemies_data = data["enemies"] as Array<Dictionary>?;
        if (enemies_data != null) {
            for (var i = 0; i < enemies_data.size(); i++) {
                var enemy = Enemy.load(enemies_data[i]);
                room.addEnemy(enemy);
            }
        }
        return room;
    }

}
