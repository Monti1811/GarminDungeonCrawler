import Toybox.Lang;

class Paladin extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 4;
		// Set name
		self.name = name;
		self.description = "A paladin character";

		// Set health
		self.current_health = 21;
		self.maxHealth = 21;

		// Give starting items
		self.equipItem(new SteelDagger(), RIGHT_HAND, null);
		self.equipItem(new SteelShield(), LEFT_HAND, null);
		self.equipItem(new SteelBreastPlate(), CHEST, null);

		// Set attributes
		self.attributes = {
			:strength => 10,
			:constitution => 12,
			:intelligence => 3,
			:wisdom => 10,
			:dexterity => 5,
			:charisma => 5,
			:luck => 5
		};

		self.sprite = $.Rez.Drawables.Paladin;

	}

	function onLevelUp() as Void {
		// Increase max health
		Player.onLevelUp();
		maxHealth += 4;
	}



	

}