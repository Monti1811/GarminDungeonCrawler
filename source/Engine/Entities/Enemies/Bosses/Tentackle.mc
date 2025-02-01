import Toybox.Lang;

class Tentackle extends Enemy {
    
    function initialize() {
        Enemy.initialize();
        id = 26;
        name = "Tentackle";
        current_health = 750;
        maxHealth = current_health;
        damage = 100;
        armor = 10;
        kill_experience = 500;
        energy_per_turn = 200; 
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_tentackle;
    }

    function getSpriteOffset() as Point2D {
		return [8, 16];
	}

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }
}