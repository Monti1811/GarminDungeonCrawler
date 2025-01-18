import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Graphics;

module Main {

	function prepareDungeon(dungeon as Dungeon) {
		dungeon.addStairs();
		dungeon.addMerchant();
		var app = getApp();
		app.setCurrentDungeon(dungeon);
		var start_room = MathUtil.random(0, dungeon.getSize()[0] * dungeon.getSize()[1] - 1);
		dungeon.setCurrentRoomFromIndex(MathUtil.IndexToPos2D(start_room, dungeon.getSize()[0]));
	}

	function createNewGame1(player as Player, progress_bar as WatchUi.ProgressBar) as Void {
		$.Game.init(player.getId());
		var app = getApp();
		app.setPlayer(player);
		progress_bar.setProgress(10.0);
		progress_bar.setDisplayString("Creating dungeon");
		$.SaveData.current_save_num = SaveData.current_save_num + 1;
        $.SaveData.chosen_save = SaveData.current_save_num.toString();
		
	}

	function createNewGame2(player as Player, progress_bar as WatchUi.ProgressBar, dungeon as Dungeon) as Void {
		prepareDungeon(dungeon);
		var view = new DCIntroView();
		WatchUi.switchToView(view, new DCIntroDelegate(view, null, Graphics.FONT_TINY), WatchUi.SLIDE_IMMEDIATE);
	}

	function createNextDungeon1(progress_bar as WatchUi.ProgressBar) as Void {
		progress_bar.setProgress(10.0);
		progress_bar.setDisplayString("Creating dungeon");
		
	}

	function createNextDungeon2(progress_bar as WatchUi.ProgressBar, dungeon as Dungeon) as Void {
		prepareDungeon(dungeon);
		var view_delegate = getApp().showRoom() as [Views, InputDelegates];
		WatchUi.switchToView(view_delegate[0], view_delegate[1], WatchUi.SLIDE_IMMEDIATE);
	}

	function startGame() as Void {
		var app = getApp();
		var view_delegate = app.showRoom() as [Views, InputDelegates];
		WatchUi.switchToView(view_delegate[0], view_delegate[1], WatchUi.SLIDE_IMMEDIATE);
		$.Game.setTimeStarted(Toybox.Time.now());
	}

	function createNewDungeon(progress_bar as WatchUi.ProgressBar) as Dungeon {
		var size_x = MathUtil.random(2, 4);
		var size_y = MathUtil.random(2, 4);
		var dungeon = new Dungeon(size_x, size_y);
		dungeon.connectRoomsRandomly();
		return dungeon;
	}

	function createRoomForDungeon(dungeon as Dungeon, i as Number, j as Number) as Void {
		var room = createRandomRoom();
		var connections = dungeon.getConnections();
		var room_name = $.SimUtil.getRoomName(i, j);
		var room_connections = connections[room_name];
		if (room_connections != null) {
			var connections_keys = room_connections.keys();
			for (var k = 0; k < connections_keys.size(); k++) {
				var direction = connections_keys[k];
				room.addConnection(direction);
			}
		}
		dungeon.addRoom(room, [i, j]);
	}

	function createRandomRoom() as Room {
		var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
		var screen_size_x = Math.ceil(360.0/tile_width).toNumber();
		var screen_size_y = Math.ceil(360.0/tile_height).toNumber();
		var room_size_x = MathUtil.random(5, 15);
		var room_size_y = MathUtil.random(5, 15);

		var middle_of_screen = [Math.floor(screen_size_x/2), Math.floor(screen_size_y/2)];
		var left = middle_of_screen[0] - Math.floor(room_size_x/2);
		var right = middle_of_screen[0] + Math.floor(room_size_x/2);
		var top = middle_of_screen[1] - Math.floor(room_size_y/2);
		var bottom = middle_of_screen[1] + Math.floor(room_size_y/2);
		var map = createRandomMap(screen_size_x, screen_size_y, left, right, top, bottom);
		var room = new Room({
			:size_x => room_size_x, 
			:size_y => room_size_y,
			:tile_width => tile_width,
			:tile_height => tile_height,
			:start_pos => middle_of_screen,
			:map => map,
			:items => createRandomItems(map, left, right, top, bottom),
			:enemies => createRandomEnemies(map, left, right, top, bottom)
		});
		
		return room;
	}

