import Toybox.Lang;

class BloodBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1081; // Updated ID
		name = "Blood Breastplate";
		description = "A chestplate encrusted with dried blood that never washes away.";
		value = 5000;
		weight = 8;
		slot = CHEST;
		defense = 65;
		attribute_bonus = {
			:constitution => 20,
			:strength => 5,
		};
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
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
