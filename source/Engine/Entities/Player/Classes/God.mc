import Toybox.Lang;

class God extends Player {

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

		// Second bar
		self.current_second_bar = 15;
		self.max_second_bar = 1000;

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

		self.inventory = new Inventory(100);
		var arrows = new Arrow();
		arrows.amount = 100;
		self.equipItem(new SteelAxe(), RIGHT_HAND, null);
		self.equipItem(new SteelBreastPlate(), CHEST, null);
		self.equipItem(new SteelHelmet(), HEAD, null);
		self.equipItem(new SteelShoes(), FEET, null);
		self.equipItem(new SteelRing1(), ACCESSORY, null);
		self.equipItem(arrows, AMMUNITION, null);

		self.gold = 99999;
		self.sprite = $.Rez.Drawables.Wrestler;

		self.inventory.add(new SteelBow());
		self.inventory.add(new SteelSpell());
		self.inventory.add(new SteelStaff());
		self.inventory.add(new ManaPotion());
		self.inventory.add(new HealthPotion());
		self.inventory.add(new SteelDagger());
		self.inventory.add(new SteelDagger());
		self.inventory.add(new WoodShield());
		self.inventory.add(new CrossBow());
		self.inventory.add(new GreaterHealthPotion());
		self.inventory.add(new MaxHealthPotion());
		self.inventory.add(new GreaterManaPotion());
		self.inventory.add(new MaxManaPotion());
		self.inventory.add(new GreenBackpack());
		self.inventory.add(new FireSword());
		self.inventory.add(new IceSword());
		self.inventory.add(new FireBreastPlate());
		var arrows2 = new Arrow();
		arrows2.amount = 15;
		self.inventory.add(arrows2);

	}

	function onLevelUp() as Void {
		// Increase max health
		Player.onLevelUp();
		current_health += 50;
		maxHealth += 50;
	}

}
