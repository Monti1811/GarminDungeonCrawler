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

class Room extends WatchUi.Drawable {

    private var _size_x as Number;
    private var _size_y as Number;
    private var _tile_width as Number;
    private var _tile_height as Number;

    private var _map as Array<Array<Object?>>;
    private var _map_drawing as Dictionary<Symbol, Array<Point2D>>;

    private var _start_pos as Point2D?;

    private var _items as Array<Item?>;
    private var _items_sprite as Array<Bitmap?>;
    private var _enemies as Array<Enemy?>;
    private var _enemies_sprite as Array<Bitmap?>;

    private var _player_pos as Point2D;

    function initialize(options as Dictionary?) {
        Drawable.initialize(options);
        _size_x = options[:size_x];
        _size_y = options[:size_y];
        _tile_width = options[:tile_width];
        _tile_height = options[:tile_height];
        _start_pos = options[:start_pos] as Point2D;
        _player_pos = _start_pos;

        if (options.get(:map) != null) {
            _map = options[:map];
        } else {
             _map = new Array<Array<Object?>>[_size_x];
            for (var i = 0; i < _size_x; i++) {
                _map[i] = new Array<Object?>[_size_y];
            }
        }
       
        _map_drawing = options[:map_drawing] as Dictionary;
        _items = options[:items];
        _items_sprite = new Array<Bitmap?>[_items.size()];
        _enemies = options[:enemies];
        _enemies_sprite = new Array<Bitmap?>[_enemies.size()];
        
        initializeMap();

    }

    function initializeMap() as Void {
        // Add walls to map
        var a_wall = new Wall();
        var walls = _map_drawing[:walls] as Dictionary<Symbol, Array<Point2D>>;
        var wall_keys = walls.keys() as Array<Symbol>;
        for (var i = 0; i < wall_keys.size(); i++) {
            var spec_wall_values = walls[wall_keys[i]] as Array<Point2D>?;
            for (var j = 0; j < spec_wall_values.size(); j++) {
                var wall_pos = spec_wall_values[j];
                _map[wall_pos[0]][wall_pos[1]] = a_wall;
            }
        }
            
        // Add items to map
        for (var i = 0; i < _items.size(); i++) {
            var item = _items[i];
            var item_pos = item.getPos();
            _items_sprite[i] = new WatchUi.Bitmap({:rezId=>item.getSprite(), :locX=>item_pos[0] * _tile_width, :locY=>item_pos[1] * _tile_height});
            _map[item_pos[0]][item_pos[1]] = item;
        }

        // Add enemies to map
        for (var i = 0; i < _enemies.size(); i++) {
            var enemy = _enemies[i];
            var enemy_pos = enemy.getPos();
            _enemies_sprite[i] = new WatchUi.Bitmap({:rezId=>enemy.getSprite(), :locX=>enemy_pos[0] * _tile_width, :locY=>enemy_pos[1] * _tile_height});
            _map[enemy_pos[0]][enemy_pos[1]] = enemy;
        }
    }

    function draw(dc as Dc) as Void {
        drawMap(dc);
    }

    function drawMap(dc as Dc) as Void {
        var map_keys = _map_drawing.keys() as Array<Symbol>;
        for (var i = 0; i < map_keys.size(); i++) {
            var key = map_keys[i];
            if (key == :walls) {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                var walls = _map_drawing[key] as Dictionary<Symbol, Array<Point2D>>?;
                var wall_keys = walls.keys() as Array<Symbol>;
                for (var j = 0; j < wall_keys.size(); j++) {
                    var wall_key = wall_keys[j] as Symbol;
                    var func = new Method(self, wall_key) as Method;
                    var points = walls[wall_key] as Array<Point2D>;
                    for (var k = 0; k < points.size(); k++) {
                        var options = {
                            :dc => dc,
                            :x => points[k][0],
                            :y => points[k][1]
                        };
                        func.invoke(options);
                    }
                }
            } else {
                var points = _map_drawing[key] as Array<Point2D>;
                var func = new Method(self, key) as Method;
                for (var j = 0; j < points.size(); j++) {
                    var options = {
                        :dc => dc,
                        :x => points[j][0],
                        :y => points[j][1]
                    };
                    func.invoke(options);
                }
            }
            
            
        }
    }

