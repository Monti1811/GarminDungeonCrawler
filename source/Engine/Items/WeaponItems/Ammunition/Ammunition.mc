import Toybox.Lang;

class Ammunition extends WeaponItem {

	var type as AmmunitionType = ARROW;

	function initialize() {
		WeaponItem.initialize();
		slot = AMMUNITION;
		attack = 1;
		weight = 0.01;
		value = 5;
	}

	function getType() as AmmunitionType {
		return type;
	}

	function isType(type as AmmunitionType) as Boolean {
		return self.type == type;
	}


}