import Toybox.Lang;

class ElementalPlant extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 23;
		name = "Plant Elemental";
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_plant;
	}
}