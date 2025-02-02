import Toybox.Lang;

class IceBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1030;
		name = "Ice Breastplate";
		description = "A simple ice breastplate";
		value = 22;
		weight = 10;
		slot = CHEST;
		defense = 8;
		attribute_bonus = {
			:constitution => 5,
			:dexterity => -1
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_armor;
	}

	function deepcopy() as Item {
		var breastplate = new IceBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
