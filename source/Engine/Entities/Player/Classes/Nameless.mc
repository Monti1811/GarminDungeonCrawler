import Toybox.Lang;

class Nameless extends Player {

	var current_mana as Number = 15;
	var maxMana as Number = 15;

	function initialize(name as String) {
		Player.initialize();
		self.id = 3;
		// Set name
		self.name = name;
		self.description = "A nameless character, with no backstory";
		self.second_bar = :mana;

		// Set health
		self.current_health = 150;
		self.maxHealth = 150;

		// Give starting items
		self.equipItem(new SteelDagger(), RIGHT_HAND, null);
		self.equipItem(new LifeAmulet(), ACCESSORY, null);


		// Set attributes
		self.attributes = {
			:strength => 13,
			:constitution => 13,
			:intelligence => 13,
			:wisdom => 13,
			:dexterity => 13,
			:charisma => 13,
			:luck => 5
		};

		self.sprite = $.Rez.Drawables.Basic;

	}

	function getCurrentMana() as Number {
		return current_mana;
	}

	function getMaxMana() as Number {
		return maxMana;
	}

	function getManaPercent() as Float {
		return current_mana.toFloat() / maxMana.toFloat();
	}

	function doManaDelta(delta as Number) as Void {
		current_mana += delta;
		if (current_mana < 0) {
			current_mana = 0;
		}
		if (current_mana > maxMana) {
			current_mana = maxMana;
		}
	}

	function onLevelUp() as Void {
		Player.onLevelUp();
		// Increase max health and mana
		maxHealth += 12;
		maxMana += 4;
	}

	function onNextDungeon() as Void {
		Player.onNextDungeon();
		current_mana = MathUtil.ceil(maxMana / 2, current_mana);
	}

	function save() as Dictionary {
		var save_data = Player.save();
		save_data["current_mana"] = current_mana;
		save_data["maxMana"] = maxMana;
		return save_data;
	}


	function onLoad(save_data as Dictionary) as Void {
		Player.onLoad(save_data);
		current_mana = save_data["current_mana"];
		maxMana = save_data["maxMana"];
	}
	

}