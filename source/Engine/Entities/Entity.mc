import Toybox.Lang;
import Toybox.Application;

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

	static function onLoad(save_data as Dictionary<PropertyKeyType, PropertyValueType>) as Entity {
		var entity = new Entity();
		entity.name = save_data["name"] as String;
		return entity;
	}
}