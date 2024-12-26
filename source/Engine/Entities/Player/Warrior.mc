import Toybox.Lang;

class Warrior extends Player {

	function initialize(name as String) {
		Player.initialize();

		// Set name
		me.name = name;

		// Give starting items
		equipped[RIGHT_HAND] = new Axe();
		equipped[HEAD] = new Helmet();

		// Set attributes
		attributes[:strength] = 10;
		attributes[:constitution] = 10;

	}

	function onLevelUp() as Void {
		// Increase max health
		maxHealth += 10;

		// Increase attributes
		addToAttribute(:strength, 2);
		addToAttribute(:constitution, 2);
	}



	

}