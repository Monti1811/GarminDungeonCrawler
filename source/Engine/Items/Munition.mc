import Toybox.Lang;

class Munition extends Item {

	var type as MunitionType = ARROW;

	function initialize() {
		Item.initialize();
	}

	function getType() as MunitionType {
		return type;
	}

	function isType(type as MunitionType) as Boolean {
		return self.type == type;
	}


}