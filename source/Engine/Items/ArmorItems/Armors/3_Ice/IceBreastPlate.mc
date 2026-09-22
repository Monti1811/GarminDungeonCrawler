import Toybox.Lang;

class IceBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1031;
		name = "Ice Breastplate";
		description = "A chestplate of enchanted glacial ice, cold to the touch.";
		value = 100;
		weight = 10;
		slot = CHEST;
		defense = 22;
		attribute_bonus = {
			:constitution => 4,
			:wisdom => 4,
			:charisma => 1
		};
		element = ELEMENT_ICE;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
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
