import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;


module SaveData {

	var saves as Dictionary = {};
	var chosen_save as String = "";
	var current_save_num = 0;
	const STORAGE_STRING as String = "save_data";

	var _save_data as Dictionary<PropertyKeyType, PropertyValueType> = {};

	// Compendium tracking
	var discovered_enemies as Dictionary<Number, Boolean> = {};
	var discovered_items as Dictionary<Number, Boolean> = {};


	public function init() as Void {
		loadSaves();
		var save_num = Storage.getValue("save_num") as Number?;
		if (save_num != null) {
			current_save_num = save_num;
		}
	}

	//! Save a value
	//! @param key The key
	//! @param value The value
	public function save(key as PropertyKeyType, value as PropertyValueType) {
		_save_data[key] = value;
	}

	//! Load a value
	//! @param key The key
	//! @return The value
	public function load(key as PropertyKeyType) as PropertyValueType {
		return _save_data[key];
	}

	//! Get the entire save data
	//! @return The save data
	public function getSaveData() as Dictionary<PropertyKeyType, PropertyValueType> {
		return _save_data;
	}

	//! Set the entire save data
	//! @param save_data The save data
	public function setSaveData(save_data as Dictionary<PropertyKeyType, PropertyValueType>) {
		_save_data = save_data;
	}

	//! Clear the save data
	public function clear() {
		_save_data = {};
	}

	public function clearValues() {
		clear();
		saves = {};
		current_save_num = 0;
		discovered_enemies = {};
		discovered_items = {};
	}

	public function loadFromMemory() {
		var save_data = Storage.getValue(chosen_save) as Dictionary<PropertyKeyType, PropertyValueType>?;
		if (save_data != null) {
			setSaveData(save_data);
		}
	}

	public function saveToMemory(data) {
		Storage.setValue(chosen_save, getSaveData());
		saves[chosen_save] = data;
		saveSaves();
	}

	// Copy all real room keys from the save dict into buffer keys (real keys are kept)
	function loadRoomsToBuffer(data as Dictionary) as Void {
		var dungeon_data = data["dungeon"] as Dictionary?;
		if (dungeon_data == null) {
			return;
		}
		var rooms = dungeon_data["rooms"] as Array<String?>?;
		if (rooms == null) {
			return;
		}
		for (var i = 0; i < rooms.size(); i++) {
			var real_name = rooms[i];
			if (real_name == null) {
				continue;
			}
			var room_data = Storage.getValue(real_name) as Dictionary?;
			if (room_data != null) {
				var buffer_name = $.SimUtil.toBufferRoomName(real_name);
				Storage.setValue(buffer_name, room_data);
			}
		}
	}

	// Copy all buffer room keys to real keys for the current dungeon
	function saveRoomsFromBuffer(dungeon as Dungeon) as Void {
		var rooms = dungeon.getRooms();
		for (var i = 0; i < rooms.size(); i++) {
			for (var j = 0; j < rooms[i].size(); j++) {
				var buffer_name = rooms[i][j];
				if (buffer_name == null) {
					continue;
				}
				var room_data = Storage.getValue(buffer_name) as Dictionary?;
				if (room_data != null) {
					var real_name = $.SimUtil.toRealRoomName(buffer_name);
					Storage.setValue(real_name, room_data);
				}
			}
		}
	}

	public function saveGame() as Void {
		var player = $.Game.getPlayer();
		if (Storage.getValue(chosen_save) == null) {
			Storage.setValue("save_num", current_save_num);
		}
		$.Game.updateTimePlayed(Toybox.Time.now());
		var dungeon = $.Game.getDungeon();
		if (dungeon == null) {
			return;
		}
		var data = {
			"player" => player.save(),
			"level" => player.getLevel(),
			"dungeon" => dungeon.save(),
			"game" => $.Game.save(),
			"entitymanager" => $.EntityManager.save(),
			"quests" => $.Quests.save(),
			"discovered_enemies" => discovered_enemies.keys(),
			"discovered_items" => discovered_items.keys(),
			"stepgate" => StepGate.save(),
		} as Dictionary<PropertyKeyType, PropertyValueType>;
		saveRoomsFromBuffer(dungeon);
		DebugLogger.println("Saving game to " + chosen_save);
		DebugLogger.println("Data: " + data);
		_save_data = data;
		var playerData = data["player"] as Dictionary<PropertyKeyType, PropertyValueType>;
		var gameData = data["game"] as Dictionary<PropertyKeyType, PropertyValueType>;
		var data_to_show = [
			playerData["name"] as PropertyValueType,
			data["level"] as PropertyValueType,
			gameData["depth"] as PropertyValueType,
			gameData["time_played"] as PropertyValueType,
			playerData["id"] as PropertyValueType
		] as Array<PropertyValueType>;
		saveToMemory(data_to_show);
		_save_data = {};
	}

