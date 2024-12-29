import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;


module SaveData {

	var saves as Dictionary<String, Array<String>> = {};
	var chosen_save as String = "";
	const STORAGE_STRING as String = "save_data";

	var _save_data as Dictionary<PropertyKeyType, PropertyValueType> = {};

	//! Constructor
	public function initialize() {
		_save_data = {};
		self.loadSaves();
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

	public function saveToMemory() {
		Storage.setValue(chosen_save, getSaveData());
		saves[chosen_save] = [getApp().getPlayer().getLevel().toString()];
		saveSaves();
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

	public function getSaves() as Array<String> {
		return saves.keys();
	}

}