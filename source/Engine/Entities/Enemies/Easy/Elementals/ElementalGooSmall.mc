import Toybox.Lang;

class ElementalGooSmall extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 16;
		name = "Small Goo Elemental";
		damage = 15;
		current_health = 50;
		maxHealth = current_health;
		energy_per_turn = 50;
		armor = 5;
        kill_experience = 15;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_goo_small;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}