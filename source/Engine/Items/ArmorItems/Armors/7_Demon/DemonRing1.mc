import Toybox.Lang;

class DemonRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1074;
		name = "Demon Ring";
		description = "A simple demon ring";
		slot = ACCESSORY;
		value = 700;
		weight = 0.1;
		defense = 7;
		attribute_bonus = {
			:constitution => 5,
			:strength => 7,
			:wisdom => -5,
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.demon_ring1;
	}
	
	function deepcopy() as Item {
		var ring = new DemonRing1();
		// ...existing code...
		return ring;
	}

}
