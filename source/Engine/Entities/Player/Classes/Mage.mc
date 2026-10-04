import Toybox.Lang;

class Mage extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 1;
		// Set name
		self.name = name;
		self.description = "A mage character";
		self.ability_text = "Mana is your second bar: your staff drains it with every hit and stays powered while you can pay. Potions refill it; it is restored to 3/4 on each new floor.";
		self.second_bar = :mana;

		// Second bar
		self.current_second_bar = 35;
		self.max_second_bar = 35;

		// Set health
		self.current_health = 25;
		self.maxHealth = 25;

		// Give starting items
		self.equipItem(new SteelStaff(), RIGHT_HAND, null);
		self.equipItem(new SteelRing1(), ACCESSORY, null);


		// Set attributes
		self.attributes = {
			:strength => 3,
			:constitution => 5,
			:intelligence => 15,
			:wisdom => 15,
			:dexterity => 5,
			:charisma => 2,
			:luck => 5
		};

		self.sprite = $.Rez.Drawables.Wizard;

	}

	function onLevelUp() as Void {
		Player.onLevelUp();
		// Increase max health and second bar
		maxHealth += 4;
		max_second_bar += 2;
	}

	function onNextDungeon() as Void {
		Player.onNextDungeon();
		current_second_bar = MathUtil.ceil(3 * max_second_bar / 4, current_second_bar);
	}

}
