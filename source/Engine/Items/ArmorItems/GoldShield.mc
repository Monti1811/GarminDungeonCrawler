import Toybox.Lang;

class GoldShield extends ArmorItem {
	
	function initialize() {
		ArmorItem.initialize();
		id = 1012;
		name = "Gold Shield";
		description = "A golden shield";
		value = 500;
		weight = 5;
		slot = LEFT_HAND;
		attribute_bonus = {
			:constitution => 6,
			:dexterity => -2,
			:luck => 5
		};

		defense = 10;

	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.shield_gold
	}

	function deepcopy() as Item {
		var shield = new GoldShield();
		shield.amount = amount;
		return shield;
	}
}