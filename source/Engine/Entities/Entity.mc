import Toybox.Lang;

class Entity {
	var name as String = "Entity";

	function initialize() {
	}

	function getName() as String {
		return name;
	}

	function setName(name as String) {
		self.name = name;
	}
}