import Toybox.Lang;

class Bat extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 1;
		name = "Bat";
		current_health = 25;
		maxHealth = 25;
		armor = 5;
        kill_experience = 20;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_bat;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}