import Toybox.Lang;

class BloodBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1060;
		name = "Blood Breastplate";
		description = "A blood breastplate";
		value = 5000;
		weight = 8;
		slot = CHEST;
		defense = 40;
		attribute_bonus = {
			:constitution => 20,
			:strength => 5,
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.blood_armor;
	}

	function deepcopy() as Item {
		var breastplate = new BloodBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
