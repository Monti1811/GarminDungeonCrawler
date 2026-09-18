import Toybox.Lang;

class ElementalFire extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 20;
		name = "Fire Elemental";
		description = "A fierce elemental of blazing fire.";
		children_id = 14;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_fire;
	}

}