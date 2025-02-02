import Toybox.Lang;

class GrassShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1031;
		name = "Grass Shoes";
		description = "A simple grass shoes";
		value = 25;
		weight = 3;
		slot = FEET;
		defense = 7;
		attribute_bonus = {
			:dexterity => 6
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.grass_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new GrassShoes();
		// ...existing code...
		return shoes;
	}

}
