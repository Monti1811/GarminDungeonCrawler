import Toybox.Lang;

class BloodShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1049;
		name = "Demon Shoes";
		description = "Some demon shoes";
		value = 1200;
		weight = 3;
		slot = FEET;
		defense = 15;
		attribute_bonus = {
			:dexterity => 10,
			:strength => 7
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.blood_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new BloodShoes();
		// ...existing code...
		return shoes;
	}

}