	function createRandomMap(screen_size_x as Number, screen_size_y as Number, left as Number, right as Number, top as Number, bottom as Number) as  Array<Array<Tile>> {
		var map = new Array<Array<Tile>>[screen_size_x];
        for (var i = 0; i < screen_size_x; i++) {
            map[i] = new Array<Tile>[screen_size_y];
			for (var j = 0; j < screen_size_y; j++) {
				map[i][j] = new Tile(i, j);
			}
        }

		// Add walls to tiles by changing the type of the tile
		// Top wall
		for (var i = left; i <= right; i++) {
			map[i][top].type = WALL;
		}
		// Bottom wall
		for (var i = left; i <= right; i++) {
			map[i][bottom].type = WALL;
		}
		// Left wall
		for (var j = top; j <= bottom; j++) {
			map[left][j].type = WALL;
		}
		// Right wall
		for (var j = top; j <= bottom; j++) {
			map[right][j].type = WALL;
		}

		// Add passable to tiles
		for (var i = left + 1; i < right; i++) {
			for (var j = top + 1; j < bottom; j++) {
				map[i][j].type = PASSABLE;
			}
		}

		return map;
	}

	/*function createRandomMap(left as Number, right as Number, top as Number, bottom as Number) as Dictionary {
		var walls = {};
		walls[:drawBottomRightWall] = [
			[left, top]
		];
		walls[:drawTopRightWall] = [
			[left, bottom]
		];
		walls[:drawBottomLeftWall] = [
			[right, top]
		];
		walls[:drawTopLeftWall] = [
			[right, bottom]
		];
		walls[:drawTopWall] = [];
		for (var i = left + 1; i < right; i++) {
			walls[:drawTopWall].add([i, bottom]);
		}
		walls[:drawBottomWall] = [];
		for (var i = left + 1; i < right; i++) {
			walls[:drawBottomWall].add([i, top]);
		}
		walls[:drawLeftWall] = [];
		for (var j = top + 1; j < bottom; j++) {
			walls[:drawLeftWall].add([right, j]);
		}
		walls[:drawRightWall] = [];
		for (var j = top + 1; j < bottom; j++) {
			walls[:drawRightWall].add([left, j]);
		}

		var passable = [];
		for (var i = left + 1; i < right; i++) {
			for (var j = top + 1; j < bottom; j++) {
				passable.add([i, j]);
			}
		}
		
		return {
            :walls => walls,
            :drawPassable => passable
        };
	}*/

	function getMaxItemsNumForRoom(size_x as Number, size_y as Number) as Number {
		return Math.floor(size_x * size_y / 20);
	}

	function createRandomItems(map as Array<Array<Tile>>, left as Number, right as Number, top as Number, bottom as Number) as Dictionary<Point2D, Item> {
		var items = {};
		var num_items = MathUtil.random(0, getMaxItemsNumForRoom(right - left - 1, bottom - top - 1));
		for (var i = 0; i < num_items; i++) {
			var item = createRandomItem();
			var item_pos = MapUtil.getRandomPos(map, left, right, top, bottom);
			item.setPos(item_pos);
			map[item_pos[0]][item_pos[1]].content = item;
			items.put(item_pos, item);
		}
		return items;
	}

	function createRandomItem() as Item {
		return Items.createRandomWeightedItem();
	}

	function getMaxEnemiesNumForRoom(size_x as Number, size_y as Number) as Number {
		return Math.floor(size_x * size_y / 10);
	}

	function createRandomEnemies(map as Array<Array<Tile>>, left as Number, right as Number, top as Number, bottom as Number) as Dictionary<Point2D,Enemy> {
		var enemies = {};
		var num_enemies = MathUtil.random(0, getMaxEnemiesNumForRoom(right - left - 1, bottom - top - 1));
		for (var i = 0; i < num_enemies; i++) {
			var enemy = createRandomEnemy();
			var enemy_pos = MapUtil.getRandomPos(map, left, right, top, bottom);
			enemy.setPos(enemy_pos);
			map[enemy_pos[0]][enemy_pos[1]].content = enemy;
			enemies.put(enemy_pos, enemy);
		}
		return enemies;
	}

	function createRandomEnemy() as Enemy {
		return Enemies.createRandomWeightedEnemy();
	}

}