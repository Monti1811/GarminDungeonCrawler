import Toybox.Lang;

class Arrow extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 9;
		name = "Arrow";
		type = ARROW;
		attack = 4;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.arrow;
	}


}