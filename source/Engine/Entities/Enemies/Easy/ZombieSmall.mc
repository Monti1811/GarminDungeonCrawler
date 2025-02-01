import Toybox.Lang;

class ZombieSmall extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 7;
		name = "Small Zombie";
		damage = 5;
		current_health = 20;
		maxHealth = 20;
		energy_per_turn = 100;
		armor = 0;
        kill_experience = 10;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_zombie_small;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}