import Toybox.Lang;

class Rokita extends Enemy {

    var teleport_cooldown = 0;
	var teleport_cooldown_max = 3;
    
    function initialize() {
        Enemy.initialize();
        id = 35;
        name = "Rokita";
        damage = 40;
		current_health = 500;
		maxHealth = current_health;
		armor = 0;
        kill_experience = 350;
		energy_per_turn = 100;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_rokita;
    }

    function findNextMove(map) as Point2D {
        if (teleport_cooldown > 0) {
			return Enemy.followPlayerSimple(map);
		}
		teleport_cooldown = teleport_cooldown_max;
		return Enemy.toPlayerTeleport(map);
    }
}