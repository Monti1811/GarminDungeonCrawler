import Toybox.Lang;

class GrassBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1041;
		name = "Grass Breastplate";
		description = "A grass breastplate";
		value = 100;
		weight = 8;
		slot = CHEST;
		defense = 10;
		attribute_bonus = {
			:constitution => 3,
			:charisma => 3,
			:luck => 2,
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
