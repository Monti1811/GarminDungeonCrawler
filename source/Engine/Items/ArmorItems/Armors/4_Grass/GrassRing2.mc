import Toybox.Lang;

class GrassRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1045;
		name = "Corruption Ring";
		description = "A corruption ring";
		value = 50;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 5;
		attribute_bonus = {
			:intelligence => 4,
			:charisma => 4,
			:luck => 2
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.grass_ring2;
	}
	
	function deepcopy() as Item {
		var ring = new GrassRing2();
		// ...existing code...
		return ring;
	}

}
