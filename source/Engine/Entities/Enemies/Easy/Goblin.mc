import Toybox.Lang;

class Goblin extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 25;
        name = "Goblin";
        current_health = 35;
        maxHealth = 35;
        damage = 10;
        armor = 2;
        kill_experience = 15;
        energy_per_turn = 100; 
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_goblin;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }
}