import Toybox.Lang;

class GrassHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1034;
		name = "Grass Helmet";
		description = "A simple grass helmet";
		value = 25;
		weight = 3;
		slot = HEAD;
		defense = 7;
		attribute_bonus = {
			:constitution => 6
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
