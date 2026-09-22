import Toybox.Lang;

class GoldRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1065;
		name = "Amethyst Gold Ring";
		description = "A gold ring set with an amethyst that glows with holy light.";
		value = 30;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 36;
		attribute_bonus = {
			:intelligence => 9,
			:wisdom => 8
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_ring2;
	}
	
	function deepcopy() as Item {
		var ring = new GoldRing2();
		// ...existing code...
		return ring;
	}

}
