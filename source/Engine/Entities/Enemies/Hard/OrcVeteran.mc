import Toybox.Lang;

class OrcVeteran extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 34;
        name = "Veteran Orc";
        damage = 100;
		current_health = 75;
		maxHealth = current_health;
		armor = 0;
        kill_experience = 300;
		energy_per_turn = 100;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_orc_veteran;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }
}