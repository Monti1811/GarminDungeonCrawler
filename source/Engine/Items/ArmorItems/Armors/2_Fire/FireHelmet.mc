import Toybox.Lang;

class FireHelmet extends ArmorItem {

	function initialize() {
		ArmorItem.initialize();
		id = 1020;
		name = "Fire Helmet";
		description = "A fire helmet, it's a bit hot";
		value = 70;
		weight = 3;
		slot = HEAD;
		defense = 7;
		attribute_bonus = {
			:constitution => 3,
			:strength => 3
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