    public function drawPassable(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(x * _tile_width, y * _tile_height, _tile_width, _tile_height);
    }

    public function drawTopWall(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.fillRectangle(x * _tile_width, y * _tile_height, _tile_width, _tile_height / 2);
    }

    public function drawBottomWall(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.fillRectangle(x * _tile_width, y * _tile_height + _tile_height / 2, _tile_width, _tile_height / 2);
    }

    public function drawLeftWall(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.fillRectangle(x * _tile_width, y * _tile_height, _tile_width / 2, _tile_height);
    }

    public function drawRightWall(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.fillRectangle(x * _tile_width + _tile_width / 2, y * _tile_height, _tile_width / 2, _tile_height);
    }

    public function drawTopLeftWall(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.fillRectangle(x * _tile_width, y * _tile_height, _tile_width / 2, _tile_height / 2);
    }

    public function drawTopRightWall(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.fillRectangle(x * _tile_width + _tile_width / 2, y * _tile_height, _tile_width / 2, _tile_height / 2);
    }

    public function drawBottomLeftWall(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.fillRectangle(x * _tile_width, y * _tile_height + _tile_height / 2, _tile_width / 2, _tile_height / 2);
    }

    public function drawBottomRightWall(options as Dictionary) as Void {
        var dc = options[:dc] as Dc;
        var x = options[:x] as Number;
        var y = options[:y] as Number;
        dc.fillRectangle(x * _tile_width + _tile_width / 2, y * _tile_height + _tile_height / 2, _tile_width / 2, _tile_height / 2);
    }

    function drawItems(dc as Dc) as Void {
        for (var i = 0; i < _items.size(); i++) {
            if (_items_sprite[i] != null) {
                _items_sprite[i].draw(dc);
            } 
        }
    }

    function drawEnemies(dc as Dc) as Void {
        for (var i = 0; i < _enemies.size(); i++) {
            if (_enemies_sprite[i] != null) {
                _enemies_sprite[i].draw(dc);
            }
        }
    }

    function getMapData() as Dictionary {
        return {
            :size_x => _size_x,
            :size_y => _size_y,
            :tile_width => _tile_width,
            :tile_height => _tile_height,
            :start_pos => _start_pos,
            :map => _map
        };
    }

    function removeItem(item as Item) as Void {
        var item_pos = item.getPos();
        _map[item_pos[0]][item_pos[1]] = null;
        for (var i = 0; i < _items.size(); i++) {
            if (_items[i] == item) {
                _items[i] = null;
                _items_sprite[i] = null;
                break;
            }
        }

    }

    function dropLoot(enemy as Enemy) as Void {
        var loot = enemy.getLoot() as Item?;
        if (loot == null) {
            return;
        }
        loot.setPos(enemy.getPos());
        _items.add(loot);
        var loot_pos = loot.getPos();
        _items_sprite.add(new WatchUi.Bitmap({:rezId=>loot.getSprite(), :locX=>loot_pos[0] * _tile_width, :locY=>loot_pos[1] * _tile_height}));
        _map[loot_pos[0]][loot_pos[1]] = loot;
    }

    function removeEnemy(enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        _map[enemy_pos[0]][enemy_pos[1]] = null;
        for (var i = 0; i < _enemies.size(); i++) {
            if (_enemies[i] == enemy) {
                _enemies[i] = null;
                _enemies_sprite[i] = null;
                break;
            }
        }
    }

