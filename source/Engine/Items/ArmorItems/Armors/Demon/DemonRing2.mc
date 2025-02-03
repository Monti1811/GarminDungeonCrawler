import Toybox.Lang;

class DemonRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1051;
		name = "Death Ring";
		description = "A ring showing the skull of a demon";
		value = 700;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 7;
		attribute_bonus = {
			:intelligence => 5,
			:strength => 7,
			:wisdom => -5
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.demon_ring2;
	}
	
	function deepcopy() as Item {
		var ring = new DemonRing2();
		// ...existing code...
		return ring;
	}

}
