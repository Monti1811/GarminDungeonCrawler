import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;

class DCGameView extends WatchUi.View {

    private var _tile_width as Number;
    private var _tile_height as Number;
    private var _room as Room;

	private var _player_sprite as Bitmap;
    private var _player_sprite_offset as Point2D = [0,0];

	private var _timer as Timer.Timer;
    private var bg_layer as Layer;
    private var fg_layer as Layer;

	private var _turns as Turn;

    private var rightLowHint as Bitmap;

    private var damage_texts as Array<Text> = [];

    function initialize(player as Player, room as Room, options as Dictionary?) {
        View.initialize();
		_room = room;
		var map_data = room.getMapData();
        _tile_width = map_data[:tile_width] as Number;
        _tile_height = map_data[:tile_height] as Number;
        _turns = new Turn(self, player, _room, map_data);
        var player_pos = map_data[:player_pos] as Point2D;

		_timer = new Timer.Timer();
        
        if (options != null) {
            // Load options

        }
        rightLowHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightLow, :locX => 290, :locY => 220});

		bg_layer = new Layer({:locX=>0, :locY=>0, :width=>360, :height=>360});
        fg_layer = new Layer({:locX=>0, :locY=>0, :width=>360, :height=>360});
		
		_player_sprite = new WatchUi.Bitmap({
            :rezId=>player.getSprite(), 
            :locX=>player_pos[0] * _tile_width, :locY=>player_pos[1] * _tile_height
        });
        var player_sprite_dimensions = _player_sprite.getDimensions();
        _player_sprite_offset = [
            player_sprite_dimensions[0] - _tile_width, 
            (player_sprite_dimensions[1] - _tile_height) / 2
        ];

    }

    function getTurns() as Turn {
        return _turns;
    }

    function getTimer() as Timer.Timer {
        return _timer;
    }

    function setRoom(room as Room) as Void {
        _room = room;
    }

    function setMapData(map_data as Dictionary) as Void {
        _tile_width = map_data[:tile_width] as Number;
        _tile_height = map_data[:tile_height] as Number;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
		addLayer(bg_layer);
        addLayer(fg_layer);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

		var bg_dc = bg_layer.getDc();
		var fg_dc = fg_layer.getDc();

        _room.draw(dc);
		rightLowHint.draw(dc);

        bg_dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		bg_dc.clear();
        _room.drawItems(bg_dc);
        _room.drawEnemies(bg_dc);
		
		fg_dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		fg_dc.clear();
		
		drawPlayer(fg_dc);

        for (var i = 0; i < damage_texts.size(); i++) {
            damage_texts[i].draw(fg_dc);
        }
    }

    function drawPlayer(dc as Dc) as Void {
        var player_pos = getApp().getPlayer().getPos();
        _player_sprite.locX = player_pos[0] * _tile_width - _player_sprite_offset[0];
		_player_sprite.locY = player_pos[1] * _tile_height - _player_sprite_offset[1];
        _player_sprite.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function removeDamageTexts() as Void {
        damage_texts = [];
        WatchUi.requestUpdate();
    }


    function addDamageText(amount as Number, pos as Point2D) as Void {
        if (amount <= 0) {
            return;
        }
        var damage_text = new WatchUi.Text({
            :text=>"-" + amount, 
            :locX=>pos[0] * _tile_width, 
            :locY=>pos[1] * _tile_height - _tile_height / 2, :size=>20,
            :color=>Graphics.COLOR_RED,
            :font=>Graphics.FONT_XTINY
        });
        damage_texts.add(damage_text);
    }

    function setPlayerSpritePos(pos as Point2D) as Void {
        _player_sprite.locX = pos[0] * _tile_width - _player_sprite_offset[0];
        _player_sprite.locY = pos[1] * _tile_height - _player_sprite_offset[1];
    }

}
