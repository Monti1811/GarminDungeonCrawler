import Toybox.Lang;

class ElementalAir extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 18;
		name = "Air Elemental";
		description = "A powerful elemental of raging storms.";
		children_id = 12;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_air;
	}

}