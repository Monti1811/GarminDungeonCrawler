import Toybox.Lang;

class ElementalEarthSmall extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 13;
		name = "Small Earth Elemental";
		damage = 12;
		current_health = 50;
		maxHealth = current_health;
		energy_per_turn = 50;
		armor = 4;
        kill_experience = 15;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_earth_small;
	}

	function findNextMove(map) as Point2D {
		return Enemy.followPlayerStrafe(map, false);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}