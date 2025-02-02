import Toybox.Lang;

class GrassGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1035;
		name = "Grass Gauntlets";
		description = "Simple grass gauntlets";
		value = 20;
		weight = 2;
		slot = EITHER_HAND;
		defense = 7;
		attribute_bonus = {
			:charisma => 6
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.grass_gauntlets;
	}
	
	function deepcopy() as Item {
		var gauntlets = new GrassGauntlets();
		// ...existing code...
		return gauntlets;
	}

}
