import Toybox.Lang;

class WaterRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1055;
		name = "Obsidian Ring";
		description = "An obsidian ring";
		value = 50;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 5;
		attribute_bonus = {
			:intelligence => 4,
			:wisdom => 5
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.water_ring2;
	}
	
	function deepcopy() as Item {
		var ring = new WaterRing2();
		// ...existing code...
		return ring;
	}

}
