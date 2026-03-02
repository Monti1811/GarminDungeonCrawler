import Toybox.Lang;

class FireArrow extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 201;
		name = "Fire Arrow";
		description = "A fire arrow";
		type = ARROW;
		element_override = ELEMENT_FIRE;
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