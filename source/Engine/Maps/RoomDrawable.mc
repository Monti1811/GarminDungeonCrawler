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

class RoomDrawable extends WatchUi.Drawable {

    private var _size_x as Number;
    private var _size_y as Number;
    private var _tile_width as Number;
    private var _tile_height as Number;

    private var _map as Array<Array<Object?>>;
    private var _map_drawing as Dictionary<Symbol, Array<Point2D>>;
    private var _stairs as Point2D?;
    private var _stairs_sprite as BitmapReference?;

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
       
        _map_drawing = options[:map_drawing] as Dictionary;
        _items = options[:items];
        _items_sprite = new Array<Bitmap?>[_items.size()];
        _enemies = options[:enemies];
        _enemies_sprite = new Array<Bitmap?>[_enemies.size()];

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
        if (_stairs != null) {
            // Draw the stairs
            System.println("Stairs at: " + _stairs);
            dc.drawBitmap(_stairs[0] * _tile_width, _stairs[1] * _tile_height, _stairs_sprite);
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
            var enemy_sprite = _enemies_sprite[index];
            var enemy_sprite_dimensions = enemy_sprite.getDimensions();
            var enemy_sprite_offset = [enemy_sprite_dimensions[0] - _tile_width, (enemy_sprite_dimensions[1] - _tile_height) / 2];
            enemy_sprite.locX = enemy_next_pos[0] * _tile_width - enemy_sprite_offset[0];
            enemy_sprite.locY = enemy_next_pos[1] * _tile_height - enemy_sprite_offset[1];
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


    function addItem(item as Item) as Void {
        var item_pos = item.getPos();
        _items.add(item);
        _items_sprite.add(new WatchUi.Bitmap({:rezId=>item.getSprite(), :locX=>item_pos[0] * _tile_width, :locY=>item_pos[1] * _tile_height}));
        _map[item_pos[0]][item_pos[1]] = item;
    }

    function addEnemy(enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        _enemies.add(enemy);
        _enemies_sprite.add(new WatchUi.Bitmap({:rezId=>enemy.getSprite(), :locX=>enemy_pos[0] * _tile_width, :locY=>enemy_pos[1] * _tile_height}));
        _map[enemy_pos[0]][enemy_pos[1]] = enemy;
    }


}
