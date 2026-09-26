import Toybox.Lang;

class FireRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1024;
		name = "Mirror Ring";
		description = "A ring set with a smoldering ember that never cools.";
		slot = ACCESSORY;
		value = 50;
		weight = 0.1;
		defense = 13;
		attribute_bonus = {
			:constitution => 4,
			:wisdom => 1,
			:strength => 4
		};
		element = ELEMENT_FIRE;
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
