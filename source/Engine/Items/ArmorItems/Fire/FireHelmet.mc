import Toybox.Lang;

class FireHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1022;
		name = "Fire Helmet";
		description = "A simple fire helmet";
		value = 15;
		weight = 3;
		slot = HEAD;
		defense = 5;
		attribute_bonus = {
			:constitution => 4
		};
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.fire_helmet;
	}
	
	function deepcopy() as Item {
		var helmet = new FireHelmet();
		// ...existing code...
		return helmet;
	}

}
