import Toybox.Test;
import Toybox.Lang;
import Toybox.Application.Storage;
import Toybox.System;

// ============================================================
// Room Creation Profiling Test
// Measures per-phase timing at depth=100 to identify watchdog
// trip hotspots. Uses Sys.getTimer() for wall-clock ms.
// ============================================================

(:test)
module RoomCreationProfileTest {

	var _room_names as Array<String> = [];

	function setupSettings() as Void {
		Settings.settings["rooms_amount"] = 4;
		Settings.settings["min_room_size"] = 15;
		Settings.settings["max_room_size"] = 15;
		$.SaveData.chosen_save = "test";
		$.Game.depth = 100;
		$.Game.initModules(1);
	}

	function cleanupStorage() as Void {
		for (var i = 0; i < _room_names.size(); i++) {
			Storage.deleteValue(_room_names[i]);
		}
		_room_names = [];
	}

	function nowMs() as Number {
		return System.getTimer().toNumber();
	}

	// --- Test: profile a single room creation at depth=100 ---
	(:test)
	function testProfileSingleRoom(logger as Test.Logger) as Boolean {
		setupSettings();

		var room_shape = Map.chooseRandomRoomShape();
		logger.debug("=== PROFILING SINGLE ROOM: depth=100, shape=" + room_shape + " ===");

		// 1. Full createRandomRoom (includes createRoomShape + addIslands + enemies + items)
		var t0 = nowMs();
		var room = Main.createRandomRoom(room_shape);
		var t1 = nowMs();
		logger.debug("[1] createRandomRoom (full): " + (t1 - t0) + "ms");

		// 2. cleanupRoomForDungeon (addWallsAroundPassable)
		t0 = nowMs();
		Main.cleanupRoomForDungeon(room);
		t1 = nowMs();
		logger.debug("[2] cleanupRoomForDungeon: " + (t1 - t0) + "ms");

		// 3. saveRoomForDungeon (storage write)
		var room_name = "profile_test_room";
		_room_names.add(room_name);
		t0 = nowMs();
		var saved = room.save();
		Storage.setValue(room_name, saved);
		t1 = nowMs();
		logger.debug("[3] saveRoom (storage write): " + (t1 - t0) + "ms");

		logger.debug("--- TOTAL per room: " + ((t1 - t0)) + "ms (save only) ---");
		logger.debug("Full room creation + cleanup = steps 1+2");

		room.freeMemory();
		return true;
	}

	// --- Test: profile chooseEnemies at different enemy_points ---
	(:test)
	function testProfileChooseEnemies(logger as Test.Logger) as Boolean {
		setupSettings();

		// depth=100, room_area=225, diff=1 → enemy_points ≈ 116
		var points_array = [50, 100, 150, 200] as Array<Number>;
		for (var p = 0; p < points_array.size(); p++) {
			var pts = points_array[p];
			var t0 = nowMs();
			var enemies = Main.chooseEnemies(15, pts);
			var t1 = nowMs();
			logger.debug("chooseEnemies(pts=" + pts + "): " + (t1 - t0) + "ms, " + enemies.size() + " enemies");
		}

		return true;
	}

	// --- Test: profile getRandomPos with increasing entity count ---
	(:test)
	function testProfileGetRandomPos(logger as Test.Logger) as Boolean {
		setupSettings();

		logger.debug("=== PROFILING getRandomPos ===");

		// Use createRandomRoom to get a real room, then measure getRandomPos
		var room = Main.createRandomRoom(ROOMSHAPE_RECTANGLE);
		var map = room.getMap();
		var left = room.getLeft();
		var right = room.getRight();
		var top = room.getTop();
		var bottom = room.getBottom();

		// Measure getRandomPos with increasing fill
		var fill_levels = [0, 5, 10, 14] as Array<Number>;
		for (var f = 0; f < fill_levels.size(); f++) {
			var fill = fill_levels[f];
			// Create fresh room for each fill level
			var fresh_room = Main.createRandomRoom(ROOMSHAPE_RECTANGLE);
			var fresh_map = fresh_room.getMap();
			var fleft = fresh_room.getLeft();
			var fright = fresh_room.getRight();
			var ftop = fresh_room.getTop();
			var fbottom = fresh_room.getBottom();

			// Pre-fill with enemies
			for (var i = 0; i < fill; i++) {
				var pos = MapUtil.getRandomPos(fresh_map, fleft, fright, ftop, fbottom);
				fresh_map.setContent(pos, new Frog());
			}

			var t0 = nowMs();
			for (var i = 0; i < 5; i++) {
				MapUtil.getRandomPos(fresh_map, fleft, fright, ftop, fbottom);
			}
			var t1 = nowMs();
			logger.debug("getRandomPos x5 (fill=" + fill + "): " + (t1 - t0) + "ms");
			fresh_room.freeMemory();
		}

		// Measure getRandomPosAvoidingTunnels
		var t0 = nowMs();
		for (var i = 0; i < 5; i++) {
			MapUtil.getRandomPosAvoidingTunnels(map, left, right, top, bottom);
		}
		var t1 = nowMs();
		logger.debug("getRandomPosAvoidingTunnels x5: " + (t1 - t0) + "ms");

		// Measure addWallsAroundPassable
		t0 = nowMs();
		Map.addWallsAroundPassable(map);
		t1 = nowMs();
		logger.debug("addWallsAroundPassable: " + (t1 - t0) + "ms");

		room.freeMemory();
		return true;
	}

