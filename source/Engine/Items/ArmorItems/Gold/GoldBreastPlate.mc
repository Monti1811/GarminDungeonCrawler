import Toybox.Lang;

class GoldBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1048;
		name = "Gold Breastplate";
		description = "A simple gold breastplate";
		value = 38;
		weight = 10;
		slot = CHEST;
		defense = 11;
		attribute_bonus = {
			:constitution => 8,
			:dexterity => -1
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_armor;
	}

	function deepcopy() as Item {
		var breastplate = new GoldBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
