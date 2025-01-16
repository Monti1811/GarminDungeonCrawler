import Toybox.Lang;

class Warrior extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 0;
		// Set name
		self.name = name;
		self.description = "A warrior character";

		// Give starting items
		self.equipped[RIGHT_HAND] = new SteelAxe();
		self.equipped[HEAD] = new SteelHelmet();

		// Set attributes
		self.attributes[:strength] = 10;
		self.attributes[:constitution] = 10;

		self.sprite = $.Rez.Drawables.KnightBlue;

	}

	function onLevelUp() as Void {
		// Increase max health
		maxHealth += 10;

		// Increase attributes
		addToAttribute(:strength, 2);
		addToAttribute(:constitution, 2);
	}



	

}