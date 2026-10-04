import Toybox.Lang;

class Trickster extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 6;
		// Set name
		self.name = name;
		self.description = "A fast and lucky backstabber";
		self.ability_text = "Energy is your second bar: it regenerates 5 each turn. While full, every hit deals double damage until 25 energy is spent - chain attacks to keep it filled.";
		self.second_bar = :energy;

		// Second bar (energy)
		self.current_second_bar = 100;
		self.max_second_bar = 100;

		// Set health
		self.current_health = 20;
		self.maxHealth = 20;

		// Give starting items
		self.equipItem(new SteelDagger(), RIGHT_HAND, null);
		self.equipItem(new SteelShoes(), FEET, null);

		// Set attributes
		self.attributes = {
			:strength => 8,
			:constitution => 6,
			:intelligence => 4,
			:wisdom => 4,
			:dexterity => 16,
			:charisma => 6,
			:luck => 8
		};

		self.sprite = $.Rez.Drawables.Trickster;

	}

	function onLevelUp() as Void {
		Player.onLevelUp();
		maxHealth += 3;
	}

	// Energy regenerates every turn
	function onTurnDone() as Void {
		Player.onTurnDone();
		doSecondBarDelta(5);
	}

	// A hit at full energy is a knockback crit: double damage
	function getAttack(enemy as Enemy?) as Number {
		var attack = Player.getAttack(enemy);
		if (current_second_bar >= 100) {
			attack = attack * 2;
		}
		return attack;
	}

	// The crit consumes energy
	function onDamageDone(damage as Number, enemy as Enemy?) as Void {
		Player.onDamageDone(damage, enemy);
		if (damage > 0 && current_second_bar >= 100) {
			doSecondBarDelta(-25);
		}
	}

}