    function moveEnemy(enemy as Enemy, index as Number) as Void {
        var enemy_pos = enemy.getPos();
        var enemy_next_pos = enemy.getNextPos();
        if (enemy_pos != enemy_next_pos) {
            _map[enemy_pos[0]][enemy_pos[1]] = null;
            _map[enemy_next_pos[0]][enemy_next_pos[1]] = enemy;
            _enemies_sprite[index].locX = enemy_next_pos[0] * _tile_width;
            _enemies_sprite[index].locY = enemy_next_pos[1] * _tile_height;
            enemy.setPos(enemy_next_pos);
            enemy.setHasMoved(true);
        } else {
            enemy.setHasMoved(false);
        }
    }


    function moveEnemies(player_pos as Point2D) as Void {
        for (var i = 0; i < _enemies.size(); i++) {
            if (_enemies[i] != null) {
                var enemy = _enemies[i];
                enemy.findNextMove(_map);
                moveEnemy(enemy, i);
            }
        }
    }

    function enemiesAttack(view as DCGameView, player_pos as Point2D) as Void {
        for (var i = 0; i < _enemies.size(); i++) {
            var enemy = _enemies[i];
            if (enemy != null && !enemy.getHasMoved()) {
                _enemies[i].attackNearbyPlayer(view, _map, player_pos);
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
        if (new_pos[1] >= 0 && _map[new_pos[0]][new_pos[1]] == null) {
            return new_pos;
        }
        new_pos = [pos[0], pos[1] + 1];
        if (new_pos[1] < _size_y && _map[new_pos[0]][new_pos[1]] == null) {
            return new_pos;
        }
        new_pos = [pos[0] - 1, pos[1]];
        if (new_pos[0] >= 0 && _map[new_pos[0]][new_pos[1]] == null) {
            return new_pos;
        }
        new_pos = [pos[0] + 1, pos[1]];
        if (new_pos[0] < _size_x && _map[new_pos[0]][new_pos[1]] == null) {
            return new_pos;
        }
        return null;
    }

    function addItem(item as Item) as Void {
        var item_pos = item.getPos();
        _items.add(item);
        _items_sprite.add(new WatchUi.Bitmap({:rezId=>item.getSprite(), :locX=>item_pos[0] * _tile_width, :locY=>item_pos[1] * _tile_height}));
        _map[item_pos[0]][item_pos[1]] = item;
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
            if (_map[x][y] != null) {
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
        var passable = _map_drawing[:drawPassable] as Array<Point2D>;
        var wall = new Wall();

        addTunnelTile(x, y, direction, left_right, wall, passable, screen_size_x, screen_size_y);
        do {
            x += dx;
            y += dy;
            addTunnelTile(x, y, direction, left_right, wall, passable, screen_size_x, screen_size_y);
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

    function addTunnelTile(x as Number, y as Number, direction as WalkDirection, left_right as Boolean, wall as Wall, passable as Array<Point2D>, screen_size_x as Number, screen_size_y as Number) as Void {
        var walls = _map_drawing[:walls] as Dictionary;
        if (_map[x][y] != null) {
            _map[x][y] = null;
            var pos = [x, y];
            if (direction == UP) {
                removeFromArray(walls[:drawBottomWall], pos);
            } else if (direction == DOWN) {
                removeFromArray(walls[:drawTopWall], pos);
            } else if (direction == LEFT) {
                removeFromArray(walls[:drawRightWall], pos);
            } else if (direction == RIGHT) {
                removeFromArray(walls[:drawLeftWall], pos);
            }
        }
        
        passable.add([x, y]);

        if (left_right) {
            if (x > 0) { 
                _map[x - 1][y] = wall;
                walls[:drawRightWall].add([x - 1, y]);
            }
            if (x < screen_size_x - 1) {
                _map[x + 1][y] = wall;
                walls[:drawLeftWall].add([x + 1, y]);
            }
        } else {
            if (y > 0) {
                _map[x][y - 1] = wall;
                walls[:drawBottomWall].add([x, y - 1]);
            }
            if (y < screen_size_y - 1) {
                _map[x][y + 1] = wall; 
                walls[:drawTopWall].add([x, y + 1]);
            }
        }
    }



}
