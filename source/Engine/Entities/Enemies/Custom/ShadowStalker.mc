import Toybox.Lang;

class ShadowStalker extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 36;
        name = "Shadow Stalker";
        current_health = 55;
        maxHealth = 55;
        damage = 8;
        armor = 2;
        kill_experience = 14;
        energy_per_turn = 80;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_shadow_stalker;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerUnpredictableSafe(map);
    }
}
