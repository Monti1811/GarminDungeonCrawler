import Toybox.Lang;

class BloodShoes extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1083; // Updated ID
		name = "Blood Shoes";
		description = "Blood-soaked boots that whisper of past victims.";
		value = 1200;
		weight = 3;
		slot = FEET;
		defense = 23;
		attribute_bonus = {
			:dexterity => 10,
			:strength => 7
		};
		defense_type = CHARISMA;
	}

	function onEquipItem(player as Player, slot as ItemSlot) as Void {
		ArmorItem.onEquipItem(player, slot);
	}
	// ...existing code...
	function getSprite() as ResourceId {
		return $.Rez.Drawables.blood_leg_armor;
	}
	
	function deepcopy() as Item {
		var shoes = new BloodShoes();
		// ...existing code...
		return shoes;
	}

}
