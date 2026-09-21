import Toybox.Lang;

class Paladin extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 4;
		// Set name
		self.name = name;
		self.description = "A paladin character";

		// Set health
		self.current_health = 85;
		self.maxHealth = 85;

		// Give starting items
		self.equipItem(new SteelDagger(), RIGHT_HAND, null);
		self.equipItem(new SteelShield(), LEFT_HAND, null);
		self.equipItem(new SteelBreastPlate(), CHEST, null);

		// Set attributes
		self.attributes = {
			:strength => 4,
			:constitution => 12,
			:intelligence => 1,
			:wisdom => 4,
			:dexterity => 4,
			:charisma => 3,
			:luck => 4
		};

		self.sprite = $.Rez.Drawables.Paladin;

	}

	function onLevelUp() as Void {
		// Increase max health
		Player.onLevelUp();
		maxHealth += 17;
	}



	

}