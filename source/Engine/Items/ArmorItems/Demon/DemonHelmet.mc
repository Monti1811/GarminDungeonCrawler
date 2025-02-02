import Toybox.Lang;

class DemonHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1052;
		name = "Demon Helmet";
		description = "A simple demon helmet";
		value = 40;
		weight = 3;
		slot = HEAD;
		defense = 10;
		attribute_bonus = {
			:constitution => 9
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.demon_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new DemonHelmet();
		// ...existing code...
		return helmet;
	}

}
