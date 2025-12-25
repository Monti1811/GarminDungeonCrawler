import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.Graphics;

module Main {

	
	function prepareDungeon(dungeon as Dungeon, state as Number) {
		switch(state) {
			case 1:
				dungeon.addStairs();
				break;
			case 2:
				dungeon.addMerchant();
				var app = getApp();
				app.setCurrentDungeon(dungeon);
				var start_room = MathUtil.random(0, dungeon.getSize()[0] * dungeon.getSize()[1] - 1);
				var pos = MathUtil.IndexToPos2D(start_room, dungeon.getSize()[0]);
				dungeon.setCurrentRoomFromIndex(pos);
				$.Game.setRoomAsVisited(pos);
				break;
		}	
	}

	function createNewGame(player as Player, progress_bar as WatchUi.ProgressBar, dungeon as Dungeon?, state as Number) as Void {
		switch(state) {
			case 1:
				$.Game.init(player.getId());
				var app = getApp();
				app.setPlayer(player);
				progress_bar.setProgress(10.0);
				progress_bar.setDisplayString("Creating dungeon");
				$.SaveData.current_save_num = SaveData.current_save_num + 1;
				$.SaveData.chosen_save = SaveData.current_save_num.toString();
				break;
			case 2:
				prepareDungeon(dungeon, 1);
				prepareDungeon(dungeon, 2);
				var view = new DCIntroView();
				WatchUi.switchToView(view, new DCIntroDelegate(view, null, Graphics.FONT_TINY), WatchUi.SLIDE_IMMEDIATE);
				break;
		}
	}

	function createNextDungeon(progress_bar as WatchUi.ProgressBar, dungeon as Dungeon?, state as Number) as Void {
		switch (state) {
			case 1:
				var player_id = $.getApp().getPlayer().id;
				$.Game.initModules(player_id);
				progress_bar.setProgress(10.0);
				progress_bar.setDisplayString("Creating dungeon");
				break;
			case 2:
				prepareDungeon(dungeon, 1);
				break;
			case 3:
				prepareDungeon(dungeon, 2);
				getApp().getPlayer().onNextDungeon();
				break;
			case 4:
				var app = getApp();
				var view_delegate = app.showRoom() as [Views, InputDelegates];
				WatchUi.switchToView(view_delegate[0], view_delegate[1], WatchUi.SLIDE_IMMEDIATE);
				break;
		}
	}

	function startGame() as Void {
		var app = getApp();
		var view_delegate = app.showRoom() as [Views, InputDelegates];
		WatchUi.switchToView(view_delegate[0], view_delegate[1], WatchUi.SLIDE_IMMEDIATE);
		$.Game.setTimeStarted(Toybox.Time.now());
	}

