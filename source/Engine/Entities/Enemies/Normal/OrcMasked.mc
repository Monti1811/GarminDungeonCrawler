import Toybox.Lang;

class OrcMasked extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 32;
        name = "Masked Orc";
        damage = 20;
		current_health = 125;
		maxHealth = 125;
		energy_per_turn = 100;
		armor = 2;
        kill_experience = 125;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_orc_masked;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }
}