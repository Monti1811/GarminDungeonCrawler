import Toybox.Lang;

class BloodBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1060;
		name = "Blood Breastplate";
		description = "A simple blood breastplate";
		value = 48;
		weight = 10;
		slot = CHEST;
		defense = 13;
		attribute_bonus = {
			:constitution => 10,
			:dexterity => -1
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
