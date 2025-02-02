import Toybox.Lang;

class BronzeGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1017;
		name = "Bronze Gauntlets";
		description = "Simple bronze gauntlets";
		value = 8;
		weight = 2;
		slot = EITHER_HAND;
		defense = 4;
		attribute_bonus = {
			:charisma => 3
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.bronze_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new BronzeGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
