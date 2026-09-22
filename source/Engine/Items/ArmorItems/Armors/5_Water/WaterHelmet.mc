import Toybox.Lang;

class WaterHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1050;
		name = "Water Helmet";
		description = "A helm filled with the power of the raging sea.";
		value = 70;
		weight = 3;
		slot = HEAD;
		defense = 38;
		attribute_bonus = {
			:constitution => 3,
			:intelligence => 3
		};
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.water_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new WaterHelmet();
		// ...existing code...
		return helmet;
	}

}
