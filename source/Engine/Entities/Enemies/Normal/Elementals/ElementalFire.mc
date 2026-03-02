import Toybox.Lang;

class ElementalFire extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 20;
		name = "Fire Elemental";
		children_id = 14;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_fire;
	}

}