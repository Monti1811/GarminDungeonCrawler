import Toybox.Lang;

class OrcArmored extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 31;
        name = "Armored Orc";
        description = "A heavily armored orc footman.";
        damage = 50;
		current_health = 220;
		maxHealth = current_health;
		armor = 35;
        kill_experience = 100;
		energy_per_turn = 50;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_orc_armored;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerDirect(map);
    }
}