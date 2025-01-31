import Toybox.Lang;

class Skeleton extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 5;
		name = "Skeleton";
		damage = 20;
		current_health = 50;
		maxHealth = 50;
		energy_per_turn = 100;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_skelet;
	}

	function findNextMove(map) as Point2D {
        return Enemy.randomMovement(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}