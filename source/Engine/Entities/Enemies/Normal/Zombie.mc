import Toybox.Lang;

class Zombie extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 8;
		name = "Small Zombie";
		damage = 15;
		current_health = 125;
		maxHealth = 125;
		energy_per_turn = 100;
		armor = 0;
        kill_experience = 125;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_zombie;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}