	function createNewDungeon(progress_bar as WatchUi.ProgressBar) as Dungeon {
		var max_rooms = Settings.settings["rooms_amount"] as Number;
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
		var min_room_size = Settings.settings["min_room_size"] as Number;
		var max_room_size = Settings.settings["max_room_size"] as Number;
		var room_size_x = MathUtil.random(min_room_size, max_room_size);
		var room_size_y = MathUtil.random(min_room_size, max_room_size);

		var middle_of_screen = [Math.floor(screen_size_x/2), Math.floor(screen_size_y/2)];
		var left = middle_of_screen[0] - Math.floor(room_size_x/2);
		var right = middle_of_screen[0] + Math.floor(room_size_x/2);
		var top = middle_of_screen[1] - Math.floor(room_size_y/2);
		var bottom = middle_of_screen[1] + Math.floor(room_size_y/2);
		var map = Map.createRandomMap(screen_size_x, screen_size_y, left, right, top, bottom);
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

	function getItemType() as Number {
		var weighted_types = {
			0 => 20, // Weapons
			1 => 20, // Armor
			2 => 50, // Consumables
			3 => 5  // High Quality
		};
		return MathUtil.weighted_random(weighted_types);
	}


	function createRandomItems(map as Map, left as Number, right as Number, top as Number, bottom as Number, amount_enemies as Number) as Dictionary<Point2D, Item> {
		var items = {};
		var room_size = (right - left - 1) * (bottom - top - 1);
		var num_items = getItemsNumForRoom(amount_enemies, room_size);
		var chest_chance = 10; // Percentage chance to wrap loot in a chest
		for (var i = 0; i < num_items; i++) {
			var type = getItemType();
			var item = createRandomItem(type);
			if (item == null) {
				continue;
			}

			// For High Quality items, increase chance to spawn as chest
			var spawn_as_chest = type == 3 ? MathUtil.random(0, 100) < chest_chance * 4 : MathUtil.random(0, 100) < chest_chance;
			if (spawn_as_chest) {
				var chest = Items.createTreasureChestWithLoot(item);
				var chest_pos = MapUtil.getRandomPosAvoidingTunnels(map, left, right, top, bottom);
				chest.setPos(chest_pos);
				map.setContent(chest_pos, chest);
				items.put(chest_pos, chest);
			} else {
				var item_pos = MapUtil.getRandomPos(map, left, right, top, bottom);
				item.setPos(item_pos);
				map.setContent(item_pos, item);
				items.put(item_pos, item);
			}
		}
		return items;
	}

	function createRandomItem(type as Number) as Item? {
		return Items.createRandomWeightedItem(type);
	}

	function getMaxEnemiesNumForRoom(size_x as Number, size_y as Number) as Number {
		return Math.floor(size_x * size_y / 10);
	}

	function calculateEnemiesForRoom(room_size, difficulty_factor) as Array {
		var depth = $.Game.depth;
		// Scaling factors
		var base_enemies = 1;                         // Minimum enemies per room
		var base_enemy_points = 2;                    // Minimum enemy difficulty points
		var depth_sqrt = Math.sqrt(depth);             // Depth scaling factor
		var room_size_scaling = room_size / 50;       // Larger rooms have more enemies
		var depth_scaling = depth_sqrt / 2;          // Depth increases the number of enemies
		var difficulty_scaling = 1 / difficulty_factor; // Higher difficulty reduces the number of enemies

		// Calculate number of enemies
		var num_enemies = base_enemies + room_size_scaling + depth_scaling * difficulty_scaling;

		if (MathUtil.random(0, 100) < 10) {
			// 10% chance of no enemies in the room
			return [
				0,
				0
			];
		}

		// Ensure a minimum of 1 enemy in the room
		num_enemies = MathUtil.max(1, Math.floor(num_enemies));

		// Determine enemy difficulty points
		var enemy_points = base_enemy_points + Math.floor(depth * difficulty_factor + depth_sqrt * room_size_scaling);

		return [
			num_enemies,        // Number of enemies
			enemy_points       // Points to distribute among enemy difficulties
		];
	}


	function createRandomEnemies(map as Map, left as Number, right as Number, top as Number, bottom as Number) as Dictionary<Point2D,Enemy> {
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
			map.setContent(enemy_pos, enemy);
			enemies.put(enemy_pos, enemy);
		}
		return enemies;
	}

	function filterEnemiesByPoints(enemies as Array<Dictionary<Symbol, Numeric>>, points as Number) as Array {
		var filtered = [];
		for (var i = 0; i < enemies.size(); i++) {
			var enemy = enemies[i];
			if (enemy[:cost] <= points) {
				filtered.add(enemy);
			}
		}
		return filtered;
	}

	function getTotalWeight(enemies as Array<Dictionary<Symbol, Numeric>>) as Number {
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
			var chosen_enemy = null as Dictionary<Symbol, Numeric>?;

			for (var i = 0; i < available_enemies.size(); i++) {
				var enemy = available_enemies[i] as Dictionary<Symbol, Numeric>;
				accumulated_weight += enemy[:weight];
				if (roll <= accumulated_weight) {
					chosen_enemy = enemy;
					break;
				}
			}

			// Add chosen enemy to the list and subtract its cost
			if (chosen_enemy != null) {
				var enemy = Enemies.createEnemyFromId(chosen_enemy[:id]);
				enemy.register();
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