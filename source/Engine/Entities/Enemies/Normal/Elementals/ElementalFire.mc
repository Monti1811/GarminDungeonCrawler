import Toybox.Lang;

class ElementalFire extends Enemy {

	function initialize() {
		Enemy.initialize();
		id = 20;
		name = "Fire Elemental";
		damage = 50;
		current_health = 250;
		maxHealth = current_health;
		energy_per_turn = 50;
		armor = 10;
        kill_experience = 125;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_fire;
	}

	function findNextMove(map) as Point2D {
        return Enemy.followPlayerSimple(map);
    }

	function onDeath() as Void {
		Enemy.onDeath();
		// Spawn two small elementals
		var room = $.getApp().getCurrentDungeon().getCurrentRoom();
		var map = room.getMap();
		var summon1_pos = $.MapUtil.findRandomEmptyTileAround(map, pos);
		if (summon1_pos != null) {
			var summon1 = new ElementalAirSmall();
			summon1.setPos(summon1_pos);
			room.addEnemy(summon1);
		}
		var summon2_pos = $.MapUtil.findRandomEmptyTileAround(map, pos);
		if (summon2_pos != null) {
			var summon2 = new ElementalAirSmall();
			summon2.setPos(summon2_pos);
			room.addEnemy(summon2);
		}		
	}

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
	}
}