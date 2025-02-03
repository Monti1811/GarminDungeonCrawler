import Toybox.Lang;

class GoldBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1061;
		name = "Gold Breastplate";
		description = "A gold breastplate";
		value = 500;
		weight = 15;
		slot = CHEST;
		defense = 20;
		attribute_bonus = {
			:constitution => 10,
			:strength => 3,
			:dexterity => -5
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
