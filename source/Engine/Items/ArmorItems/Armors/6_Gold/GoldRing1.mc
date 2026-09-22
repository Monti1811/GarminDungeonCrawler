import Toybox.Lang;

class GoldRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1064;
		name = "Gold Ring";
		description = "A golden band that hums with sacred energy.";
		slot = ACCESSORY;
		value = 28;
		weight = 0.1;
		defense = 42;
		attribute_bonus = {
			:constitution => 8,
			:wisdom => 8,
			:charisma => 8
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_ring1;
	}
	
	function deepcopy() as Item {
		var ring = new GoldRing1();
		// ...existing code...
		return ring;
	}

}
