import Toybox.Lang;

class Chort extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 28;
		name = "Chort";
		description = "A lesser demon with a fiery temper.";
		damage = 44;
		current_health = 230;
		maxHealth = current_health;
		energy_per_turn = 100;
		armor = 12;
        kill_experience = 100;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_chort;
	}

	function findNextMove(map) as Point2D {
		return Enemy.followPlayerDash(map, 2);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}