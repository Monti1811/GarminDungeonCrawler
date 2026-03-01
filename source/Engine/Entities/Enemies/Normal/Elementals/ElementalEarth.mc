import Toybox.Lang;

class ElementalEarth extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 19;
		name = "Earth Elemental";
		children_id = 13;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_earth;
	}
	
}