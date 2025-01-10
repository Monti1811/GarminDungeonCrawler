import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;


module SaveData {

	var saves as Dictionary = {};
	var chosen_save as String = "";
	var current_save_num = 0;
	const STORAGE_STRING as String = "save_data";

	var _save_data as Dictionary<PropertyKeyType, PropertyValueType> = {};


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

	public function saveGame() as Void {
		var app = getApp();
		var player = app.getPlayer();
		if (Storage.getValue(chosen_save) == null) {
			Storage.setValue("save_num", current_save_num);
		}
		player.updateTimePlayed(Toybox.Time.now());
		var data = {
			"player" => player.save() as Dictionary<PropertyKeyType, PropertyValueType>,
			"level" => player.getLevel() as PropertyValueType,
			"dungeon" => app.getCurrentDungeon().save() as Dictionary<PropertyKeyType, PropertyValueType>
		} as Dictionary<PropertyKeyType, PropertyValueType>;
		Toybox.System.println("Saving game to " + chosen_save);
		Toybox.System.println("Data: " + data);
		_save_data = data;
		var playerData = data["player"] as Dictionary<PropertyKeyType, PropertyValueType>;
		var data_to_show = [
			playerData["name"], 
			data["level"], 
			playerData["run"], 
			playerData["time_played"]
		] as Array<PropertyValueType>;
		saveToMemory(data_to_show);
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

	public function getSaveInfo(save as String) as Array<String> {
		var info = saves[save] as Array;
		var hours = info[3].toNumber() / 3600;
		var minutes = (info[3].toNumber() % 3600) / 60;
		if (minutes < 10) {
			minutes = "0" + minutes;
		}
		return [
			info[0], 
			"Level " + info[1] + " Depth: " + info[2] + " Time played: " + hours + ":" + minutes
		];
	}

	public function deleteSave(save as String) {
		var temp = Storage.getValue(save) as Dictionary;
		var dungeon_save_keys = (temp["dungeon"] as Dictionary)["rooms"] as Array<String>;
		for (var i = 0; i < dungeon_save_keys.size(); i++) {
			Storage.deleteValue(dungeon_save_keys[i]);
		}
		Storage.deleteValue(save);
		saves.remove(save);
		saveSaves();
	}

}