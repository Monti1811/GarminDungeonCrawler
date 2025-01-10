import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;

class DCGameView extends WatchUi.View {

    public var _map_data as Dictionary?;
    private var _room as Room;

	private var _player as Player;
	private var _player_sprite as Bitmap;
    private var _player_pos as Point2D = [0,0];

	private var _timer as Timer.Timer;
    private var bg_layer as Layer;
    private var fg_layer as Layer;

	private var is_moving as Boolean = false;

    private var rightLowHint as Bitmap;

    private var damage_texts as Array<Text> = [];

    function initialize(player as Player, room as Room, options as Dictionary?) {
        View.initialize();
		_player = player;
		_room = room;
		_map_data = room.getMapData();
        _player_pos = _map_data[:player_pos] as Point2D;
        _player.setPos(_player_pos);

		_timer = new Timer.Timer();
        
        if (options != null) {
            // Load options

        }
        rightLowHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightLow, :locX => 290, :locY => 220});

		bg_layer = new Layer({:locX=>0, :locY=>0, :width=>360, :height=>360});
        fg_layer = new Layer({:locX=>0, :locY=>0, :width=>360, :height=>360});
		
		_player_sprite = new WatchUi.Bitmap({:rezId=>_player.getSprite(), :locX=>_player_pos[0] * _map_data[:tile_width], :locY=>_player_pos[1] * _map_data[:tile_height]});

        // Add player position to map
        var map = _map_data[:map] as Array<Array<Object?>>;
        map[_player_pos[0]][_player_pos[1]] = _player;
    }

    function loadRoom(room as Room) as Void {
        _room = room;
        _map_data = room.getMapData();
        _player_pos = _map_data[:start_pos];
        _player.setPos(_player_pos);
        room.updatePlayerPos(_player_pos);
        _player_sprite.locX = _player_pos[0] * _map_data[:tile_width] as Number;
        _player_sprite.locY = _player_pos[1] * _map_data[:tile_height] as Number;
        var map = _map_data[:map] as Array<Array<Object?>>;
        map[_player_pos[0]][_player_pos[1]] = _player;
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
		_player_sprite.locX = _player_pos[0] * _map_data[:tile_width];
		_player_sprite.locY = _player_pos[1] * _map_data[:tile_height];
		_player_sprite.draw(fg_dc);

        for (var i = 0; i < damage_texts.size(); i++) {
            damage_texts[i].draw(fg_dc);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function getNewPlayerPosInNextRoom(next_pos as Point2D, direction as WalkDirection) as Point2D {
        var new_pos = next_pos;
        var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
        var screen_size_x = Math.ceil(360.0/tile_width).toNumber();
		var screen_size_y = Math.ceil(360.0/tile_height).toNumber();
        switch (direction) {
            case UP:
                new_pos = [next_pos[0], screen_size_y - 1];
                break;
            case DOWN:
                new_pos = [next_pos[0], 0];
                break;
            case LEFT:
                new_pos = [screen_size_x - 1, next_pos[1]];
                break;
            case RIGHT:
                new_pos = [0, next_pos[1]];
                break;
            case STANDING:
                new_pos = next_pos;
                break;
        }
        return new_pos;
    }
        

    function removeDamageTexts() as Void {
        damage_texts = [];
        WatchUi.requestUpdate();
    }

	function doTurn(direction as WalkDirection) as Void {
		if (is_moving) {
            return;
        }
        System.println("Moving " + direction);
        var new_pos = _player_pos;
        switch (direction) {
            case UP:
                new_pos = [_player_pos[0], _player_pos[1] - 1];
                break;
            case DOWN:
                new_pos = [_player_pos[0], _player_pos[1] + 1];
                break;
            case LEFT:
                new_pos = [_player_pos[0] - 1, _player_pos[1]];
                break;
            case RIGHT:
                new_pos = [_player_pos[0] + 1, _player_pos[1]];
                break;
            case STANDING:
                new_pos = _player_pos;
                break;
        }

        var map = _map_data[:map] as Array<Array<Object?>>;
        if (new_pos[0] < 0 || new_pos[0] >= map.size() || new_pos[1] < 0 || new_pos[1] >= map[0].size()) {
            var dungeon = getApp().getCurrentDungeon();
            var next_room = dungeon.getRoomInDirection(direction);
            if (next_room != null) {
                dungeon.setCurrentRoom(next_room);
                // Set the player position to the new room
                new_pos = getNewPlayerPosInNextRoom(new_pos, direction);
                next_room.setStartPos(new_pos);
                loadRoom(next_room);
                WatchUi.requestUpdate();
            }
            return;
        }

        var map_element = map[new_pos[0]][new_pos[1]] as Object?;
        
		if ((map_element != null) && (map_element instanceof Wall)) {
			return;
		}

        if (map_element != null && map_element instanceof Stairs) {
            var app = getApp();
            app.setCurrentDungeon(null);
            _player.addToCurrentRun(1);
            var progressBar = new WatchUi.ProgressBar(
            "Creating next dungeon...",
            0.0
            );
            WatchUi.switchToView(progressBar, new DCNewDungeonProgressDelegate(progressBar), WatchUi.SLIDE_UP);
            return;
        }

        var enemy_in_pos = false;   
        var enemy = null as Enemy?;

        if (map_element != null && map_element instanceof Item) {
            _player.pickupItem(map_element as Item);
            _room.removeItem(map_element as Item);
        } else {
            var range = _player.getRange(null) as [Numeric, RangeType];
            enemy = MapUtil.getEnemyInRange(map, _player_pos, range[0], range[1], direction);
            if (enemy != null) {
                enemy_in_pos = true;
            }
        }

		System.println("Old pos: " + _player_pos);
        System.println("New pos: " + new_pos);

        var has_moved = false;
        // Move player
        if (!enemy_in_pos && _player_pos != new_pos) {
            movePlayer(map, new_pos);
            has_moved = true;
        }
        // Move enemies
        _room.moveEnemies(new_pos);

        // Remove existing damage texts
        removeDamageTexts();

        // Check if enemy is still there, if not move to position
        var range = _player.getRange(null) as [Numeric, RangeType];
        enemy = MapUtil.getEnemyInRange(map, _player_pos, range[0], range[1], direction);
        if (enemy_in_pos && enemy == null) {
            movePlayer(map, new_pos);
            has_moved = true;
        }

        // Check for enemy collision and attack
        if (!has_moved && enemy != null && _player.canAttack(enemy)) {
            var defeated = Battle.attackEnemy(self, _player, enemy);
            if (defeated) {
                _player.onGainExperience(enemy.getKillExperience());
                _room.dropLoot(enemy);
                _room.removeEnemy(enemy);
            }
            new_pos = _player_pos;
        }
        // Check for enemy collision and attack
        _room.enemiesAttack(self, new_pos);
        _timer.start(method(:removeDamageTexts), 1000, false);

        // Do stuff after the turn is over
        _player.onTurnDone();

		WatchUi.requestUpdate();
	}

    function movePlayer(map as Array<Array<Object?>>, new_pos as Point2D) as Void {
        map[_player_pos[0]][_player_pos[1]] = null;
        map[new_pos[0]][new_pos[1]] = _player;
        _room.updatePlayerPos(new_pos);
        _player_pos = new_pos;
        _player.setPos(new_pos);
    }

    function addDamageText(amount as Number, pos as Point2D) as Void {
        if (amount <= 0) {
            return;
        }
        var damage_text = new WatchUi.Text({
            :text=>"-" + amount, 
            :locX=>pos[0] * _map_data[:tile_width], 
            :locY=>pos[1] * _map_data[:tile_height] - _map_data[:tile_height] / 2, :size=>20,
            :color=>Graphics.COLOR_RED,
            :font=>Graphics.FONT_XTINY
        });
        damage_texts.add(damage_text);
    }

    function getPlayer() as Player {
        return _player;
    }


}
