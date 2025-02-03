import Toybox.Lang;

class FireGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1022; 
		name = "Fire Gauntlets";
		description = "Some fire gauntlets";
		value = 50;
		weight = 1.5;
		slot = EITHER_HAND;
		defense = 7;
		attribute_bonus = {
			:charisma => 3,
			:strength => 3,
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.fire_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new FireGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
