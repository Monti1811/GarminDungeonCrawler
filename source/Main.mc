import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

module Main {

	function createNewGame1(player as Player, progress_bar as WatchUi.ProgressBar) as Void {
		var app = getApp();
		app.setPlayer(player);
		progress_bar.setProgress(10.0);
		progress_bar.setDisplayString("Creating dungeon");
		
	}

	function createNewGame2(player as Player, progress_bar as WatchUi.ProgressBar, dungeon as Dungeon) as Void {
		var app = getApp();
		app.setCurrentDungeon(dungeon);
		var start_room = MathUtil.random(0, dungeon.getSize()[0] * dungeon.getSize()[1] - 1);
		dungeon.setCurrentRoomFromIndex(MathUtil.IndexToPos2D(start_room, dungeon.getSize()[0]));
		var view_delegate = app.showRoom() as [Views, InputDelegates];
		WatchUi.switchToView(view_delegate[0], view_delegate[1], WatchUi.SLIDE_IMMEDIATE);
	}

	function startGame() as Void {
		Log.log("Game started");
	}

	function createNewDungeon(progress_bar as WatchUi.ProgressBar) as Dungeon {
		var size_x = MathUtil.random(2, 4);
		var size_y = MathUtil.random(2, 4);
		var dungeon = new Dungeon(size_x, size_y);
		return dungeon;
	}

	function createRoomForDungeon(dungeon as Dungeon, i as Number, j as Number) as Void {
		var size_x = dungeon.getSize()[0];
		var size_y = dungeon.getSize()[1];
		var room = createRandomRoom();
		var connections = {};
		// Check for all walkdirections if a connection is possible and if yes, create a connection
		if (i > 0 ){//&& (MathUtil.random(0,100) < 50)) {
			connections[LEFT] = [i - 1, j];
		}
		if (i < size_x - 1){// && (MathUtil.random(0,100) < 50)) {
			connections[RIGHT] = [i + 1, j];
		}
		if (j > 0){// && (MathUtil.random(0,100) < 50)) {
			connections[UP] = [i, j - 1];
		}
		if (j < size_y - 1){// && (MathUtil.random(0,100) < 50)) {
			connections[DOWN] = [i, j + 1];
		}
		dungeon.addRoom(room, [i, j], connections);
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
		var map = new Array<Array<Object?>>[screen_size_x];
        for (var i = 0; i < screen_size_x; i++) {
            map[i] = new Array<Object?>[screen_size_y];
        }
		var map_drawing = createRandomMap(left, right, top, bottom);
		var room = new Room({
			:size_x => room_size_x, 
			:size_y => room_size_y,
			:tile_width => tile_width,
			:tile_height => tile_height,
			:start_pos => middle_of_screen,
			:map => map,
			:map_drawing => map_drawing,
			:items => createRandomItems(map, left, right, top, bottom),
			:enemies => createRandomEnemies(map, left, right, top, bottom)
		});
		
		return room;
	}

	function createRandomMap(left as Number, right as Number, top as Number, bottom as Number) as Dictionary {
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
	}

	function createRandomItems(map as Array<Array<Object?>>, left as Number, right as Number, top as Number, bottom as Number) as Array<Item> {
		var items = [];
		var num_items = MathUtil.random(0, 5);
		for (var i = 0; i < num_items; i++) {
			var item = createRandomItem();
			item.setPos(getRandomPos(map, left, right, top, bottom));
			items.add(item);
		}
		return items;
	}

	function createRandomItem() as Item {
		var item = null;
		var item_type = MathUtil.random(0, 1);
		if (item_type == 0) {
			item = new Helmet();
		} else if (item_type == 1) {
			item = new Axe();
		}
		return item;
	}

	function createRandomEnemies(map as Array<Array<Object?>>, left as Number, right as Number, top as Number, bottom as Number) as Array<Enemy> {
		var enemies = [];
		var num_enemies = MathUtil.random(0, 5);
		for (var i = 0; i < num_enemies; i++) {
			var enemy = createRandomEnemy();
			enemy.setPos(getRandomPos(map, left, right, top, bottom));
			enemies.add(enemy);
		}
		return enemies;
	}

	function createRandomEnemy() as Enemy {
		var enemy = null;
		var enemy_type = MathUtil.random(0, 1);
		if (enemy_type == 0) {
			enemy = new Frog();
		} else if (enemy_type == 1) {
			enemy = new Frog();
		}
		return enemy;
	}

	function getRandomPos(map as Array<Array<Object?>>, left as Number, right as Number, top as Number, bottom as Number) as Point2D {
		var x = 0;
		var y = 0;
		do {
			x = MathUtil.random(left + 1, right - 1);
			y = MathUtil.random(top + 1, bottom - 1);
		} while (map[x][y] != null);
		return [x, y];
	}
}