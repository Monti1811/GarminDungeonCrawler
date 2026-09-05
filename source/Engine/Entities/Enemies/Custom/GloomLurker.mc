import Toybox.Lang;

class GloomLurker extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 37;
        name = "Gloom Lurker";
        current_health = 62;
        maxHealth = 62;
        damage = 9;
        armor = 3;
        kill_experience = 16;
        energy_per_turn = 78;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_gloom_lurker;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerUnpredictableSafe(map);
    }
}
