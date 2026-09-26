import Toybox.Lang;

class BronzeRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1015;
		name = "Silver Ring";
		description = "A tarnished bronze ring with a faint protective ward.";
		slot = ACCESSORY;
		value = 13;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 6;
		attribute_bonus = {
			:intelligence => 4,
			:wisdom => 3
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.bronze_ring2;
	}
	
	function deepcopy() as Item {
		var ring = new BronzeRing2();
		// ...existing code...
		return ring;
	}

}
