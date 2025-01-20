import Toybox.Lang;

class Ammunition extends WeaponItem {

	var type as AmmunitionType = ARROW;

	function initialize() {
		WeaponItem.initialize();
		attack = 1;
	}

	function getType() as AmmunitionType {
		return type;
	}

	function isType(type as AmmunitionType) as Boolean {
		return self.type == type;
	}


}