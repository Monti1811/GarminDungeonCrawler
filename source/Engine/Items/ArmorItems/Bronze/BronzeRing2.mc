import Toybox.Lang;

class BronzeRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1015;
		name = "Amethyst Bronze Ring";
		description = "A simple amethyst bronze ring";
		value = 9;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 2;
		attribute_bonus = {
			:intelligence => 4,
			:wisdom => 3
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
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
