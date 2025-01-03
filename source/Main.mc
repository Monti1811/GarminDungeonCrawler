import Toybox.Lang;
import Toybox.Math;

module Main {

	function createNewGame(player as Player) as Void {
		var app = getApp();
		app.setPlayer(player);
		app.setCurrentDungeon(createNewDungeon());
		var view_delegate = app.showRoom() as [Views, InputDelegates];
		WatchUi.switchToView(view_delegate[0], view_delegate[1], WatchUi.SLIDE_IMMEDIATE);
	}

	function startGame() as Void {
		Log.log("Game started");
	}

	function createNewDungeon() as Dungeon {
		var size_x = MathUtil.random(3, 5);
		var size_y = MathUtil.random(3, 5);
		var dungeon = new Dungeon(size_x, size_y);
		for (var i = 0; i < size_x; i++) {
			for (var j = 0; j < size_y; j++) {
				var room = createRandomRoom();
				var connections = {};
				// Check for all walkdirections if a connection is possible and if yes, create a connection
				if (i > 0 && (MathUtil.random(0,100) < 50)) {
					connections[LEFT] = [i - 1, j];
				}
				if (i < size_x - 1 && (MathUtil.random(0,100) < 50)) {
					connections[RIGHT] = [i + 1, j];
				}
				if (j > 0 && (MathUtil.random(0,100) < 50)) {
					connections[UP] = [i, j - 1];
				}
				if (j < size_y - 1 && (MathUtil.random(0,100) < 50)) {
					connections[DOWN] = [i, j + 1];
				}
				dungeon.addRoom(room, [i, j], connections);
			}
		}
		return dungeon;
	}

	function createRandomRoom() as Room {
		var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
		var screen_size_x = Math.ceil(360/tile_width);
		var screen_size_y = Math.ceil(360/tile_height);
		var room_size_x = MathUtil.random(5, 15);
		var room_size_y = MathUtil.random(5, 15);

		var middle_of_screen = [Math.floor(screen_size_x/2), Math.floor(screen_size_y/2)];
		var left = middle_of_screen[0] - room_size_x;
		var right = middle_of_screen[0] + room_size_x;
		var top = middle_of_screen[1] - room_size_y;
		var bottom = middle_of_screen[1] + room_size_y;
		var room = new Room({
			:size_x => room_size_x, 
			:size_y => room_size_y,
			:tile_width => tile_width,
			:tile_height => tile_height,
			:start_pos => [Math.floor(tile_width), Math.floor(tile_height)],
			:map => createRandomMap(left, right, top, bottom),
			:items => createRandomItems(left, right, top, bottom),
			:enemies => createRandomEnemies(left, right, top, bottom)
		});
		
		return room;
	}

	function createRandomMap(left as Number, right as Number, top as Number, bottom as Number) as Dictionary {
		var walls = {};
		walls[:drawTopLeftWall] = [
			[left, top]
		];
		walls[:drawTopRightWall] = [
			[right, top]
		];
		walls[:drawBottomLeftWall] = [
			[left, bottom]
		];
		walls[:drawBottomRightWall] = [
			[right, bottom]
		];
		walls[:drawTopWall] = [];
		for (var i = left + 1; i < right; i++) {
			walls[:drawTopWall].add([top, i]);
		}
		walls[:drawBottomWall] = [];
		for (var i = left + 1; i < right; i++) {
			walls[:drawBottomWall].add([bottom, i]);
		}
		walls[:drawLeftWall] = [];
		for (var j = top + 1; j < bottom; j++) {
			walls[:drawLeftWall].add([j, left]);
		}
		walls[:drawRightWall] = [];
		for (var j = top + 1; j < bottom; j++) {
			walls[:drawRightWall].add([j, right]);
		}

		var passable = [];
		for (var i = left + 1; i < right; i++) {
			for (var j = top + 1; i < bottom; j++) {
				passable.add([i, j]);
			}
		}
		
		return {
            :walls => walls,
            :drawPassable => passable
        };
	}

	function createRandomItems(left as Number, right as Number, top as Number, bottom as Number) as Array<Item> {
		var items = [];
		var num_items = MathUtil.random(0, 5);
		for (var i = 0; i < num_items; i++) {
			var item = createRandomItem();
			item.setPos(getRandomPos(left, right, top, bottom));
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

	function createRandomEnemies(left as Number, right as Number, top as Number, bottom as Number) as Array<Enemy> {
		var enemies = [];
		var num_enemies = MathUtil.random(0, 5);
		for (var i = 0; i < num_enemies; i++) {
			var enemy = createRandomEnemy();
			enemy.setPos(getRandomPos(left, right, top, bottom));
			enemies.add();
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

	private function getRandomPos(left as Number, right as Number, top as Number, bottom as Number) as Point2D {
		var x = MathUtil.random(left + 1, right - 1);
		var y = MathUtil.random(top + 1, bottom - 1);
		return [x, y];
	}
}