import Toybox.Lang;

class Warrior extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 0;
		// Set name
		self.name = name;
		self.description = "A warrior character";

		// Give starting items
		self.equipItem(new SteelAxe(), RIGHT_HAND, null);
		self.equipItem(new SteelBreastPlate(), CHEST, null);

		// Set attributes
		self.attributes = {
			:strength => 8,
			:constitution => 12,
			:intelligence => 1,
			:wisdom => 2,
			:dexterity => 1,
			:charisma => 3,
			:luck => 4
		};

		self.sprite = $.Rez.Drawables.KnightBlue;

	}

	function onLevelUp() as Void {
		// Increase max health
		Player.onLevelUp();
		maxHealth += 10;
	}



	

}