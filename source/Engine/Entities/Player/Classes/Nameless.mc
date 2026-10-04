import Toybox.Lang;

class Nameless extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 3;
		// Set name
		self.name = name;
		self.description = "A nameless character, with no backstory";
		self.ability_text = "Mana is your second bar: spells and staves drain it with every hit. Potions refill it; it is restored to half on each new floor.";
		self.second_bar = :mana;

		// Second bar
		self.current_second_bar = 20;
		self.max_second_bar = 20;

		// Set health
		self.current_health = 30;
		self.maxHealth = 30;

		// Give starting items
		self.equipItem(new SteelDagger(), RIGHT_HAND, null);
		self.equipItem(new LifeAmulet(), ACCESSORY, null);


		// Set attributes
		self.attributes = {
			:strength => 7,
			:constitution => 7,
			:intelligence => 7,
			:wisdom => 7,
			:dexterity => 7,
			:charisma => 7,
			:luck => 8
		};

		self.sprite = $.Rez.Drawables.Basic;

	}

	function onLevelUp() as Void {
		Player.onLevelUp();
		// Increase max health and second bar
		maxHealth += 4;
		max_second_bar += 2;
	}

	function onNextDungeon() as Void {
		Player.onNextDungeon();
		current_second_bar = MathUtil.ceil(max_second_bar / 2, current_second_bar);
	}

}
