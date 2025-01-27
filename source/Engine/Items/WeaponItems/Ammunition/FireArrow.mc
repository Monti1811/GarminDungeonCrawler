import Toybox.Lang;

class FireArrow extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 10;
		name = "Fire Arrow";
		description = "A fire arrow";
		type = ARROW;
		attack = 2;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.arrow_fire;
	}

	function deepcopy() as Item {
		var item = new FireArrow();
		return item;
	}


}