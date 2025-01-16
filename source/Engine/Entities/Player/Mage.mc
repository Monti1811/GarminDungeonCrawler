import Toybox.Lang;

class Mage extends Player {

	function initialize(name as String) {
		Player.initialize();
		self.id = 1;
		// Set name
		self.name = name;
		self.description = "A mage character";

		// Give starting items
		self.equipped[RIGHT_HAND] = new SteelAxe();
		self.equipped[HEAD] = new SteelHelmet();

		// Set attributes
		self.attributes[:intelligence] = 10;
		self.attributes[:wisdom] = 10;

		self.sprite = $.Rez.Drawables.Wizard;

	}

	function onLevelUp() as Void {
		// Increase max health
		maxHealth += 10;

		// Increase attributes
		addToAttribute(:intelligence, 2);
		addToAttribute(:wisdom, 2);
	}



	

}