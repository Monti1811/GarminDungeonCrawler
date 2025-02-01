import Toybox.Lang;

class DarkKnight extends Enemy {
	
	var teleport_cooldown = 0;
	var teleport_cooldown_max = 3;

	function initialize() {
		Enemy.initialize();
		id = 11;
		name = "Dark Knight";
		damage = 50;
		current_health = 200;
		maxHealth = current_health;
		armor = 30;
        kill_experience = 400;
		energy_per_turn = 75;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_dark_knight;
	}

	function findNextMove(map) as Point2D {
		return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}