import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;


module SaveData {

	var saves as Dictionary = {};
	var chosen_save as String = "";
	const STORAGE_STRING as String = "save_data";

	var _save_data as Dictionary<PropertyKeyType, PropertyValueType> = {};

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

	public function loadFromMemory() {
		var save_data = Storage.getValue(chosen_save) as Dictionary<PropertyKeyType, PropertyValueType>?;
		if (save_data != null) {
			setSaveData(save_data);
		}
	}

	public function saveToMemory(data) {
		Storage.setValue(chosen_save, getSaveData());
		saves[chosen_save] = [data];
		saveSaves();
	}

	public function saveGame() as Void {
		var app = getApp();
		var player = app.getPlayer();
		var save_name = "save_" + player.getName() + "_" + player.getLevel().toString();
		chosen_save = save_name;
		var data = {
			"player" => player.save() as Dictionary<PropertyKeyType, PropertyValueType>,
			"level" => player.getLevel() as PropertyValueType,
			"dungeon" => app.getCurrentDungeon().save() as Dictionary<PropertyKeyType, PropertyValueType>
		} as Dictionary<PropertyKeyType, PropertyValueType>;
		Toybox.System.println("Saving game to " + save_name);
		Toybox.System.println("Data: " + data);
		_save_data = data;
		saveToMemory(data["level"]);
		_save_data = {};
	}

	public function loadGame(save as String) as Void {
		chosen_save = save;
		loadFromMemory();
		var app = getApp();
		var data = getSaveData();
		var player = Player.load(data["player"] as Dictionary<PropertyKeyType, PropertyValueType>);
		app.setPlayer(player);
		app.setCurrentDungeon(Dungeon.load(data["dungeon"] as Dictionary<PropertyKeyType, PropertyValueType>));
	}

	public function isEmpty() as Boolean {
		return _save_data.isEmpty();
	}

	public function loadSaves() {
		var save_data = Storage.getValue(STORAGE_STRING) as Dictionary<String, Array>?;
		if (save_data != null) {
			saves = save_data;
		}
	}

	public function saveSaves() {
		Storage.setValue(STORAGE_STRING, saves);
	}

	public function getSaveInfo(save as String) as String {
		var info = saves[save] as Array;
		return "Level " + info[0];
	}

	public function deleteSave(save as String) {
		var temp = Storage.getValue(save) as Dictionary;
		var dungeon_save_keys = temp["dungeon"]["rooms"] as Array<String>;
		for (var i = 0; i < dungeon_save_keys.size(); i++) {
			Storage.deleteValue(dungeon_save_keys[i]);
		}
		Storage.deleteValue(save);
		saves.remove(save);
		saveSaves();
	}

}