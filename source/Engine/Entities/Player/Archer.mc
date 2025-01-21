import Toybox.Lang;

class Archer extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 2;
		// Set name
		self.name = name;
		self.description = "An archer character";

		// Give starting items
		self.equipItem(new SteelBow(), RIGHT_HAND, null);
		self.equipItem(new SteelGauntlets(), LEFT_HAND, null);
		var arrows = new Arrow();
		arrows.setAmount(20);
		self.equipItem(arrows, AMMUNITION, null);


		// Set attributes
		self.attributes = {
			:strength => 5,
			:constitution => 8,
			:intelligence => 4,
			:wisdom => 4,
			:dexterity => 12,
			:charisma => 5,
			:luck => 7
		};

		self.sprite = $.Rez.Drawables.Elf;

	}

	function onLevelUp() as Void {
		// Increase max health
		Player.onLevelUp();
		maxHealth += 10;
	}



	

}