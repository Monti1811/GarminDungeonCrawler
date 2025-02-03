import Toybox.Lang;

class BloodRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1084; // Updated ID
		name = "Demon Blood Ring";
		description = "A demon blood ring";
		slot = ACCESSORY;
		value = 2500;
		weight = 0.1;
		defense = 7;
		attribute_bonus = {
			:constitution => 5,
			:strength => 10,
			
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.blood_ring1;
	}
	
	function deepcopy() as Item {
		var ring = new BloodRing1();
		// ...existing code...
		return ring;
	}

}
