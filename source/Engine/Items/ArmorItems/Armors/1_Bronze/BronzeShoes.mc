import Toybox.Lang;

class BronzeShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1013;
		name = "Bronze Shoes";
		description = "Bronze-plated boots, light but offering minimal protection.";
		value = 20;
		weight = 3;
		slot = FEET;
		defense = 4;
		attribute_bonus = {
			:dexterity => 3
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.bronze_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new BronzeShoes();
		// ...existing code...
		return shoes;
	}

}
