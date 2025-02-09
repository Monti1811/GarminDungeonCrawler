import Toybox.Lang;

class FireBolt extends Ammunition {

	function initialize() {
		Ammunition.initialize();
		id = 251;
		name = "Fire Bolt";
		description = "A fire bolt";
		type = BOLT;
		attack = 2;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.bolt_fire;
	}

	function deepcopy() as Item {
		var item = new FireBolt();
		return item;
	}


}