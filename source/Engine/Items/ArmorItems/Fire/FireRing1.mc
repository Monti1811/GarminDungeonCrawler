import Toybox.Lang;

class FireRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1020;
		name = "Fire Ring";
		description = "A simple fire ring";
		slot = ACCESSORY;
		value = 12;
		weight = 0.1;
		defense = 5;
		attribute_bonus = {
			:constitution => 4,
			:wisdom => 4,
			:charisma => 4
		};
		defense_type = WISDOM;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.fire_ring1;
	}
	
	function deepcopy() as Item {
		var ring = new FireRing1();
		// ...existing code...
		return ring;
	}

}
