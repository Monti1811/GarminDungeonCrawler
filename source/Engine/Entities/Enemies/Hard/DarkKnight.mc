import Toybox.Lang;

class DarkKnight extends Enemy {
	
	var teleport_cooldown = 0;
	var teleport_cooldown_max = 3;

	function initialize() {
		Enemy.initialize();
		id = 11;
		name = "Dark Knight";
		description = "A fallen knight clad in shadow-forged armor.";
		damage = 50;
		current_health = 250;
		maxHealth = current_health;
		armor = 21;
        kill_experience = 100;
		energy_per_turn = 75;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_dark_knight;
	}

	function findNextMove(map) as Point2D {
		return Enemy.followPlayerFlankSafe(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}