import Toybox.Lang;

class Wogol extends Enemy {
	
	var teleport_cooldown = 0;
	var teleport_cooldown_max = 3;

	function initialize() {
		Enemy.initialize();
		id = 9;
		name = "Wogol";
		damage = 60;
		current_health = 250;
		maxHealth = 250;
		armor = 15;
        kill_experience = 250;
		energy_per_turn = 50;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_wogol;
	}

	function findNextMove(map) as Point2D {
        if (teleport_cooldown > 0) {
			return Enemy.followPlayerSimple(map);
		}
		teleport_cooldown = teleport_cooldown_max;
		return Enemy.toPlayerTeleport(map);
    }

	function onTurnDone() as Void {
		teleport_cooldown -= 1;
		Enemy.onTurnDone();
	}

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}