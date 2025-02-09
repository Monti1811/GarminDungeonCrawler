import Toybox.Lang;


class OakCrossBow extends Bow {

	function initialize() {
		Bow.initialize();
		id = 301;
		name = "Oak Crossbow";
		description = "An oak crossbow, can attack every 3 turns.";
		slot = RIGHT_HAND;
		value = 14;
		weight = 4;
		attribute_bonus = {
			:charisma => 3,
			:strength => 3
		};

		attack = 15;
		range = 3;
		range_type = LINEAR;
		attack_type = DEXTERITY;
		cooldown = 2;
		ammunition_type = BOLT;
	}

	
	function getSprite() as ResourceId {
		return $.Rez.Drawables.crossbow_oak;
	}

	function deepcopy() as Item {
		var bow = new OakCrossBow();
		bow.amount = amount;
		bow.pos = pos;
		bow.equipped = equipped;
		bow.in_inventory = in_inventory;
		bow.attack = attack;
		bow.range = range;
		return bow;
	}


}