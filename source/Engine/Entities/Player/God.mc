import Toybox.Lang;

class God extends Player {

	var current_mana as Number = 1000;
	var maxMana as Number = 1000;

	function initialize(name as String) {
		Player.initialize();
		self.id = 999;
		// Set name
		self.name = name;
		self.description = "A god character";
		self.level = 100;
		self.experience = 124;
		self.second_bar = :mana;
		self.next_level_experience = 130;
		self.attributes = {
			:strength => 100,
			:constitution => 100,
			:intelligence => 100,
			:wisdom => 100,
			:dexterity => 100,
			:charisma => 100,
			:luck => 100
		};
		self.current_health = 1000;
		self.maxHealth = 1000;

		var arrows = new Arrow();
		arrows.amount = 100;
		self.equipped = {
			HEAD => new SteelHelmet(),
			CHEST => new SteelBreastPlate(),
			FEET => new SteelShoes(),
			RIGHT_HAND => new SteelAxe(),
			AMMUNITION => arrows,
			ACCESSORY => new SteelRing1()
		};
		self.gold = 99999;
		self.sprite = $.Rez.Drawables.Wrestler;

	}

	function onLevelUp() as Void {
		// Increase max health
		Player.onLevelUp();
		maxHealth += 100;
	}

	function getManaPercent() as Float {
		return current_mana.toFloat() / maxMana.toFloat();
	}

	

}