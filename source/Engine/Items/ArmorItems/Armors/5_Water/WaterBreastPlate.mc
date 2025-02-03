import Toybox.Lang;

class WaterBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1051;
		name = "Water Breastplate";
		description = "A water breastplate";
		value = 100;
		weight = 8;
		slot = CHEST;
		defense = 10;
		attribute_bonus = {
			:constitution => 4,
			:intelligence => 4
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.water_armor;
	}

	function deepcopy() as Item {
		var breastplate = new WaterBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
