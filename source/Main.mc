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
		var pos = MathUtil.IndexToPos2D(start_room, dungeon.getSize()[0]);
		dungeon.setCurrentRoomFromIndex(pos);
		$.Game.setRoomAsVisited(pos);
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
		getApp().getPlayer().onNextDungeon();
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
		var max_rooms = Settings.settings["rooms_amount"];
		var size_x = MathUtil.random(2, max_rooms);
		var size_y = MathUtil.random(2, max_rooms);
		var dungeon = new Dungeon(size_x, size_y);
		dungeon.connectRoomsRandomly();
		$.Game.initMap(size_x, size_y);
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
		$.Game.addRoomToMap([i, j], room_name, room_connections, room.getSize());
	}

	function createRandomRoom() as Room {
		var tile_width = getApp().tile_width;
		var tile_height = getApp().tile_height;
		var screen_size_x = Math.ceil(360.0/tile_width).toNumber();
		var screen_size_y = Math.ceil(360.0/tile_height).toNumber();
		var min_room_size = Settings.settings["min_room_size"];
		var max_room_size = Settings.settings["max_room_size"];
		var room_size_x = MathUtil.random(min_room_size, max_room_size);
		var room_size_y = MathUtil.random(min_room_size, max_room_size);

		var middle_of_screen = [Math.floor(screen_size_x/2), Math.floor(screen_size_y/2)];
		var left = middle_of_screen[0] - Math.floor(room_size_x/2);
		var right = middle_of_screen[0] + Math.floor(room_size_x/2);
		var top = middle_of_screen[1] - Math.floor(room_size_y/2);
		var bottom = middle_of_screen[1] + Math.floor(room_size_y/2);
		var map = createRandomMap(screen_size_x, screen_size_y, left, right, top, bottom);
		var enemies = createRandomEnemies(map, left, right, top, bottom);
		var items = createRandomItems(map, left, right, top, bottom, enemies.size());
		var room = new Room({
			:size_x => room_size_x, 
			:size_y => room_size_y,
			:tile_width => tile_width,
			:tile_height => tile_height,
			:start_pos => middle_of_screen,
			:map => map,
			:items => items,
			:enemies => enemies
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

	function getItemsNumForRoom(enemy_count as Number, room_size as Number) as Number {
		var depth = $.Game.depth;
		var base_items = 0.5;                   // Minimum items per room
		var scaling_factor = 0.15;              // Depth scaling factor
		var room_size_factor = room_size / 100; // Larger rooms are more likely to have more items
		var enemy_factor = enemy_count / 4;     // 1 item per 4 enemies

		// Calculate base number of items
		var items = base_items 
					+ scaling_factor * Math.sqrt(depth)  // Depth scaling
					+ enemy_factor                 // Enemies influence item count
					+ room_size_factor;           // Larger rooms yield slightly more items

		// Randomization
		if (MathUtil.random(0, 100) < 30) {
			// 30% chance of no items in the room
			return 0;
		}

		// Ensure at least 1 item if enemies are present
		items = enemy_count > 0 ? MathUtil.max(1, items) : items;

		// Round down to avoid fractional items
		return Math.floor(items);
	}


	function createRandomItems(map as Array<Array<Tile>>, left as Number, right as Number, top as Number, bottom as Number, amount_enemies as Number) as Dictionary<Point2D, Item> {
		var items = {};
		var room_size = (right - left - 1) * (bottom - top - 1);
		var num_items = getItemsNumForRoom(amount_enemies, room_size);
		var type = 0;
		for (var i = 0; i < num_items; i++) {
			var item = createRandomItem(type);
			var item_pos = MapUtil.getRandomPos(map, left, right, top, bottom);
			item.setPos(item_pos);
			map[item_pos[0]][item_pos[1]].content = item;
			items.put(item_pos, item);
		}
		return items;
	}

	function createRandomItem(type as Number) as Item {
		return Items.createRandomWeightedItem(type);
	}

	function getMaxEnemiesNumForRoom(size_x as Number, size_y as Number) as Number {
		return Math.floor(size_x * size_y / 10);
	}

	function calculateEnemiesForRoom(room_size, difficulty_factor) as Array {
		var depth = $.Game.depth;
		// Scaling factors
		var base_enemies = 1;                         // Minimum enemies per room
		var depth_sqrt = Math.sqrt(depth);             // Depth scaling factor
		var room_size_scaling = room_size / 50;       // Larger rooms have more enemies
		var depth_scaling = depth_sqrt / 2;          // Depth increases the number of enemies
		var difficulty_scaling = 1 / difficulty_factor; // Higher difficulty reduces the number of enemies

		// Calculate number of enemies
		var num_enemies = base_enemies + room_size_scaling + depth_scaling * difficulty_scaling;

		if (MathUtil.random(0, 100) < 10) {
			// 30% chance of no enemies in the room
			return [
				0,
				0
			];
		}

		// Ensure a minimum of 1 enemy in the room
		num_enemies = MathUtil.max(1, Math.floor(num_enemies));

		// Determine enemy difficulty points
		var enemy_points = Math.floor(depth * difficulty_factor + depth_sqrt * room_size_scaling);

		return [
			num_enemies,        // Number of enemies
			enemy_points       // Points to distribute among enemy difficulties
		];
	}


	function createRandomEnemies(map as Array<Array<Tile>>, left as Number, right as Number, top as Number, bottom as Number) as Dictionary<Point2D,Enemy> {
		var enemies = {};
		var diff = 1;
		if (MathUtil.random(0, 100) < 10) {
			diff = 2;
		}
		var values = calculateEnemiesForRoom((right - left - 1) * (bottom - top - 1), diff);
		var possible_enemies = chooseEnemies(values[1]);
		for (var i = 0; i < possible_enemies.size(); i++) {
			var enemy = possible_enemies[i];
			var enemy_pos = MapUtil.getRandomPos(map, left, right, top, bottom);
			enemy.setPos(enemy_pos);
			map[enemy_pos[0]][enemy_pos[1]].content = enemy;
			enemies.put(enemy_pos, enemy);
		}
		return enemies;
	}

	function filterEnemiesByPoints(enemies as Array, points as Number) as Array {
		var filtered = [];
		for (var i = 0; i < enemies.size(); i++) {
			if (enemies[i][:cost] <= points) {
				filtered.add(enemies[i]);
			}
		}
		return filtered;
	}

	function getTotalWeight(enemies as Array) as Number {
		var total_weight = 0;
		for (var i = 0; i < enemies.size(); i++) {
			total_weight += enemies[i][:weight];
		}
		return total_weight;
	}

	function chooseEnemies(allocated_points as Number) as Array<Enemy> {
		var chosen_enemies = [];
		var remaining_points = allocated_points;

		while (remaining_points > 0) {
			// Filter enemies by remaining points
			var available_enemies = filterEnemiesByPoints(Enemies.dungeon_enemies, remaining_points);

			// If no enemies fit within the points, stop the loop
			if (available_enemies.size() == 0) {
				break;
			}

			// Calculate total weight for available enemies
			var total_weight = getTotalWeight(available_enemies);

			// Randomly select an enemy based on weights
			var roll = MathUtil.rand() * total_weight;
			var accumulated_weight = 0;
			var chosen_enemy = null;

			for (var i = 0; i < available_enemies.size(); i++) {
				accumulated_weight += available_enemies[i][:weight];
				if (roll <= accumulated_weight) {
					chosen_enemy = available_enemies[i];
					break;
				}
			}

			// Add chosen enemy to the list and subtract its cost
			if (chosen_enemy) {
				var enemy = Enemies.createEnemyFromId(chosen_enemy[:id]);
				chosen_enemies.add(enemy);
				remaining_points -= chosen_enemy[:cost];
			}
		}

		return chosen_enemies;
	}

	function createRandomEnemy() as Enemy {
		return Enemies.createRandomWeightedEnemy();
	}

}