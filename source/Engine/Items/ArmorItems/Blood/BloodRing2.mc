import Toybox.Lang;

class BloodRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1051; // TODO - unique ID for the item
		name = "Blood Magic Ring";
		description = "A blood magic ring";
		slot = ACCESSORY;
		value = 2500;
		weight = 0.1;
		defense = 7;
		attribute_bonus = {
			:constitution => 5,
			:intelligence => 10,
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.blood_ring2;
	}
	
	function deepcopy() as Item {
		var ring = new BloodRing2();
		// ...existing code...
		return ring;
	}

}
