import Toybox.Lang;

class Elemental extends Enemy {

	var children_on_death = 2;

	function initialize() {
		Enemy.initialize();
		damage = 50;
		current_health = 250;
		maxHealth = current_health;
		energy_per_turn = 50;
		energy_per_turn = 50;
		armor = 10;
        kill_experience = 125;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onDeath() as Void {
		Enemy.onDeath();
		// Spawn two small elementals
		var room = $.getApp().getCurrentDungeon().getCurrentRoom();
		var map = room.getMap();
		for (var i = 0; i < children_on_death; i++) {
			var summon_pos = $.MapUtil.findRandomEmptyTileAround(map, pos);
			if (summon_pos != null) {
				var summon = new ElementalAirSmall();
				summon.setPos(summon_pos);
				room.addEnemy(summon);
			}
		}	
	}

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}