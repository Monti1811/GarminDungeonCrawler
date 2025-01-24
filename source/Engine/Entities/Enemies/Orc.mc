import Toybox.Lang;

class Orc extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 3;
        name = "Orc";
        current_health = 50;
        maxHealth = 50;
        damage = 5;
        armor = 2;
        kill_experience = 10;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_orc;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }
}