import Toybox.Lang;

class ElementalWaterSmall extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 17;
		name = "Small Water Elemental";
		description = "A minor elemental of flowing water.";
		damage = 20;
		current_health = 50;
		maxHealth = current_health;
		energy_per_turn = 50;
		armor = 7;
        kill_experience = 45;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_water_small;
	}

	function findNextMove(map) as Point2D {
		return Enemy.followPlayerStrafe(map, true);
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}