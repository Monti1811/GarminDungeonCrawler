import Toybox.Lang;

class IceHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1030;
		name = "Ice Helmet";
		description = "An ice helmet, it's a bit cold";
		value = 70;
		weight = 3;
		slot = HEAD;
		defense = 7;
		attribute_bonus = {
			:constitution => 3,
			:wisdom => 3,
			:luck => 1
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
