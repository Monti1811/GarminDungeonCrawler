import Toybox.Lang;

class GoldGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1047;
		name = "Gold Gauntlets";
		description = "Simple gold gauntlets";
		value = 28;
		weight = 2;
		slot = EITHER_HAND;
		defense = 9;
		attribute_bonus = {
			:charisma => 8
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new GoldGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
