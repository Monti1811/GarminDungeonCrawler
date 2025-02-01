import Toybox.Lang;

class Ogre extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 10;
        name = "Ogre";
        current_health = 500;
        maxHealth = current_health;
        damage = 100;
        armor = 10;
        kill_experience = 500;
        energy_per_turn = 34; // every 3 turns
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_ogre;
    }

    function getSpriteOffset() as Point2D {
		return [8, 16];
	}

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }
}