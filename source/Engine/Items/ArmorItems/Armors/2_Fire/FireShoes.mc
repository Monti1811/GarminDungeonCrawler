import Toybox.Lang;

class FireShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1023;
		name = "Fire Shoes";
		description = "Boots that smolder with each step, leaving embers in their wake.";
		value = 75;
		weight = 3;
		slot = FEET;
		defense = 15;
		attribute_bonus = {
			:dexterity => 3,
			:strength => 3
		};
		element = ELEMENT_FIRE;
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
