import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;

class DCGameView extends WatchUi.View {

    private var _tile_width as Number;
    private var _tile_height as Number;
    private var _room as Room?;
    private var _room_drawable as RoomDrawable?;

	private var _player_sprite as Bitmap?;
    private var _player_sprite_offset as Point2D = [0,0];

	private var _timer as Timer.Timer?;
    private var _autosave_timer as Timer.Timer?;

	private var _turns as Turn?;

    private var rightLowHint as Bitmap?;

    private var damage_texts as Array<Text> = [];

    function initialize(player as Player, room as Room, options as Dictionary?) {
        View.initialize();
		_room = room;
		var map_data = room.getMapData();
        _tile_width = map_data[:tile_width] as Number;
        _tile_height = map_data[:tile_height] as Number;
        _turns = new Turn(self, player, _room, map_data);
        $.Game.turns = _turns;
        var player_pos = map_data[:player_pos] as Point2D;

        _room_drawable = new RoomDrawable({
            :tile_width=>_tile_width, 
            :tile_height=>_tile_height, 
            :map=>map_data[:map],
            :map_string=>map_data[:map_string]
        });

		_timer = new Timer.Timer();
        var autosave = $.Settings.settings["autosave"] as Number;
        if (autosave != -1) {
            if (autosave == 0) {
                _turns.setAutoSave(true);
            } else {
                _autosave_timer = new Timer.Timer();
                _autosave_timer.start(method(:autoSave), autosave * 60 * 1000, false);
            }  
        }
        
        if (options != null) {
            // Load options

        }
        rightLowHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightLow, :locX => 290, :locY => 220});
		
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

    function autoSave() as Void {
        var app = $.getApp();
        if (app.getPlayer != null && app.getCurrentDungeon() != null) {
            $.SaveData.saveGame();
            var autosave = $.Settings.settings["autosave"] as Number;
            _autosave_timer.start(method(:autoSave), autosave * 60 * 1000, false);
        }
    }

    function getRoomDrawable() as RoomDrawable {
        return _room_drawable;
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
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        if (getApp().getPlayer() == null) {
            return;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        _room_drawable.drawAll(dc, _room);
		rightLowHint.draw(dc);

		drawPlayer(dc);
        addPlayerDamage();
        for (var i = 0; i < damage_texts.size(); i++) {
            damage_texts[i].draw(dc);
        }

        var player = getApp().getPlayer();
        drawHealth(dc, player);
        drawSecondBar(dc, player);
    }

    function drawHealth(dc as Dc, player as Player) as Void {
        // Draw health bar
        dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_BLACK);
        var health_percent = player.getHealthPercent();
        var bar_percent = (70 * health_percent).toNumber();
        dc.setPenWidth(5);
        dc.drawArc(180, 180, 175, Graphics.ARC_CLOCKWISE, 170, 170 - bar_percent);
        // Draw health bar outline
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        dc.drawArc(180, 180, 178, Graphics.ARC_CLOCKWISE, 170, 100);
        dc.drawArc(180, 180, 172, Graphics.ARC_CLOCKWISE, 170, 100);
        dc.drawLine(5, 149, 11, 150);
        dc.drawLine(150, 11, 149, 5);
    }

    private const bar_to_fn as Dictionary<Symbol, Symbol> = {
        :mana=>:drawManaBar
    };

    function drawSecondBar(dc as Dc, player as Player) as Void {
        if (player.second_bar == null) {
            return;
        }
        var method = new Lang.Method(self, bar_to_fn[player.second_bar]);
        var bar_values = method.invoke(player) as [Numeric, Numeric];
        // Draw second bar
        dc.setColor(bar_values[0], Graphics.COLOR_BLACK);
        dc.setPenWidth(5);
        var val = MathUtil.clamp(10 + bar_values[1], 11, 80);
        dc.drawArc(180, 180, 175, Graphics.ARC_CLOCKWISE, val, 10);
        // Draw health bar outline
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        dc.drawArc(180, 180, 178, Graphics.ARC_CLOCKWISE, 80, 10);
        dc.drawArc(180, 180, 172, Graphics.ARC_CLOCKWISE, 80, 10);
        dc.drawLine(355, 149, 349, 150);
        dc.drawLine(210, 11, 211, 5);
    }

    function drawManaBar(player as Player) as [Numeric, Numeric] {
        player = player as Mage;
        var mana_percent = player.getManaPercent();
        var bar_percent = (70 * mana_percent);
        return [Graphics.COLOR_DK_BLUE as Number, bar_percent];
        
    }
    function addPlayerDamage() as Void {
        var player = getApp().getPlayer();
        var player_pos = player.getPos();
        var damage_received = player.damage_received;
        player.damage_received = 0;
        if (damage_received == 0) {
            return;
        }
        addDamageText(damage_received, player_pos);
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

    function freeMemory() as Void {
        _player_sprite = null;
        _room_drawable.freeMemory();
        _room_drawable = null;
        _turns = null;
        _timer = null;
        _autosave_timer = null;
        rightLowHint = null;
        damage_texts = [];
    }

}
