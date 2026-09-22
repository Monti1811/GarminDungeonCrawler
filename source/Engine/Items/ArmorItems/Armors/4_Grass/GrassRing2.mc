import Toybox.Lang;

class GrassRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1045;
		name = "Corruption Ring";
		description = "A corrupted ring pulsing with dark overgrown energy.";
		value = 50;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 23;
		attribute_bonus = {
			:intelligence => 4,
			:charisma => 4,
			:luck => 2
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
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
