import Toybox.Lang;

class Mage extends Player {

	function initialize(name as String) {
		Player.initialize();

		// Set name
		self.name = name;
		self.description = "A mage character";

		// Give starting items
		equipped[RIGHT_HAND] = new Axe();
		equipped[HEAD] = new Helmet();

		// Set attributes
		attributes[:intelligence] = 10;
		attributes[:wisdom] = 10;

	}

	function onLevelUp() as Void {
		// Increase max health
		maxHealth += 10;

		// Increase attributes
		addToAttribute(:intelligence, 2);
		addToAttribute(:wisdom, 2);
	}



	

}