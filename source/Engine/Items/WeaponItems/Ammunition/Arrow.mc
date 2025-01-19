import Toybox.Lang;

class Arrow extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 9;
		type = ARROW;
		damage = 4;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.arrow;
	}


}