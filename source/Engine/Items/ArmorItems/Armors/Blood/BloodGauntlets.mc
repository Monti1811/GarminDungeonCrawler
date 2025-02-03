import Toybox.Lang;

class BloodGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1059;
		name = "Blood Gauntlets";
		description = "Some blood gauntlets, they are red and bloody looking";
		value = 2000;
		weight = 2;
		slot = EITHER_HAND;
		defense = 20;
		attribute_bonus = {
			:charisma => 10,
			:constitution => 5,
			:strength => 5,
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
