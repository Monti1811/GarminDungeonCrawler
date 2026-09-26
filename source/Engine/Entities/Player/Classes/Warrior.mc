import Toybox.Lang;

class Warrior extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 0;
		// Set name
		self.name = name;
		self.description = "A warrior character";

		// Set health
		self.current_health = 21;
		self.maxHealth = 21;

		// Give starting items
		self.equipItem(new SteelAxe(), RIGHT_HAND, null);
		self.equipItem(new SteelBreastPlate(), CHEST, null);

		// Set attributes
		self.attributes = {
			:strength => 15,
			:constitution => 15,
			:intelligence => 2,
			:wisdom => 3,
			:dexterity => 6,
			:charisma => 4,
			:luck => 5
		};

		self.sprite = $.Rez.Drawables.KnightBlue;

	}

	function onLevelUp() as Void {
		// Increase max health
		Player.onLevelUp();
		maxHealth += 4;
	}



	

}