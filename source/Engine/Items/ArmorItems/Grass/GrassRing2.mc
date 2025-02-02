import Toybox.Lang;

class GrassRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1033;
		name = "Amethyst Grass Ring";
		description = "A simple amethyst grass ring";
		value = 22;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 5;
		attribute_bonus = {
			:intelligence => 7,
			:wisdom => 6
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
