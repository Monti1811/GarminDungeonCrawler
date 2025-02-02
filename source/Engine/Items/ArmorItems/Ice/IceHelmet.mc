import Toybox.Lang;

class IceHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1028;
		name = "Ice Helmet";
		description = "A simple ice helmet";
		value = 20;
		weight = 3;
		slot = HEAD;
		defense = 6;
		attribute_bonus = {
			:constitution => 5
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
		var helmet = new IceHelmet();
		// ...existing code...
		return helmet;
	}

}
