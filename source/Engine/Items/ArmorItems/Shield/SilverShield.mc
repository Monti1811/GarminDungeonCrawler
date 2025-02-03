import Toybox.Lang;

class SilverShield extends ArmorItem {
	
	function initialize() {
		ArmorItem.initialize();
		id = 1202;
		name = "Silver Shield";
		description = "A silver shield";
		value = 100;
		weight = 3.5;
		slot = LEFT_HAND;
		attribute_bonus = {
			:constitution => 4,
			:dexterity => -2
		};

		defense = 10;

	}
	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.shield_silver;
	}

	function deepcopy() as Item {
		var shield = new SilverShield();
		shield.amount = amount;
		return shield;
	}
}