import Toybox.Test;
import Toybox.Lang;
import Toybox.Application.Storage;

// ============================================================
// Room Creation Stress Test
// Mirrors the exact pipeline from DCNewDungeonProgressDelegate.onTimer:
//   createNewDungeon → for each room: createRoomForDungeon →
//   cleanupRoomForDungeon → saveRoomForDungeon → load back
// Then prepareDungeon (stairs, merchant, quest giver) and cleanup.
// ============================================================

(:test)
module RoomCreationStressTest {

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

	function addRoomToDungeon(
		dungeon as Dungeon, i as Number, j as Number,
		logger as Test.Logger
	) as Void {
		var room_name = $.SimUtil.getRoomName(i, j);
		_room_names.add(room_name);

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
	}

	// --- Test: full dungeon creation pipeline with save/load ---

	(:test)
	function testFullDungeonPipelineMaxRoomSize(logger as Test.Logger) as Boolean {
		setupSettings();

		var max_rooms = Settings.settings["rooms_amount"] as Number;
		var size_x = MathUtil.random(2, max_rooms);
		var size_y = MathUtil.random(2, max_rooms);
		var dungeon = new Dungeon(size_x, size_y);
		dungeon.connectRoomsRandomly();
		$.Game.initMap(size_x, size_y);

		var total = size_x * size_y;
		logger.debug("Dungeon size: " + size_x + "x" + size_y + " = " + total + " rooms");

		// 1. Create all rooms (mirrors onTimer phases 0→1→2)
		for (var j = 0; j < size_y; j++) {
			for (var i = 0; i < size_x; i++) {
				addRoomToDungeon(dungeon, i, j, logger);
			}
		}

		// 2. Verify all rooms saved to Storage, load back
		for (var j = 0; j < size_y; j++) {
			for (var i = 0; i < size_x; i++) {
				var room_name = $.SimUtil.getRoomName(i, j);
				var saved = Storage.getValue(room_name) as Dictionary?;
				Test.assertMessage(saved != null, "Room " + room_name + " should be in Storage");

				var loaded_room = Room.load(saved as Dictionary);
				Test.assertMessage(loaded_room != null, "Room " + room_name + " should load");

				var loaded_map = loaded_room.getMap();
				Test.assertMessage(loaded_map != null, "Loaded map should not be null for " + room_name);

				var passable_count = 0;
				var w = loaded_map.getXSize();
				var h = loaded_map.getYSize();
				for (var x = 0; x < w; x++) {
					for (var y = 0; y < h; y++) {
						if (loaded_map.getTile(x, y).type == PASSABLE) {
							passable_count += 1;
						}
					}
				}
				Test.assertMessage(passable_count > 0, "Loaded room " + room_name + " should have passable tiles (has " + passable_count + ")");
			}
		}

		// 3. prepareDungeon: stairs, merchant, quest giver
		dungeon.addStairs();
		dungeon.addMerchant();
		dungeon.addQuestGiver();

		// 4. Reload rooms after prepareDungeon
		for (var j = 0; j < size_y; j++) {
			for (var i = 0; i < size_x; i++) {
				var room_name = $.SimUtil.getRoomName(i, j);
				var saved = Storage.getValue(room_name) as Dictionary?;
				Test.assertMessage(saved != null, "Room " + room_name + " should still be in Storage after prepareDungeon");
				var loaded_room = Room.load(saved as Dictionary);
				Test.assertMessage(loaded_room != null, "Room " + room_name + " should load after prepareDungeon");
			}
		}

		logger.debug("Full dungeon pipeline passed (" + total + " rooms created, saved, loaded, prepared)");
		cleanupStorage();
		return true;
	}

	// --- Test: stress with max room sizes, multiple dungeon runs ---

