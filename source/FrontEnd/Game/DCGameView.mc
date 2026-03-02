import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;

class DCGameView extends WatchUi.View {

    private var _tile_width as Number;
    private var _tile_height as Number;
    private var _room_drawable as RoomDrawable?;

	private var _player_sprite as Bitmap?;
    private var _player_sprite_offset as Point2D = [0,0];

	private var _timer as Timer.Timer?;
    private var _autosave_timer as Timer.Timer?;

    private var damage_texts as Array<Text> = [];

    private var rightTopHint as Bitmap?;

    function initialize(player as Player, room as Room, options as Dictionary?) {
        View.initialize();
        var map_data = room.getMapData();
        _tile_width = map_data[:tile_width] as Number;
        _tile_height = map_data[:tile_height] as Number;
        var turns = new Turn(self, player, room, map_data);
        $.StepGate.resetForSession();
        $.Game.setTurns(turns);
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
				turns.setAutoSave(true);
            } else {
                _autosave_timer = new Timer.Timer();
                _autosave_timer.start(method(:autoSave), autosave * 60 * 1000, false);
            }  
        }
        
        if (options != null) {
            // Load options

        }
		
		_player_sprite = new WatchUi.Bitmap({
            :rezId=>player.getSprite(), 
            :locX=>player_pos[0] * _tile_width, :locY=>player_pos[1] * _tile_height
        });
        var player_sprite_dimensions = _player_sprite.getDimensions();
        _player_sprite_offset = [
            player_sprite_dimensions[0] - _tile_width, 
            (player_sprite_dimensions[1] - _tile_height) / 2
        ];

        setHint();

    }

    (:venu2)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 345, :locY => 67});
    }

    (:venu2plus)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 345, :locY => 67});
    }

    (:venu2s)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 300, :locY => 59});
    }

    (:venu3)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 360, :locY => 54});
    }

    (:venu3s)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 318, :locY => 59});
    }

    (:venu441mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 319, :locY => 72});
    }

    (:venu445mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 360, :locY => 54});
    }

    function onLayout(dc as Dc) as Void {
        //setLayout($.Rez.Layouts.DCGameView(dc));
    }

    function autoSave() as Void {
        if ($.Game.getPlayer() != null && $.Game.getDungeon() != null) {
            $.SaveData.saveGame();
            var autosave = $.Settings.settings["autosave"] as Number;
            _autosave_timer.start(method(:autoSave), autosave * 60 * 1000, false);
        }
    }

    function getRoomDrawable() as RoomDrawable {
        return _room_drawable;
    }

    function getTurns() as Turn {
        return $.Game.getTurns();
    }

    function getTimer() as Timer.Timer {
        return _timer;
    }

    function setRoom(room as Room) as Void {
        // Game module owns the active room; no local storage needed.
    }

    function setMapData(map_data as Dictionary) as Void {
        _tile_width = map_data[:tile_width] as Number;
        _tile_height = map_data[:tile_height] as Number;
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

        
		// Draw layout hint
		View.onUpdate(dc);

        _room_drawable.drawAll(dc, $.Game.getCurrentRoom());
        rightTopHint.draw(dc);


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
        var center_x = (Constants.SCREEN_WIDTH / 2).toNumber();
        var center_y = (Constants.SCREEN_HEIGHT / 2).toNumber();
        var min_size = $.MathUtil.min(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT);
        var bar_radius = (min_size * 175 / 360).toNumber();
        var outer_outline_radius = (min_size * 178 / 360).toNumber();
        var inner_outline_radius = (min_size * 172 / 360).toNumber();
        var line_x1 = (Constants.SCREEN_WIDTH * 5 / 360).toNumber();
        var line_y1 = (Constants.SCREEN_HEIGHT * 149 / 360).toNumber();
        var line_x2 = (Constants.SCREEN_WIDTH * 11 / 360).toNumber();
        var line_y2 = (Constants.SCREEN_HEIGHT * 150 / 360).toNumber();
        var line2_x1 = (Constants.SCREEN_WIDTH * 150 / 360).toNumber();
        var line2_y1 = (Constants.SCREEN_HEIGHT * 11 / 360).toNumber();
        var line2_x2 = (Constants.SCREEN_WIDTH * 149 / 360).toNumber();
        var line2_y2 = (Constants.SCREEN_HEIGHT * 5 / 360).toNumber();

        // Draw health bar
        dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_BLACK);
        var health_percent = player.getHealthPercent();
        var bar_percent = (70 * health_percent).toNumber();
        dc.setPenWidth(5);
        dc.drawArc(center_x, center_y, bar_radius, Graphics.ARC_CLOCKWISE, 170, $.MathUtil.min(170, 170 - bar_percent));
        // Draw health bar outline
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        dc.drawArc(center_x, center_y, outer_outline_radius, Graphics.ARC_CLOCKWISE, 170, 100);
        dc.drawArc(center_x, center_y, inner_outline_radius, Graphics.ARC_CLOCKWISE, 170, 100);
        dc.drawLine(line_x1, line_y1, line_x2, line_y2);
        dc.drawLine(line2_x1, line2_y1, line2_x2, line2_y2);
    }

    private const bar_to_fn as Dictionary<Symbol, Symbol> = {
        :mana=>:drawManaBar
    };

    function drawSecondBar(dc as Dc, player as Player) as Void {
        if (player.second_bar == null) {
            return;
        }
        var center_x = (Constants.SCREEN_WIDTH / 2).toNumber();
        var center_y = (Constants.SCREEN_HEIGHT / 2).toNumber();
        var min_size = $.MathUtil.min(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT);
        var bar_radius = (min_size * 175 / 360).toNumber();
        var outer_outline_radius = (min_size * 178 / 360).toNumber();
        var inner_outline_radius = (min_size * 172 / 360).toNumber();
        var line_x1 = (Constants.SCREEN_WIDTH * 5 / 360).toNumber();
        var line_y1 = (Constants.SCREEN_HEIGHT * 211 / 360).toNumber();
        var line_x2 = (Constants.SCREEN_WIDTH * 11 / 360).toNumber();
        var line_y2 = (Constants.SCREEN_HEIGHT * 210 / 360).toNumber();
        var line2_x1 = (Constants.SCREEN_WIDTH * 150 / 360).toNumber();
        var line2_y1 = (Constants.SCREEN_HEIGHT * 349 / 360).toNumber();
        var line2_x2 = (Constants.SCREEN_WIDTH * 149 / 360).toNumber();
        var line2_y2 = (Constants.SCREEN_HEIGHT * 355 / 360).toNumber();

        var method = new Lang.Method(self, bar_to_fn[player.second_bar]);
        var bar_values = method.invoke(player) as [Numeric, Numeric];
        // Draw second bar
        dc.setColor(bar_values[0], Graphics.COLOR_BLACK);
        dc.setPenWidth(5);
        var val = MathUtil.clamp(190 + bar_values[1], 191, 260);
        dc.drawArc(center_x, center_y, bar_radius, Graphics.ARC_CLOCKWISE, val, 190);
        // Draw health bar outline
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        dc.drawArc(center_x, center_y, outer_outline_radius, Graphics.ARC_CLOCKWISE, 260, 190);
        dc.drawArc(center_x, center_y, inner_outline_radius, Graphics.ARC_CLOCKWISE, 260, 190);
        dc.drawLine(line_x1, line_y1, line_x2, line_y2);
        dc.drawLine(line2_x1, line2_y1, line2_x2, line2_y2);
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
        $.Game.setTurns(null);
        _timer.stop();
        _timer = null;
        if (_autosave_timer != null) {
            _autosave_timer.stop();
            _autosave_timer = null;
        }
        damage_texts = [];
        rightTopHint = null;
    }

}
