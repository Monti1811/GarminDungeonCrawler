import Toybox.Lang;

class IceRing2 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1035;
		name = "Glacierite Ring";
		description = "A ring carved from deep glacier ice, radiating bitter cold.";
		value = 50;
		weight = 0.1;
		slot = ACCESSORY;
		defense = 5;
		attribute_bonus = {
			:intelligence => 3,
			:charisma => 4,
			:wisdom => 2
		};
		element = ELEMENT_ICE;
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
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
