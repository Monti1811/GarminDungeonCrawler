import Toybox.Lang;

class BronzeRing1 extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1014;
		name = "Bronze Ring";
		description = "A bronze ring";
		slot = ACCESSORY;
		value = 13;
		weight = 0.1;
		defense = 4;
		attribute_bonus = {
			:constitution => 3,
			:wisdom => 3,
			:charisma => 3
		};
		defense_type = WISDOM;
	}

	function onEquipItem(player as Player) as Void {
		ArmorItem.onEquipItem(player);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.bronze_ring1;
	}
	
	function deepcopy() as Item {
		var ring = new BronzeRing1();
		// ...existing code...
		return ring;
	}

}
