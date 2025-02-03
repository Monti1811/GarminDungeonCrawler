import Toybox.Lang;

class SteelShield extends ArmorItem {
	
	function initialize() {
		ArmorItem.initialize();
		id = 1201;
		name = "Steel Shield";
		description = "A simple shield";
		value = 50;
		weight = 2.5;
		slot = LEFT_HAND;
		attribute_bonus = {
			:constitution => 3,
			:dexterity => -2
		};

		defense = 7;

	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.shield_steel;
	}

	function deepcopy() as Item {
		var shield = new SteelShield();
		shield.amount = amount;
		return shield;
	}
}