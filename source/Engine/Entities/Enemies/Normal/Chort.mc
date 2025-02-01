import Toybox.Lang;

class Chort extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 28;
		name = "Chort";
		damage = 25;
		current_health = 150;
		maxHealth = current_health;
		energy_per_turn = 100;
		armor = 10;
        kill_experience = 175;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_chort;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}