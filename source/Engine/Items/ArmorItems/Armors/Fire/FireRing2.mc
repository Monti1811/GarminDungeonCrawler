import Toybox.Lang;

class FireRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1021;
		name = "Tourmaline Ring";
		description = "A tourmaline ring";
		value = 50;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 3;
		attribute_bonus = {
			:intelligence => 5,
			:constitution => 4
		};
		defense_type = WISDOM;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.fire_ring2;
	}
	
	function deepcopy() as Item {
		var ring = new FireRing2();
		// ...existing code...
		return ring;
	}

}
