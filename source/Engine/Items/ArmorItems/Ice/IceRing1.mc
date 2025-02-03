import Toybox.Lang;

class IceRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1032;
		name = "Mirror Ring";
		description = "A mirror ring";
		slot = ACCESSORY;
		value = 50;
		weight = 0.1;
		defense = 5;
		attribute_bonus = {
			:constitution => 1,
			:charisma => 6,
			:wisdom => 3,
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.ice_ring1;
	}
	
	function deepcopy() as Item {
		var ring = new IceRing1();
		// ...existing code...
		return ring;
	}

}
