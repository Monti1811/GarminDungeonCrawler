import Toybox.Lang;

class ElementalPlant extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 23;
		name = "Plant Elemental";
		description = "A fierce elemental of twisted nature.";
		children_id = 30;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_plant;
	}
}