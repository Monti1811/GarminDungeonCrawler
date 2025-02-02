import Toybox.Lang;

class GrassBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1036;
		name = "Grass Breastplate";
		description = "A simple grass breastplate";
		value = 28;
		weight = 10;
		slot = CHEST;
		defense = 9;
		attribute_bonus = {
			:constitution => 6,
			:dexterity => -1
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.grass_armor;
	}

	function deepcopy() as Item {
		var breastplate = new GrassBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
