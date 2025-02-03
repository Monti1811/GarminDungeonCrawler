import Toybox.Lang;

class IceShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1033;
		name = "Ice Shoes";
		description = "A simple ice shoes";
		value = 75;
		weight = 3;
		slot = FEET;
		defense = 7;
		attribute_bonus = {
			:dexterity => 3,
			:charisma => 3,
			:luck => 1
		};
		defense_type = CHARISMA;
	}

	
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new IceShoes();
		// ...existing code...
		return shoes;
	}

}
