import Toybox.Lang;

class GrassHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1034;
		name = "Grass Helmet";
		description = "A simple grass helmet";
		value = 70;
		weight = 3;
		slot = HEAD;
		defense = 7;
		attribute_bonus = {
			:constitution => 2,
			:charisma => 2,
			:luck => 2,
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.grass_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new GrassHelmet();
		// ...existing code...
		return helmet;
	}

}
