import Toybox.Lang;

class DemonShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1049;
		name = "Demon Shoes";
		description = "A simple demon shoes";
		value = 40;
		weight = 3;
		slot = FEET;
		defense = 10;
		attribute_bonus = {
			:dexterity => 9
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.demon_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new DemonShoes();
		// ...existing code...
		return shoes;
	}

}
