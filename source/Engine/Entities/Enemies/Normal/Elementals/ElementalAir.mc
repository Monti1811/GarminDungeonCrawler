import Toybox.Lang;

class ElementalAir extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 18;
		name = "Air Elemental";
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_air;
	}

}