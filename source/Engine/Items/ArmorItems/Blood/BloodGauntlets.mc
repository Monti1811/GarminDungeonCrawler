import Toybox.Lang;

class BloodGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1059;
		name = "Blood Gauntlets";
		description = "Simple blood gauntlets";
		value = 36;
		weight = 2;
		slot = EITHER_HAND;
		defense = 11;
		attribute_bonus = {
			:charisma => 10
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.blood_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new BloodGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
