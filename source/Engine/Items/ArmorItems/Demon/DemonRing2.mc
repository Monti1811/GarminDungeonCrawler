import Toybox.Lang;

class DemonRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1051;
		name = "Amethyst Demon Ring";
		description = "A simple amethyst demon ring";
		value = 34;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 8;
		attribute_bonus = {
			:intelligence => 10,
			:wisdom => 9
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
