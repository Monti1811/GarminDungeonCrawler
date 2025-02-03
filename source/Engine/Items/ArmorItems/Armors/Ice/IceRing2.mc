import Toybox.Lang;

class IceRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1033;
		name = "Glacierite Ring";
		description = "An glacierite ring";
		value = 50;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 5;
		attribute_bonus = {
			:intelligence => 3,
			:charisma => 4,
			:wisdom => 2
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_ring2;
	}
	
	function deepcopy() as Item {
		var ring = new IceRing2();
		// ...existing code...
		return ring;
	}

}
