import Toybox.Lang;

class ElementalGoo extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 22;
		name = "Goo Elemental";
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_goo;
	}

}