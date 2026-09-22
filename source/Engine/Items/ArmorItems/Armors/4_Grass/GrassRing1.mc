import Toybox.Lang;

class GrassRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1044;
		name = "Grass Ring";
		description = "A delicate ring woven from magic-infused grass blades.";
		slot = ACCESSORY;
		value = 50;
		weight = 0.1;
		defense = 5;
		attribute_bonus = {
			:constitution => 2,
			:charisma => 6,
			:luck => 2,
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.grass_ring1;
	}
	
	function deepcopy() as Item {
		var ring = new GrassRing1();
		// ...existing code...
		return ring;
	}

}
