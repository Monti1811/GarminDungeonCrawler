import Toybox.Lang;

class IceBolt extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 18;
		name = "Ice Bolt";
		description = "An ice bolt";
		type = BOLT;
		attack = 2;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.bolt_ice;
	}

	function deepcopy() as Item {
		var item = new IceBolt();
		item.amount = amount;
		return item;
	}


}