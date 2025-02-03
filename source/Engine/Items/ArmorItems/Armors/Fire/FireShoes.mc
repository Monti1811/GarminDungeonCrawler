import Toybox.Lang;

class FireShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1019;
		name = "Fire Shoes";
		description = "Some fire shoes";
		value = 75;
		weight = 3;
		slot = FEET;
		defense = 7;
		attribute_bonus = {
			:dexterity => 3,
			:strength => 3
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
