import Toybox.Lang;

class Demon extends Enemy {

	function initialize() {
		Enemy.initialize();
        id = 2;
		name = "Demon";
        attack_cooldown = 0;
        damage = 25;
        armor = 10;
        current_health = 250;
        maxHealth = 250;
		kill_experience = 200;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_demon;
	}

	function getSpriteOffset() as Point2D {
		return [8, 16];
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}