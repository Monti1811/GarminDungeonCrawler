import Toybox.Lang;

class BronzeBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1011; // Updated ID
		name = "Bronze Breastplate";
		description = "A worn bronze chestplate, light but reliable.";
		value = 25;
		weight = 12;
		slot = CHEST;
		defense = 8;
		attribute_bonus = {
			:constitution => 3,
			:dexterity => -1
		};
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.bronze_armor;
	}

	function deepcopy() as Item {
		var breastplate = new BronzeBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
