import Toybox.Lang;

class DemonGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1072; 
		name = "Ice Gauntlets";
		description = "Gauntlets forged in hellfire that enhance demonic strength.";
		value = 500;
		weight = 3;
		slot = EITHER_HAND;
		defense = 9;
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