	(:test)
	function testMultipleDungeonRunsMaxRooms(logger as Test.Logger) as Boolean {
		setupSettings();

		for (var run = 0; run < 3; run++) {
			logger.debug("=== Dungeon run " + run + " ===");

			var size_x = 4;
			var size_y = 4;
			var dungeon = new Dungeon(size_x, size_y);
			dungeon.connectRoomsRandomly();
			$.Game.initMap(size_x, size_y);

			for (var j = 0; j < size_y; j++) {
				for (var i = 0; i < size_x; i++) {
					addRoomToDungeon(dungeon, i, j, logger);
				}
			}

			// Verify save/load cycle
			for (var j = 0; j < size_y; j++) {
				for (var i = 0; i < size_x; i++) {
					var room_name = $.SimUtil.getRoomName(i, j);
					var saved = Storage.getValue(room_name) as Dictionary?;
					Test.assertMessage(saved != null, "Run " + run + ": Room " + room_name + " should be in Storage");
					var loaded = Room.load(saved as Dictionary);
					Test.assertMessage(loaded != null, "Run " + run + ": Room " + room_name + " should load");
				}
			}

			dungeon.addStairs();
			dungeon.addMerchant();
			dungeon.addQuestGiver();

			cleanupStorage();
			logger.debug("Dungeon run " + run + " passed");
		}

		logger.debug("Multiple dungeon runs stress test passed");
		return true;
	}

	// --- Test: worst-case with all shapes at max size ---

	(:test)
	function testAllShapesAtMaxSize(logger as Test.Logger) as Boolean {
		setupSettings();

		var shapes = [
			ROOMSHAPE_RECTANGLE,
			ROOMSHAPE_L_SHAPE,
			ROOMSHAPE_T_SHAPE,
			ROOMSHAPE_PLUS,
			ROOMSHAPE_ROUNDED
		] as Array<RoomShape>;

		for (var i = 0; i < shapes.size(); i++) {
			var shape = shapes[i];
			logger.debug("Testing shape " + shape + " at max size");

			var room = Main.createRandomRoom(shape);

			Test.assertMessage(room != null, "Room with shape " + shape + " should be created");

			var map = room.getMap();
			Test.assertMessage(map != null, "Map should not be null for shape " + shape);

			room.freeMemory();
		}

		logger.debug("All shapes at max size passed");
		return true;
	}

	// --- Test: save/load integrity for a single max-size room ---

	(:test)
	function testSaveLoadIntegrityMaxRoom(logger as Test.Logger) as Boolean {
		setupSettings();

		var room = Main.createRandomRoom(ROOMSHAPE_RECTANGLE);
		Test.assertMessage(room != null, "Room should be created");

		var room_name = "stress_test_room";
		_room_names.add(room_name);
		var saved_data = room.save();
		Storage.setValue(room_name, saved_data);

		var loaded = Storage.getValue(room_name) as Dictionary?;
		Test.assertMessage(loaded != null, "Room should be in Storage");

		var loaded_room = Room.load(loaded as Dictionary);
		Test.assertMessage(loaded_room != null, "Room should load");

		Test.assertMessage(loaded_room.getSize()[0] == room.getSize()[0], "Size X should match");
		Test.assertMessage(loaded_room.getSize()[1] == room.getSize()[1], "Size Y should match");

		var orig_map = room.getMap();
		var loaded_map = loaded_room.getMap();
		Test.assertMessage(loaded_map.getXSize() == orig_map.getXSize(), "Map width should match");
		Test.assertMessage(loaded_map.getYSize() == orig_map.getYSize(), "Map height should match");

		var mismatches = 0;
		var w = orig_map.getXSize();
		var h = orig_map.getYSize();
		for (var x = 0; x < w; x++) {
			for (var y = 0; y < h; y++) {
				if (orig_map.getTile(x, y).type != loaded_map.getTile(x, y).type) {
					mismatches += 1;
				}
			}
		}
		Test.assertMessage(mismatches == 0, "Tile type mismatches: " + mismatches);

		logger.debug("Save/load integrity test passed (map " + w + "x" + h + ")");

		room.freeMemory();
		loaded_room.freeMemory();
		cleanupStorage();
		return true;
	}
}
