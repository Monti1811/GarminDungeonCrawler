import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;

class DCGameView extends WatchUi.View {

    private var _tile_width as Number;
    private var _tile_height as Number;
    private var _room_drawable as RoomDrawable?;
    private var _background_layer as WatchUi.Layer?;
    private var _foreground_layer as WatchUi.Layer?;
    private var _overlay_layer as WatchUi.Layer?;
    private var _background_dirty as Boolean = true;
    private var _foreground_dirty as Boolean = true;
    private var _overlay_dirty as Boolean = true;
    private var _last_health_percent as Float?;
    private var _last_second_bar as Symbol?;
    private var _last_second_bar_percent as Numeric?;

	private var _player_sprite as Bitmap?;
    private var _player_sprite_offset as Point2D = [0,0];

	private var _timer as Timer.Timer?;
    private var _autosave_timer as Timer.Timer?;

    private var damage_texts as Array<Text> = [];

    private var rightTopHint as Bitmap?;

    function initialize(player as Player, room as Room, options as Dictionary?) {
        View.initialize();
        var map_data = room.getMapData();
        var map_string = room.getMap().getMapString();
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
            :map_string=>map_string
        });

        _background_layer = new WatchUi.Layer({
            :width => Constants.SCREEN_WIDTH,
            :height => Constants.SCREEN_HEIGHT
        });
        _foreground_layer = new WatchUi.Layer({
            :width => Constants.SCREEN_WIDTH,
            :height => Constants.SCREEN_HEIGHT
        });
        _overlay_layer = new WatchUi.Layer({
            :width => Constants.SCREEN_WIDTH,
            :height => Constants.SCREEN_HEIGHT
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

    (:fenix7s)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 207, :locY => 44});
    }

    (:fenix7spro)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 207, :locY => 44});
    }

    (:fenix7)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 225, :locY => 48});
    }

    (:fenix7pro)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 225, :locY => 48});
    }

    (:fenix7pronowifi)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 225, :locY => 48});
    }

    (:fenix8solar47mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 206, :locY => 42});
    }

    (:fenix9prosolar47mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 206, :locY => 42});
    }

    (:fenix7x)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 242, :locY => 52});
    }

    (:fenix7xpro)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 242, :locY => 52});
    }

    (:fenix7xpronowifi)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 242, :locY => 52});
    }

    (:fenix8solar51mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 222, :locY => 44});
    }

    (:fenix9prosolar51mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 225, :locY => 55});
    }

    (:fenix843mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 323, :locY => 71});
    }

    (:fenix943mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 323, :locY => 71});
    }

    (:fenix9pro43mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 323, :locY => 71});
    }

    (:fenixe)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 323, :locY => 71});
    }

    (:fenix847mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 353, :locY => 77});
    }

    (:fenix8pro47mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 353, :locY => 77});
    }

    (:fenix947mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 353, :locY => 77});
    }

    (:fenix9pro47mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 353, :locY => 77});
    }

    (:fenix9pro51mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 353, :locY => 77});
    }

    (:fr955)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 224, :locY => 50});
    }

    (:enduro3)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 222, :locY => 44});
    }

    (:fr265s)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 297, :locY => 69});
    }

    (:approachs50)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 338, :locY => 73});
    }

    (:approachs7042mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 338, :locY => 73});
    }

    (:descentg2)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 337, :locY => 72});
    }

    (:descentmk343mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 337, :locY => 72});
    }

    (:epix2pro42mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 337, :locY => 72});
    }

    (:fr170)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 323, :locY => 73});
    }

    (:fr170m)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 323, :locY => 73});
    }

    (:fr57042mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 323, :locY => 73});
    }

    (:fr70)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 323, :locY => 73});
    }

    (:marq2)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 337, :locY => 72});
    }

    (:marq2aviator)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 337, :locY => 72});
    }

    (:venusq2)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 307, :locY => 70});
    }

    (:venusq2m)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 307, :locY => 70});
    }

    (:venux1)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 389, :locY => 80});
    }

    (:vivoactive5)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 318, :locY => 59});
    }

    (:vivoactive6)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 319, :locY => 72});
    }

    (:d2airx10)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 345, :locY => 67});
    }

    (:d2mach1)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 360, :locY => 77});
    }

    (:epix2)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 360, :locY => 77});
    }

    (:epix2pro47mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 360, :locY => 77});
    }

    (:fr265)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 343, :locY => 81});
    }

    (:approachs7047mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 393, :locY => 85});
    }

    (:d2mach2)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 353, :locY => 77});
    }

    (:d2mach2pro)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 353, :locY => 77});
    }

    (:descentmk351mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 393, :locY => 84});
    }

    (:epix2pro51mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 393, :locY => 84});
    }

    (:fr57047mm)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 379, :locY => 89});
    }

    (:fr965)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 379, :locY => 89});
    }

    (:fr970)
    function setHint() as Void {
        rightTopHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightTop, :locX => 379, :locY => 89});
    }



    function onLayout(dc as Dc) as Void {
        addLayer(_background_layer);
        addLayer(_foreground_layer);
        addLayer(_overlay_layer);
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
        _background_dirty = true;
    }

    function onShow() as Void {
        _background_dirty = true;
        _foreground_dirty = true;
        _overlay_dirty = true;
    }

    function setForegroundDirty() as Void {
        _foreground_dirty = true;
        WatchUi.requestUpdate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var player = getApp().getPlayer();
        if (player == null) {
            return;
        }

        View.onUpdate(dc);

        if (_background_dirty) {
            var bg_dc = _background_layer.getDc();
            _room_drawable.draw(bg_dc);
            _background_dirty = false;
        }

        if (_foreground_dirty) {
            var fg_dc = _foreground_layer.getDc();
            fg_dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            fg_dc.clear();
            _room_drawable.drawForeground(fg_dc, $.Game.getCurrentRoom());
            drawPlayer(fg_dc);
            _foreground_dirty = false;
        }

        if (addPlayerDamage()) {
            _overlay_dirty = true;
        }

        var health_percent = player.getHealthPercent();
        var second_bar = player.second_bar as Symbol?;
        var second_bar_percent = null as Numeric?;
        if (second_bar != null) {
            if (second_bar == :mana) {
                var bar_values = drawManaBar(player);
                second_bar_percent = bar_values[1];
            }
        }

        if (_last_health_percent == null ||
            _last_health_percent != health_percent ||
            _last_second_bar != second_bar ||
            _last_second_bar_percent != second_bar_percent) {
            _overlay_dirty = true;
        }

        if (_overlay_dirty) {
            var ui_dc = _overlay_layer.getDc();
            ui_dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            ui_dc.clear();
            rightTopHint.draw(ui_dc);
            for (var i = 0; i < damage_texts.size(); i++) {
                damage_texts[i].draw(ui_dc);
            }

            drawHealth(ui_dc, player);
            drawSecondBar(ui_dc, player);

            _last_health_percent = health_percent;
            _last_second_bar = second_bar;
            _last_second_bar_percent = second_bar_percent;
            _overlay_dirty = false;
        }

    }

    function drawHealth(dc as Dc, player as Player) as Void {
        var center_x = (Constants.SCREEN_WIDTH / 2).toNumber();
        var center_y = (Constants.SCREEN_HEIGHT / 2).toNumber();
        var min_size = $.MathUtil.min(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT);
        var bar_radius = (min_size * 175 / 360).toNumber();
        var outer_outline_radius = (min_size * 178 / 360).toNumber();
        var inner_outline_radius = (min_size * 172 / 360).toNumber();
        var marker_radius = (min_size * 175 / 360).toNumber();
        var end170 = $.MathUtil.getArcCoordinates(center_x, center_y, marker_radius, 170, 170) as Array<Array<Number>>;
        var end100 = $.MathUtil.getArcCoordinates(center_x, center_y, marker_radius, 100, 100) as Array<Array<Number>>;
        var p170 = end170[0];
        var p100 = end100[0];
        var line_x1 = p170[0] - 3;
        var line_y1 = p170[1] - 1;
        var line_x2 = p170[0] + 3;
        var line_y2 = p170[1] + 1;
        var line2_x1 = p100[0] - 3;
        var line2_y1 = p100[1] - 1;
        var line2_x2 = p100[0] + 3;
        var line2_y2 = p100[1] + 1;

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
        var marker_radius = (min_size * 175 / 360).toNumber();
        var end260 = $.MathUtil.getArcCoordinates(center_x, center_y, marker_radius, 260, 260) as Array<Array<Number>>;
        var end190 = $.MathUtil.getArcCoordinates(center_x, center_y, marker_radius, 190, 190) as Array<Array<Number>>;
        var p260 = end260[0];
        var p190 = end190[0];
        var line_x1 = p260[0] - 3;
        var line_y1 = p260[1] - 1;
        var line_x2 = p260[0] + 3;
        var line_y2 = p260[1] + 1;
        var line2_x1 = p190[0] - 3;
        var line2_y1 = p190[1] - 1;
        var line2_x2 = p190[0] + 3;
        var line2_y2 = p190[1] + 1;

        var bar_values = [0, 0] as [Numeric, Numeric];
        if (player.second_bar == :mana) {
            bar_values = drawManaBar(player);
        }
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
    function addPlayerDamage() as Boolean {
        var player = getApp().getPlayer();
        var player_pos = player.getPos();
        var damage_received = player.damage_received;
        player.damage_received = 0;
        if (damage_received == 0) {
            return false;
        }
        addDamageText(damage_received, player_pos);
        return true;
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
    function onHide() as Void {    }

    function removeDamageTexts() as Void {
        damage_texts = [];
        _overlay_dirty = true;
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
        _overlay_dirty = true;
    }

    function setPlayerSpritePos(pos as Point2D) as Void {
        _player_sprite.locX = pos[0] * _tile_width - _player_sprite_offset[0];
        _player_sprite.locY = pos[1] * _tile_height - _player_sprite_offset[1];
    }

    function freeMemory() as Void {
        clearLayers();
        _background_layer = null;
        _foreground_layer = null;
        _overlay_layer = null;
        _last_health_percent = null;
        _last_second_bar = null;
        _last_second_bar_percent = null;
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
