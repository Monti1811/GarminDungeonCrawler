import Toybox.Lang;

class WaterShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1037;
		name = "Water Shoes";
		description = "A simple water shoes";
		value = 30;
		weight = 3;
		slot = FEET;
		defense = 8;
		attribute_bonus = {
			:dexterity => 7
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
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
