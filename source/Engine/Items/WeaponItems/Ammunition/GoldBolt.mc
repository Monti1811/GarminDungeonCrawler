import Toybox.Lang;

class GoldBolt extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 253;
		name = "Gold Bolt";
		description = "A gold bolt";
		type = BOLT;
		attack = 15;
		value = 50;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.bolt_gold;
	}

	function deepcopy() as Item {
		var item = new GoldBolt();
		item.amount = amount;
		return item;
	}


}