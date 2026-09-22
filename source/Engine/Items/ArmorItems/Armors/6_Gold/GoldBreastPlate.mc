import Toybox.Lang;

class GoldBreastPlate extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1061;
		name = "Gold Breastplate";
		description = "A radiant golden breastplate blessed by the gods.";
		value = 500;
		weight = 15;
		slot = CHEST;
		defense = 13;
		attribute_bonus = {
			:constitution => 10,
			:strength => 3,
			:dexterity => -5
		};
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_armor;
	}

	function deepcopy() as Item {
		var breastplate = new GoldBreastPlate();
		// ...existing code...
		return breastplate;
	}

}
