import Toybox.Lang;
import Toybox.Math;

module Main {

	function createNewGame(player as Player) as Void {
		var app = getApp();
		app.setPlayer(player);
		app.setCurrentDungeon(createNewDungeon());
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
		var room = new Room({
			:size_x => Math.ceil(360/tile_width), 
			:size_y => Math.ceil(360/tile_height),
			:tile_width => tile_width,
			:tile_height => tile_height,
			:start_pos => [Math.floor(tile_width), Math.floor(tile_height)],
			:map => createRandomMap(size_x, size_y),
			:items => createRandomItems(),
			:enemies => createRandomEnemies()

		});
		
		return room;
	}

	function createRandomMap(size_x as Number, size_y as Number) as Dictionary {
		var size_x = MathUtil.random(10, 20);
		var size_y = MathUtil.random(10, 20);
		var map = {
            :walls => {},
            :drawPassable => []
        };
	}

	function createRandomItems() as Array<Item> {
		var items = [];
		var num_items = MathUtil.random(0, 5);
		for (var i = 0; i < num_items; i++) {
			items.add(createRandomItem());
		}
		return items;
	}

	function createRandomItem() as Item {
		var item = null;
		var item_type = MathUtil.random(0, 1);
		if (item_type == 0) {
			item = new Helmet();
		} else {
			item = new Axe();
		}
		return item;
	}

	function createRandomEnemies() as Array<Enemy> {
		var enemies = [];
		var num_enemies = MathUtil.random(0, 5);
		for (var i = 0; i < num_enemies; i++) {
			enemies.add(createRandomEnemy());
		}
		return enemies;
	}

	function createRandomEnemy() as Enemy {
		var enemy = null;
		var enemy_type = MathUtil.random(0, 1);
		if (enemy_type == 0) {
			enemy = new Frog();
		} else {
			enemy = new Frog();
		}
		return enemy;
	}
}