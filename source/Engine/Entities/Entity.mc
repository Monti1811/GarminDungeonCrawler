import Toybox.Lang;
import Toybox.Application;

class Entity {
	var name as String = "Entity";
	var damage_received as Number = 0;
	var energy as Number = 100;
	var energy_per_turn as Number = 100;
	var guid as Number = 0;
	var elemental_effects as Dictionary<ElementType, Dictionary<Symbol, Number>> = {};

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
		applyElementalTurnEffects();
	}

	function getElementalResistance(element as ElementType) as Float {
		return 0.0;
	}

	function applyElementalEffect(element as ElementType, power as Number, duration as Number) as Void {
		if (element == ELEMENT_NONE) {
			return;
		}
		var resistance = getElementalResistance(element);
		var adjusted_power = MathUtil.floor(power * (1.0 - resistance), 0);
		if (adjusted_power <= 0 || duration <= 0) {
			return;
		}
		elemental_effects[element] = {
			:type => element,
			:power => adjusted_power,
			:turns => duration
		};
	}

	function applyElementalTurnEffects() as Void {
		if (elemental_effects.size() == 0) {
			return;
		}
		var keys = elemental_effects.keys();
		for (var i = 0; i < keys.size(); i++) {
			var element = keys[i] as ElementType;
			var effect = elemental_effects[element];
			if (effect == null) {
				continue;
			}
			switch (effect[:type]) {
				case ELEMENT_FIRE:
					applyPeriodicDamage(effect[:power], ELEMENT_FIRE);
					break;
				case ELEMENT_ICE:
					self.doTurnEnergyDelta(-effect[:power], 0, 100);
					break;
				default:
					break;
			}
			effect[:turns] -= 1;
			if (effect[:turns] <= 0) {
				elemental_effects.remove(element);
			} else {
				elemental_effects[element] = effect;
			}
		}
	}

	function applyPeriodicDamage(amount as Number, element as ElementType) as Void {
		var dmg = MathUtil.ceil(amount, 0);
		if (dmg <= 0) {
			return;
		}
		if (self instanceof Player) {
			var player = self as Player;
			player.takeDamage(dmg, null);
		} else if (self instanceof Enemy) {
			var enemy = self as Enemy;
			enemy.takeDamage(dmg, null);
		}
	}

	function getElementalEffect(element as ElementType) as Dictionary<Symbol, Number>? {
		return elemental_effects[element];
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