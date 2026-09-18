import Toybox.Lang;

class GoldArrow extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 203;
		name = "Gold Arrow";
		description = "A golden arrow imbued with holy radiance.";
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