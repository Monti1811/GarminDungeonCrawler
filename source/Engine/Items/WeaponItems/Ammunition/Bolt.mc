import Toybox.Lang;

class Bolt extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 16;
		name = "Bolt";
		description = "A simple bolt";
		type = BOLT;
		attack = 4;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.bolt;
	}

	function deepcopy() as Item {
		var item = new Bolt();
		return item;
	}


}