import Toybox.Lang;

class DemonBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1018; //TODO: Change this to a unique ID
		name = "Demon Breastplate";
		description = "A demon breastplate, forged in the fires of hell.";
		value = 2000;
		weight = 20;
		slot = CHEST;
		defense = 40;
		attribute_bonus = {
			:constitution => 15,
			:strength => 5,
			:intelligence => -5,
			:wisdom => -5,
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.demon_armor;
	}

	function deepcopy() as Item {
		var breastplate = new DemonBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
