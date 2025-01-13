import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;


class RoomDrawable extends WatchUi.Drawable {

    private var _tile_width as Number;
    private var _tile_height as Number;

    private var _map_buffer as BufferedBitmapReference;
    private var _map_buffer_initialized as Boolean = false;
    private var _map_drawing as Dictionary<Symbol, Array<Point2D>>;
    private var _stairs as Point2D?;
    private var _stairs_sprite as BitmapReference?;


    function initialize(options as Dictionary?) {
        Drawable.initialize(options);
        _tile_width = options[:tile_width];
        _tile_height = options[:tile_height];
       
        _map_drawing = options[:map_drawing] as Dictionary;

        var buffer_options = {
			:width => 368,
			:height => 368,
		};
        _map_buffer = Graphics.createBufferedBitmap(buffer_options);

    }

    function drawItem(dc as Dc, item as Item) as Void {
        var item_pos = item.getPos();
        var item_sprite_ref = item.getSpriteRef();
        var item_sprite_offset  = item.getSpriteOffset();
        dc.drawBitmap(
                item_pos[0] * _tile_width - item_sprite_offset[0], 
                item_pos[1] * _tile_height - item_sprite_offset[1], 
                item_sprite_ref
        );
    }

    function drawItems(dc as Dc, items as Dictionary<Point2D, Item>) as Void {
        var item_values = items.values() as Array<Item>;
        for (var i = 0; i < item_values.size(); i++) {
            var item = item_values[i];
            drawItem(dc, item);
        }
    }

    function drawEnemy(dc as Dc, enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        var enemy_sprite_ref = enemy.getSpriteRef();
        var enemy_sprite_offset = enemy.getSpriteOffset();
        dc.drawBitmap(
                enemy_pos[0] * _tile_width - enemy_sprite_offset[0], 
                enemy_pos[1] * _tile_height - enemy_sprite_offset[1], 
                enemy_sprite_ref
        );
    }

    function drawEnemies(dc as Dc, enemies as Dictionary<Point2D, Enemy>) as Void {
        var enemy_values = enemies.values() as Array<Enemy>;
        for (var i = 0; i < enemy_values.size(); i++) {
            var enemy = enemy_values[i];
            drawEnemy(dc, enemy);
        }
    }

    function draw(dc as Dc) as Void {
        var map_buffer = _map_buffer.get();
        if (!_map_buffer_initialized) {
            _map_buffer_initialized = true;
            var map_dc = map_buffer.getDc();
            drawMap(map_dc);
        }
        dc.drawBitmap(0, 0, map_buffer);
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
            if (_stairs_sprite != null) {
                _stairs_sprite = WatchUi.loadResource($.Rez.Drawables.Stairs);
            }
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

}
