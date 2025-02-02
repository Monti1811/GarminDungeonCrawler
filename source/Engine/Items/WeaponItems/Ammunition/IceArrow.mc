import Toybox.Lang;

class IceArrow extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 12;
		name = "ice Arrow";
		description = "An ice arrow";
		type = ARROW;
		attack = 2;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.arrow_ice;
	}

	function deepcopy() as Item {
		var item = new IceArrow();
		item.amount = amount;
		return item;
	}


}