	// --- Test: profile full 9-room dungeon at depth=100 ---
	(:test)
	function testProfileFullDungeon9Rooms(logger as Test.Logger) as Boolean {
		setupSettings();

		var size_x = 3;
		var size_y = 3;
		var dungeon = new Dungeon(size_x, size_y);
		dungeon.connectRoomsRandomly();
		$.Game.initMap(size_x, size_y);

		var total = size_x * size_y;
		logger.debug("=== PROFILING FULL DUNGEON: " + size_x + "x" + size_y + "=" + total + " rooms, depth=100 ===");

		var t_total_start = nowMs();
		var room_times = [] as Array<Number>;

		for (var j = 0; j < size_y; j++) {
			for (var i = 0; i < size_x; i++) {
				var room_name = $.SimUtil.getRoomName(i, j);
				_room_names.add(room_name);

				var t_room_start = nowMs();

				var room_shape = Map.chooseRandomRoomShape();
				var room = Main.createRandomRoom(room_shape);

				var connections = dungeon.getConnections();
				var room_connections = connections[room_name];
				if (room_connections != null) {
					var keys = room_connections.keys();
					for (var k = 0; k < keys.size(); k++) {
						room.addConnection(keys[k]);
					}
				}

				Main.cleanupRoomForDungeon(room);

				dungeon.addRoom(room, [i, j]);
				$.Game.addRoomToMap([i, j], room_name, room_connections, room.getSize(), room.getShape());
				room.freeMemory();

				var t_room_end = nowMs();
				var elapsed = t_room_end - t_room_start;
				room_times.add(elapsed);
				logger.debug("Room [" + i + "," + j + "]: " + elapsed + "ms");
			}
		}

		var t_total_end = nowMs();
		var total_time = t_total_end - t_total_start;
		logger.debug("=== TOTAL: " + total_time + "ms for " + total + " rooms ===");
		logger.debug("Average per room: " + (total_time.toFloat() / total) + "ms");

		// Worst single room
		var max_room_ms = 0;
		for (var i = 0; i < room_times.size(); i++) {
			if (room_times[i] > max_room_ms) {
				max_room_ms = room_times[i];
			}
		}
		logger.debug("Worst single room: " + max_room_ms + "ms");
		logger.debug("Watchdog threshold estimate: 2000-4000ms on device");
		if (max_room_ms > 2000) {
			logger.debug("*** WARNING: Single room exceeds 2s! ***");
		}

		cleanupStorage();
		return true;
	}

	// --- Test: profile enemy calculation breakdown ---
	(:test)
	function testProfileEnemyCalculation(logger as Test.Logger) as Boolean {
		setupSettings();

		var room_area = 225; // 15x15 max
		var diff = 1;
		var room_max = Main.getMaxEnemiesNumForRoom(15, 15);
		var values = Main.calculateEnemiesForRoom(room_area, diff, room_max);
		var num_enemies = values[0] as Number;
		var enemy_points = values[1] as Number;

		logger.debug("=== ENEMY CALCULATION BREAKDOWN ===");
		logger.debug("room_area=" + room_area + " depth=100 diff=" + diff);
		logger.debug("num_enemies=" + num_enemies + " enemy_points=" + enemy_points);

		// Simulate chooseEnemies loop iterations
		var remaining_points = enemy_points;
		var chosen = 0;
		var iterations = 0;
		var max_enemies = $.Constants.MAX_ENEMIES_PER_ROOM;
		var total_filtered = 0;

		while (remaining_points > 0 && chosen < max_enemies) {
			var available = Main.filterEnemiesByPoints($.Enemies.dungeon_enemies, remaining_points);
			if (available.size() == 0) {
				break;
			}
			total_filtered += available.size();
			// Simulate picking cheapest enemy
			var min_cost = 999999;
			for (var i = 0; i < available.size(); i++) {
				if (available[i][:cost] < min_cost) {
					min_cost = available[i][:cost];
				}
			}
			remaining_points -= min_cost;
			chosen += 1;
			iterations += 1;
		}

		logger.debug("chooseEnemies iterations: " + iterations);
		logger.debug("Final chosen: " + chosen + " enemies");
		logger.debug("Remaining points: " + remaining_points);
		logger.debug("Total enemies scanned (sum of filtered lists): " + total_filtered);

		return true;
	}
}
