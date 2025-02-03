import Toybox.Lang;

class WaterGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1052;
		name = "Water Gauntlets";
		description = "Some water gauntlets";
		value = 50;
		weight = 2;
		slot = EITHER_HAND;
		defense = 7;
		attribute_bonus = {
			:charisma => 3,
			:intelligence => 3,
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.water_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new WaterGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
