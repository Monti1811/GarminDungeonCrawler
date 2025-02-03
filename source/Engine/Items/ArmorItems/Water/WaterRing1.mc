import Toybox.Lang;

class WaterRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1032;
		name = "Sapphire Ring";
		description = "A sapphire ring";
		slot = ACCESSORY;
		value = 50;
		weight = 0.1;
		defense = 5;
		attribute_bonus = {
			:constitution => 4,
			:intelligence => 5,
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.water_ring1;
	}
	
	function deepcopy() as Item {
		var ring = new WaterRing1();
		// ...existing code...
		return ring;
	}

}
