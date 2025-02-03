import Toybox.Lang;


class CrossBowHell extends Bow {

	function initialize() {
		Bow.initialize();
		id = 15;
		name = "Hell Crossbow";
		description = "A hellish crossbow, can attack every 2 turns.";
		slot = RIGHT_HAND;
		value = 14;
		weight = 4;
		attribute_bonus = {
			:charisma => 5,
			:strength => 5
		};

		attack = 20;
		range = 4;
		range_type = LINEAR;
		attack_type = DEXTERITY;
		cooldown = 1;
		ammunition_type = BOLT;
	}


	function getSprite() as ResourceId {
		return $.Rez.Drawables.crossbow_hell;
	}

	function deepcopy() as Item {
		var bow = new CrossBowHell();
		bow.amount = amount;
		bow.pos = pos;
		bow.equipped = equipped;
		bow.in_inventory = in_inventory;
		bow.attack = attack;
		bow.range = range;
		return bow;
	}



}