import Toybox.Lang;

class ElementalGoldSmall extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 15;
		name = "Small Gold Elemental";
		damage = 15;
		current_health = 50;
		maxHealth = current_health;
		energy_per_turn = 50;
		armor = 5;
        kill_experience = 15;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_gold_short;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function getLoot() as Item? {
		var gold = new Gold();
		gold.amount = MathUtil.random(10, 30);
		return gold;
	}

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}