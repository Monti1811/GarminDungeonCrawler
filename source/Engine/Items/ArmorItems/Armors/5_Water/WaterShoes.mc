import Toybox.Lang;

class WaterShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1053;
		name = "Water Shoes";
		description = "A simple water shoes";
		value = 75;
		weight = 3;
		slot = FEET;
		defense = 8;
		attribute_bonus = {
			:dexterity => 3,
			:intelligence => 3,
		};
		defense_type = CHARISMA;
	}

	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.water_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new WaterShoes();
		// ...existing code...
		return shoes;
	}

}
