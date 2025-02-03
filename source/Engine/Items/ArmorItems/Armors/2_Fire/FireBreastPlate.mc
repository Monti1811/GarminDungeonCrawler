import Toybox.Lang;

class FireBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1021;
		name = "Fire Breastplate";
		description = "A fire breastplate";
		value = 100;
		weight = 8;
		slot = CHEST;
		defense = 10;
		attribute_bonus = {
			:constitution => 4,
			:strength => 4,
		};
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.fire_armor;
	}

	function deepcopy() as Item {
		var breastplate = new FireBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
