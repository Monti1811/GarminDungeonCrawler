import Toybox.Lang;

class Necromancer extends Enemy {

    var summon_cooldown as Number = 0;
    var summon_cooldown_max as Number = 5;

    var children as Array<Number> = [];

	function initialize() {
		Enemy.initialize();
		id = 6;
		name = "Necromancer";
		damage = 20;
		current_health = 50;
		maxHealth = 50;
		energy_per_turn = 67; 
        armor = 0;
        kill_experience = 125;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_necromancer;
	}

	function findNextMove(map as Map) as Point2D {
        return Enemy.followPlayerKiting(map, 3, 5);
    }

    function doAction(map as Map) as Boolean {
        if (summon_cooldown > 0) {
            return false;
        }
        var summons = {
            4 => 5, // Imp
            5 => 5, // Skeleton
            7 => 5, // Small Zombie
        };
        var summon = EnemyUtil.summonEnemy(summons, map, pos);
        if (summon != null) {
            children.add(summon.guid);
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