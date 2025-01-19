import Toybox.Lang;

class Ammunition extends Item {

	var type as AmmunitionType = ARROW;
	var damage as Number = 1;

	function initialize() {
		Item.initialize();
	}

	function getType() as AmmunitionType {
		return type;
	}

	function isType(type as AmmunitionType) as Boolean {
		return self.type == type;
	}


}