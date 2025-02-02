import Toybox.Lang;

class GoldHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1046;
		name = "Gold Helmet";
		description = "A simple gold helmet";
		value = 35;
		weight = 3;
		slot = HEAD;
		defense = 9;
		attribute_bonus = {
			:constitution => 8
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new GoldHelmet();
		// ...existing code...
		return helmet;
	}

}
