import Toybox.Lang;

class Entity {
	var name as String = "Entity";

	function initialize() {
	}

	function getName() as String {
		return name;
	}

	function setName(name as String) {
		self.name = name;
	}

	function onSave() as Dictionary<PropertyKeyType, PropertyValueType> {
		var save_data = {};
		save_data["name"] = name;
		return save_data;
	}

	function onLoad(save_data as Dictionary<PropertyKeyType, PropertyValueType>) as Void {
		name = save_data["name"] as String;
	}
}