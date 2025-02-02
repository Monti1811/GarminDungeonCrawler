import Toybox.Lang;

class OrcArmored extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 31;
        name = "Armored Orc";
        damage = 50;
		current_health = 175;
		maxHealth = current_health;
		armor = 50;
        kill_experience = 300;
		energy_per_turn = 50;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_orc_armored;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }
}