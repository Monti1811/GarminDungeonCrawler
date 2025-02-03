import Toybox.Lang;

class WaterHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1028;
		name = "Water Helmet";
		description = "An water helmet, very refreshing";
		value = 70;
		weight = 3;
		slot = HEAD;
		defense = 7;
		attribute_bonus = {
			:constitution => 3,
			:intelligence => 3
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new WaterHelmet();
		// ...existing code...
		return helmet;
	}

}
