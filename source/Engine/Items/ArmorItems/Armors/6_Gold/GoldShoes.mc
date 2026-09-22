import Toybox.Lang;

class GoldShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1063;
		name = "Gold Shoes";
		description = "Golden boots that gleam with each step, light as a prayer.";
		value = 35;
		weight = 3;
		slot = FEET;
		defense = 7;
		attribute_bonus = {
			:dexterity => 8
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new GoldShoes();
		// ...existing code...
		return shoes;
	}

}
