import Toybox.Lang;

class Bies extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 29;
		name = "Bies";
		damage = 20;
		current_health = 250;
		maxHealth = current_health;
		energy_per_turn = 67;
		armor = 20;
        kill_experience = 200;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_bies;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}