	// Convert real room names in the loaded game map to buffer names for play
	function convertMapNamesToBuffer() as Void {
		var map = $.Game.map;
		if (map.size() == 0 || map[0].size() == 0 || map[0][0] == null) {
			return;
		}
		for (var i = 0; i < map.size(); i++) {
			for (var j = 0; j < map[i].size(); j++) {
				var room = map[i][j];
				if (room != null && room[0] != null) {
					room[0] = $.SimUtil.toBufferRoomName(room[0] as String);
				}
			}
		}
	}

	public function loadGame(save as String) as Void {
		chosen_save = save;
		loadFromMemory();
		var data = getSaveData();
		// Copy real room keys to buffer before loading dungeon (real keys are kept)
		loadRoomsToBuffer(data);
		var player_data = data["player"] as Dictionary;
		var player_id = player_data["id"] as Number;
		$.Game.init(player_id);
		var player = Player.load(player_data);
		$.Game.setPlayer(player);
		$.Game.setDungeon(Dungeon.load(data["dungeon"] as Dictionary));
		$.Game.load(data["game"] as Dictionary);
		// Map was loaded with real names; convert to buffer for play
		convertMapNamesToBuffer();
		$.Quests.load(data["quests"] as Dictionary?);
		$.EntityManager.load(data["entitymanager"] as Dictionary);
		StepGate.load(data["stepgate"] as Dictionary?);

		// Load compendium data
		discovered_enemies = {};
		discovered_items = {};
		var enemy_ids = data["discovered_enemies"] as Array?;
		if (enemy_ids != null) {
			for (var i = 0; i < enemy_ids.size(); i++) {
				discovered_enemies[enemy_ids[i]] = true;
			}
		}
		var item_ids = data["discovered_items"] as Array?;
		if (item_ids != null) {
			for (var i = 0; i < item_ids.size(); i++) {
				discovered_items[item_ids[i]] = true;
			}
		}
	}

	public function isEmpty() as Boolean {
		return _save_data.isEmpty();
	}

	public function loadSaves() {
		var save_data = Storage.getValue(STORAGE_STRING) as Dictionary?;
		if (save_data != null) {
			saves = save_data;
		}
	}

	public function saveSaves() {
		Storage.setValue(STORAGE_STRING, saves);
	}

	public function getSaveInfo(save as String) as Array<String?> {
		var info = saves[save] as Array;
		var hours = info[3].toNumber() / 3600;
		var minutes = (info[3].toNumber() % 3600) / 60;
		var id = info.size() > 4 ? info[4] : null;
		if (minutes < 10) {
			minutes = "0" + minutes;
		}
		return [
			info[0], // Player Name
			"Level " + info[1] + " Depth: " + info[2] + " Time: " + hours + ":" + minutes,
			id // Player ID
		];
	}

	// Delete room keys listed in a save dict + the save key itself (no buffer, no probing)
	function deleteRoomsInDict(dungeon_data as Dictionary?) as Void {
		if (dungeon_data == null) {
			return;
		}
		var rooms = dungeon_data["rooms"] as Array<String?>?;
		if (rooms == null) {
			return;
		}
		for (var i = 0; i < rooms.size(); i++) {
			if (rooms[i] != null) {
				Storage.deleteValue(rooms[i]);
			}
		}
	}

	public function deleteDungeonSave() as Void {
		var data = Storage.getValue(chosen_save) as Dictionary?;
		if (data != null) {
			deleteRoomsInDict(data["dungeon"] as Dictionary?);
		}
		Storage.deleteValue(chosen_save);
	}

	public function deleteSave(save as String) {
		var data = Storage.getValue(save) as Dictionary?;
		if (data != null) {
			deleteRoomsInDict(data["dungeon"] as Dictionary?);
		}
		Storage.deleteValue(save);
		saves.remove(save);
		saveSaves();
	}

}
