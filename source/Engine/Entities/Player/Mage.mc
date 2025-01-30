import Toybox.Lang;

class Mage extends Player {

	var current_mana as Number = 100;
	var maxMana as Number = 100;

	function initialize(name as String) {
		Player.initialize();
		self.id = 1;
		// Set name
		self.name = name;
		self.description = "A mage character";
		self.second_bar = :mana;

		// Set health
		self.current_health = 80;
		self.maxHealth = 80;

		// Give starting items
		self.equipItem(new SteelStaff(), RIGHT_HAND, null);
		self.equipItem(new SteelRing1(), ACCESSORY, null);


		// Set attributes
		self.attributes = {
			:strength => 2,
			:constitution => 3,
			:intelligence => 10,
			:wisdom => 10,
			:dexterity => 2,
			:charisma => 0,
			:luck => 4
		};

		self.sprite = $.Rez.Drawables.Wizard;

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
		maxHealth += 5;
		maxMana += 5;
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