import Toybox.Lang;

class FireShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1019;
		name = "Fire Shoes";
		description = "A simple fire shoes";
		value = 15;
		weight = 3;
		slot = FEET;
		defense = 5;
		attribute_bonus = {
			:dexterity => 4
		};
		defense_type = CHARISMA;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.fire_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new FireShoes();
		// ...existing code...
		return shoes;
	}

}
