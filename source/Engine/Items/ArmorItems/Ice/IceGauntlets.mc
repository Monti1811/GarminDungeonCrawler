import Toybox.Lang;

class IceGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1029;
		name = "Ice Gauntlets";
		description = "Simple ice gauntlets";
		value = 16;
		weight = 2;
		slot = EITHER_HAND;
		defense = 6;
		attribute_bonus = {
			:charisma => 5
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new IceGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
