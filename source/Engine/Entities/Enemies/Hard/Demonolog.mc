import Toybox.Lang;

class Demonolog extends Enemy {

    var summon_cooldown as Number = 0;
    var summon_cooldown_max as Number = 5;

    var children as Array<Number> = [];

	function initialize() {
		Enemy.initialize();
		id = 27;
		name = "Demonolog";
		damage = 20;
		current_health = 200;
		maxHealth = current_health;
		energy_per_turn = 100; 
        armor = 0;
        kill_experience = 300;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_demonolog;
	}

	function findNextMove(map as Map) as Point2D {
        var player_pos = $.getApp().getPlayer().getPos();
        var dist = $.MathUtil.abs(player_pos[0] - pos[0]) + $.MathUtil.abs(player_pos[1] - pos[1]);
        if (dist <= 3) {
            return Enemy.walkAwayFromPlayer(map);
        }
        return Enemy.followPlayerSimple(map);
    }

    function doAction(map as Map) as Boolean {
        if (summon_cooldown > 0) {
            return false;
        }
        var summons = {
            9 => 1,     // Wogol
            7 => 5,     // Zombie
            28 => 5,    // Chort
        };
        var chosen_summon = $.MathUtil.weighted_random(summons);
        var summon_pos = $.MapUtil.findRandomEmptyTileAround(map, pos);
        if (summon_pos != null) {
            var summon = $.Enemies.createEnemyFromId(chosen_summon);
            summon.register();
            summon.setPos(summon_pos);
            children.add(summon.guid);
            var room = $.Game.getCurrentRoom();
            room.addEnemy(summon);
            summon_cooldown = summon_cooldown_max;
            return true;
        }
        return false;
    }

    function onDeath() as Void {
        for (var i = 0; i < children.size(); i++) {
            var child = children[i];
            var enemy = $.EntityManager.getEntityById(child);
            if (enemy != null) {
                enemy = enemy as Enemy;
                enemy.takeDamage(100, null);
            }
        }
        Enemy.onDeath();
    }

    function onTurnDone() as Void {
        if (summon_cooldown > 0) {
            summon_cooldown -= 1;
        }
        Enemy.onTurnDone();
    }

    function save() as Dictionary {
        var save_data = Enemy.save();
        save_data["summon_cooldown"] = summon_cooldown;
        save_data["children"] = children;
        return save_data;
    }

	function onLoad(save_data as Dictionary) as Void {
		Enemy.onLoad(save_data);
        if (save_data["summon_cooldown"] != null) {
            summon_cooldown = save_data["summon_cooldown"] as Number;
        }
        if (save_data["children"] != null) {
            children = save_data["children"] as Array<Number>;
        }
	}
}