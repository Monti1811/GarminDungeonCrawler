import Toybox.Lang;

class ElementalPlantSmall extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 30;
		name = "Small Plant Elemental";
		damage = 15;
		current_health = 50;
		maxHealth = current_health;
		energy_per_turn = 50;
		armor = 5;
        kill_experience = 15;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_plant_small;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}