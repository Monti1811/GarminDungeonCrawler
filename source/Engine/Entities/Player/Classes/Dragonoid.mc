import Toybox.Lang;

class Dragonoid extends Player {

	var overheated as Boolean = false;
	var burst_this_turn as Boolean = false;

	function initialize(name as String) {
		Player.initialize();
		self.id = 7;
		// Set name
		self.name = name;
		self.description = "A dragon blooded brawler";
		self.second_bar = :heat;

		// Second bar (heat)
		self.current_second_bar = 0;
		self.max_second_bar = 100;

		// Set health
		self.current_health = 30;
		self.maxHealth = 30;

		// Give starting items
		self.equipItem(new SteelGreatsword(), RIGHT_HAND, null);
		self.equipItem(new SteelShield(), LEFT_HAND, null);
		self.equipItem(new SteelBreastPlate(), CHEST, null);

		// Set attributes
		self.attributes = {
			:strength => 14,
			:constitution => 14,
			:intelligence => 3,
			:wisdom => 3,
			:dexterity => 5,
			:charisma => 4,
			:luck => 4
		};

		self.sprite = $.Rez.Drawables.Dragonoid;

	}

	function onLevelUp() as Void {
		Player.onLevelUp();
		maxHealth += 5;
	}

	// Heat builds up with every hit dealt
	function onDamageDone(damage as Number, enemy as Enemy?) as Void {
		Player.onDamageDone(damage, enemy);
		if (damage > 0 && !overheated) {
			if (current_second_bar >= 100) {
				// Fire burst: heat is dumped, overheat starts
				doSecondBarDelta(-current_second_bar);
				overheated = true;
				burst_this_turn = true;
			} else {
				doSecondBarDelta(25);
			}
		}
	}

	// Heat decays every turn, overheat lasts one turn
	function onTurnDone() as Void {
		Player.onTurnDone();
		if (burst_this_turn) {
			burst_this_turn = false;
		} else if (overheated) {
			overheated = false;
		} else {
			doSecondBarDelta(-5);
		}
	}

	// Full heat -> fire burst (+50%), overheat -> penalty (-25%)
	function getAttack(enemy as Enemy?) as Number {
		var attack = Player.getAttack(enemy);
		if (overheated) {
			attack = (attack * 0.75).toNumber();
		} else if (current_second_bar >= 100) {
			attack = (attack * 1.5).toNumber();
		}
		return attack;
	}

	function save() as Dictionary {
		var save_data = Player.save();
		save_data["overheated"] = overheated;
		save_data["burst_this_turn"] = burst_this_turn;
		return save_data;
	}

	function onLoad(save_data as Dictionary) as Void {
		Player.onLoad(save_data);
		if (save_data["overheated"] != null) {
			overheated = save_data["overheated"] as Boolean;
		}
		if (save_data["burst_this_turn"] != null) {
			burst_this_turn = save_data["burst_this_turn"] as Boolean;
		}
	}

}
