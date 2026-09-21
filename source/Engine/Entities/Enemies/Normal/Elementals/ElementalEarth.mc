import Toybox.Lang;

class ElementalEarth extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 19;
		name = "Earth Elemental";
		description = "A mighty elemental of living stone.";
		children_id = 13;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_earth;
	}
	
}