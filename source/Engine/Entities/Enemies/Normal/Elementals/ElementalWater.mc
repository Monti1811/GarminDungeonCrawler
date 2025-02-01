import Toybox.Lang;

class ElementalWater extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 24;
		name = "Water Elemental";
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_water;
	}

}