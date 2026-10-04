import Toybox.Lang;

class Barbarian extends Player {

	var hit_this_round as Boolean = false;

	function initialize(name as String) {
		Player.initialize();
		self.id = 5;
		// Set name
		self.name = name;
		self.description = "A rage fueled berserker";
		self.ability_text = "Rage is your second bar: every point you deal or take fills it. At 50 you hit +10%, at 100 +25% and you steal 10% of your damage as life. It only fades in rounds without a hit.";
		self.second_bar = :rage;

		// Second bar (rage)
		self.current_second_bar = 0;
		self.max_second_bar = 100;

		// Set health
		self.current_health = 28;
		self.maxHealth = 28;

		// Give starting items
		self.equipItem(new SteelAxe(), RIGHT_HAND, null);
		self.equipItem(new SteelHelmet(), HEAD, null);

		// Set attributes
		self.attributes = {
			:strength => 16,
			:constitution => 14,
			:intelligence => 2,
			:wisdom => 2,
			:dexterity => 4,
			:charisma => 3,
			:luck => 4
		};

		self.sprite = $.Rez.Drawables.Barbarian;

	}

	function onLevelUp() as Void {
		Player.onLevelUp();
		maxHealth += 6;
	}

	// Gain rage for every point of damage dealt
	function onDamageDone(damage as Number, enemy as Enemy?) as Void {
		Player.onDamageDone(damage, enemy);
		if (damage > 0) {
			hit_this_round = true;
			doSecondBarDelta(damage);
			if (current_second_bar >= 100) {
				onGainHealth((damage * 0.1).toNumber());
			}
		}
	}

	// Gain rage for every point of damage taken
	function takeDamage(damage as Number, enemy as Enemy?) as Boolean {
		var died = Player.takeDamage(damage, enemy);
		if (damage > 0) {
			doSecondBarDelta(damage);
		}
		return died;
	}

	// Rage only decays in rounds without a hit, so a full bar stays
	// usable for the next swing (otherwise 100 -> decay -> 97 -> never full)
	function onTurnDone() as Void {
		Player.onTurnDone();
		if (hit_this_round) {
			hit_this_round = false;
		} else {
			doSecondBarDelta(-3);
		}
	}

	// 50+ rage -> +10% attack, 100 rage -> +25% attack
	function getAttack(enemy as Enemy?) as Number {
		var attack = Player.getAttack(enemy);
		if (current_second_bar >= 100) { 
			attack = (attack * 1.25).toNumber();
		} else if (current_second_bar >= 50) {
			attack = (attack * 1.1).toNumber();
		}
		return attack;
	}

}
