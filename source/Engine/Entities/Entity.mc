import Toybox.Lang;
import Toybox.Application;

class Entity {
	var name as String = "Entity";
	var damage_received as Number = 0;

	function initialize() {
	}

	function getName() as String {
		return name;
	}

	function setName(name as String) {
		self.name = name;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.steel_axe;
	}

	function getSpriteRef() as Toybox.Graphics.BitmapReference {
		return $.Toybox.WatchUi.loadResource(getSprite());
	}

	function getSpriteOffset() as Point2D {
		return [0, 0];
	}

	function save() as Dictionary<PropertyKeyType, PropertyValueType> {
		var save_data = {};
		save_data["name"] = name;
		return save_data;
	}

	static function load(save_data as Dictionary<PropertyKeyType, PropertyValueType>) as Entity {
		var entity = new Entity();
		entity.name = save_data["name"] as String;
		return entity;
	}
}