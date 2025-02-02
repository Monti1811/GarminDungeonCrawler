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
		energy_per_turn = 100; 
        armor = 0;
        kill_experience = 125;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_necromancer;
	}

	function findNextMove(map as Array<Array<Tile>>) as Point2D {
        var player_pos = $.getApp().getPlayer().getPos();
        var dist = $.MathUtil.abs(player_pos[0] - pos[0]) + $.MathUtil.abs(player_pos[1] - pos[1]);
        if (dist <= 3) {
            return Enemy.walkAwayFromPlayer(map);
        }
        return Enemy.followPlayerSimple(map);
    }

    function doAction(map as Array<Array<Tile>>) as Boolean {
        if (summon_cooldown > 0) {
            return false;
        }
        var summons = {
            5 => 5,
            6 => 5,
            7 => 1,
        };
        var chosen_summon = $.MathUtil.weighted_random(summons);
        var summon_pos = $.MapUtil.findRandomEmptyTileAround(map, pos);
        if (summon_pos != null) {
            var summon = $.Enemies.createEnemyFromId(chosen_summon);
            summon.setPos(summon_pos);
            summon.register();
            children.add(summon.guid);
            var room = $.getApp().getCurrentDungeon().getCurrentRoom();
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