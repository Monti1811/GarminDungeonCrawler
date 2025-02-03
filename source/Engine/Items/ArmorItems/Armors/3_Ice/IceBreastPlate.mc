import Toybox.Lang;

class IceBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1031;
		name = "Ice Breastplate";
		description = "A ice breastplate";
		value = 100;
		weight = 10;
		slot = CHEST;
		defense = 10;
		attribute_bonus = {
			:constitution => 4,
			:wisdom => 4,
			:charisma => 1
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
