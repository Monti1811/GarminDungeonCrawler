import Toybox.Lang;

class God extends Player {

	var current_mana as Number = 15;
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

		self.inventory = new Inventory(30);
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

	}

	function onLevelUp() as Void {
		// Increase max health
		Player.onLevelUp();
		current_health += 100;
		maxHealth += 100;
		WatchUi.showToast(self.name + " leveled up!", {:icon=>Rez.Drawables.aboutToastIcon});
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


	function save() as Dictionary {
		var save_data = Player.save();
		save_data["current_mana"] = current_mana;
		save_data["maxMana"] = maxMana;
		return save_data;
	}


	function onLoad(save_data as Dictionary) as Void {
		Player.onLoad(save_data);
		if (save_data["current_mana"] != null) {
			self.current_mana = save_data["current_mana"];
		}
		if (save_data["maxMana"] != null) {
			self.maxMana = save_data["maxMana"];
		}
	}

	

}