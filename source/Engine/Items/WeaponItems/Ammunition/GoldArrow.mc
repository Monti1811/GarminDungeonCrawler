import Toybox.Lang;

class GoldArrow extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 13;
		name = "Gold Arrow";
		description = "A gold arrow";
		type = ARROW;
		attack = 15;
		value = 50;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.arrow_gold;
	}

	function deepcopy() as Item {
		var item = new GoldArrow();
		item.amount = amount;
		return item;
	}


}