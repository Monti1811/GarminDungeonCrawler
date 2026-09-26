import Toybox.Lang;

class GloomLurker extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 37;
        name = "Gloom Lurker";
        description = "A sinister creature that feeds on despair.";
        current_health = 62;
        maxHealth = 218;
        damage = 15;
        armor = 6;
        kill_experience = 48;
        energy_per_turn = 78;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_gloom_lurker;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerUnpredictableSafe(map);
    }
}
