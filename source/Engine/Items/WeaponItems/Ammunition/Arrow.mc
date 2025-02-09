import Toybox.Lang;

class Arrow extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 200;
		name = "Arrow";
		description = "A simple arrow";
		type = ARROW;
		attack = 4;
		value = 5;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.arrow;
	}

	function deepcopy() as Item {
		var item = new Arrow();
		return item;
	}


}