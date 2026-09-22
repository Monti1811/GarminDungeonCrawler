import Toybox.Lang;

class GrassGauntlets extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1042;
		name = "Grass Gauntlets";
		description = "Light grass-woven gauntlets for nimble fighters.";
		value = 50;
		weight = 1.5;
		slot = EITHER_HAND;
		defense = 30;
		attribute_bonus = {
			:charisma => 5,
			:luck => 1,
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
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
