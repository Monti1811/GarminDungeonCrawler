import Toybox.Lang;

class Goblin extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 25;
        name = "Goblin";
        description = "A cunning goblin with quick reflexes.";
        current_health = 35;
        maxHealth = 241;
        damage = 12;
        armor = 2;
        kill_experience = 15;
        energy_per_turn = 100; 
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_goblin;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerFlankSafe(map);
    }
}