import Toybox.Lang;

class Turn {

    private var _view as DCGameView;

    private var _player_pos as Point2D;
    private var _player as Player;

    private var _room as Room;
    private var _map_data as Dictionary;

    private var is_moving as Boolean = false;

    function initialize(view as DCGameView, player as Player, room as Room, map_data as Dictionary) {
        _view = view;
        _player = player;
        _room = room;
        _map_data = map_data;
        _player_pos = _map_data[:player_pos] as Point2D;
        _player.setPos(_player_pos);

        // Add player position to map
        var map = _map_data[:map] as Array<Array<Object?>>;
        map[_player_pos[0]][_player_pos[1]] = _player;
    }

    function doTurn(direction as WalkDirection) as Void {
		if (is_moving) {
            return;
        }
        System.println("Moving " + direction);
        var new_pos = calculateNewPos(_player_pos, direction);

        var map = _map_data[:map] as Array<Array<Object?>>;
        if (checkIfNextRoom(new_pos, direction, map)) {
            return;
        }

        var map_element = map[new_pos[0]][new_pos[1]] as Object?;
		if ((map_element != null) && (map_element instanceof Wall)) {
			return;
		}

        if (checkIfNextDungeon(map_element)) {
            return;
        }

		System.println("Old pos: " + _player_pos);
        System.println("New pos: " + new_pos);

        resolvePlayerActions(map, new_pos, direction);
        // Resolve enemy actions
        resolveEnemyActions(_room.getEnemies().values(), _player_pos);

        // Remove existing damage texts
        _view.removeDamageTexts();
        _view.getTimer().start(new Method(_view, (:removeDamageTexts)), 1000, false);

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

    function loadRoom(room as Room) as Void {
        _room = room;
        _view.setRoom(room);
        _map_data = room.getMapData();
        _view.setMapData(_map_data);
        _player_pos = _map_data[:start_pos];
        _player.setPos(_player_pos);
        room.updatePlayerPos(_player_pos);
        _view.setPlayerSpritePos(_player_pos);
        var map = _map_data[:map] as Array<Array<Object?>>;
        map[_player_pos[0]][_player_pos[1]] = _player;
    }

    private function getNewPlayerPosInNextRoom(next_pos as Point2D, direction as WalkDirection) as Point2D {
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

    function calculateNewPos(pos as Point2D, direction as WalkDirection) as Point2D {
        var new_pos = pos;
        switch (direction) {
            case UP:
                new_pos = [pos[0], pos[1] - 1];
                break;
            case DOWN:
                new_pos = [pos[0], pos[1] + 1];
                break;
            case LEFT:
                new_pos = [pos[0] - 1, pos[1]];
                break;
            case RIGHT:
                new_pos = [pos[0] + 1, pos[1]];
                break;
            case STANDING:
                new_pos = pos;
                break;
        }
        return new_pos;
    }

    function checkIfNextRoom(new_pos as Point2D, direction as WalkDirection, map as Array<Array<Object?>>) as Boolean {
        if (new_pos[0] < 0 || 
                new_pos[0] >= map.size() || 
                new_pos[1] < 0 || 
                new_pos[1] >= map[0].size()) {
            var dungeon = getApp().getCurrentDungeon();
            var next_room = dungeon.getRoomInDirection(direction);
            if (next_room != null) {
                dungeon.setCurrentRoom(next_room);
                // Set the player position to the new room
                new_pos = getNewPlayerPosInNextRoom(new_pos, direction);
                next_room.setStartPos(new_pos);
                loadRoom(next_room);
                WatchUi.requestUpdate();
                return true;
            }
        }
        return false;
    }

    function checkIfNextDungeon(map_element as Object?) as Boolean {
        if (map_element != null && map_element instanceof Stairs) {
            var app = getApp();
            app.setCurrentDungeon(null);
            _player.addToCurrentRun(1);
            var progressBar = new WatchUi.ProgressBar(
            "Creating next dungeon...",
            0.0
            );
            WatchUi.switchToView(progressBar, new DCNewDungeonProgressDelegate(progressBar), WatchUi.SLIDE_UP);
            return true;
        }
        return false;
    }

    function resolvePlayerActions(map as Array<Array<Object?>>, new_pos as Point2D, direction as WalkDirection) as Void {

        // Check if player can attack enemy, if yes do so and don't move
        var range = _player.getRange(null) as [Numeric, RangeType];
        var attackable_enemy = MapUtil.getEnemyInRange(
            _map_data[:map], _player_pos, range[0], range[1], direction
        );
        var player_attacked = false;
        if (attackable_enemy != null) {
            var death = Battle.attackEnemy(_player, attackable_enemy);
            if (death) {
                _room.removeEnemy(attackable_enemy);
            }
            player_attacked = true;
        }
        // If the player did not attack, try to move
        if (!player_attacked) {
            movePlayer(map, new_pos);
        }

    }

    function resolveEnemyActions(enemies as Array<Enemy>, target_pos as Point2D) as Void {
        // Do enemy actions
        // Sort enemies by distance to player
        var comparator = new MapUtil.EnemyDistanceCompare(_player_pos);
        enemies.sort(comparator);
        
        var maxIterations = 10; 
        var iterations = 0;
        while (iterations < maxIterations) {
            for (var i = 0; i < enemies.size(); i++) {
                var enemy = enemies[i];
                var curr_pos = enemy.getPos();
                if (enemy.attackNearbyPlayer(_map_data[:map], target_pos)) {
                    enemies.remove(enemy);
                    return;
                }   
                var next_pos = enemy.findNextMove(_map_data[:map]);
                if (next_pos != curr_pos) {
                    if (MapUtil.isPosPlayer(_map_data[:map], next_pos)) {
                        Battle.attackPlayer(enemy, _player, target_pos);
                        enemies.remove(enemy);
                    } else {
                        var map = _map_data[:map] as Array<Array<Object?>>;
                        map[curr_pos[0]][curr_pos[1]] = null;
                        map[next_pos[0]][next_pos[1]] = enemy;
                        enemy.setPos(next_pos);
                        enemies.remove(enemy);
                    }
                }
            }
            iterations++;
        }
    }
        

}
