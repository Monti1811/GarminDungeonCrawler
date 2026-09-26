import Toybox.Lang;

class Rokita extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 35;
        name = "Rokita";
        description = "A deadly orc champion, feared by many.";
        damage = 40;
		current_health = 500;
		maxHealth = current_health;
		armor = 0;
        kill_experience = 110;
		energy_per_turn = 100;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_rokita;
    }

    function findNextMove(map) as Point2D {
        if (Enemy.canUseTeleportMove()) {
            return Enemy.followPlayerTeleportBehind(map);
        }
        return Enemy.followPlayerUnpredictableSafe(map);
    }
}