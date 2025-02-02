import Toybox.Lang;

class DemonGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1029; // TODO: Set the correct ID
		name = "Ice Gauntlets";
		description = "Some demon gauntlets, forged in the fires of hell, and imbued with the power of the underworld.";
		value = 500;
		weight = 3;
		slot = EITHER_HAND;
		defense = 15;
		attribute_bonus = {
			:charisma => 10,
			:strength => 5,
			:intelligence => -5,
			:wisdom => -5,
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.demon_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new DemonGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
