import Toybox.Lang;

class Imp extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 4;
		name = "Imp";
		damage = 12;
		current_health = 25;
		maxHealth = 25;
		energy_per_turn = 100;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_imp;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}