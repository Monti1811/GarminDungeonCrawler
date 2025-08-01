import Toybox.Lang;
import Toybox.Application;

class Entity {
	var name as String = "Entity";
	var damage_received as Number = 0;
	var energy as Number = 100;
	var energy_per_turn as Number = 100;
	var guid as Number = 0;

	function initialize() {
	}

	function register() as Void {
		$.EntityManager.addEntity(self);
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

	function getEnergy() as Number {
		return energy;
	}

	function addEnergy(energy as Number) {
		self.energy += energy;
	}

	function doTurnEnergyDelta(delta as Number, min as Number, max as Number) as Boolean {
		self.energy = MathUtil.clamp(self.energy + delta, min, max);
		return true;
	}

	function onTurnDone() as Void {
		self.doTurnEnergyDelta(energy_per_turn, 0, 100);
	}

	function save() as Dictionary {
		var save_data = {};
		save_data["name"] = name;
		save_data["energy"] = energy;
		save_data["guid"] = guid;
		return save_data;
	}

	static function load(save_data as Dictionary) as Entity {
		var entity = new Entity();
		entity.onLoad(save_data);
		return entity;
	}

	function onLoad(save_data as Dictionary) as Void {
		name = save_data["name"] as String;
		if (save_data["guid"] != null) {
			guid = save_data["guid"] as Number;
			$.EntityManager.entities[guid] = self as Entity;
		}
		if (save_data["energy"] != null) {
			energy = save_data["energy"] as Number;
		}
	}
}