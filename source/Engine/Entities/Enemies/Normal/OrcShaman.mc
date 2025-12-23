import Toybox.Lang;

class OrcShaman extends Enemy {

    private const spell_damage = 30;
    private const heal_amount = 50;

    private var magic_cooldown = 0;
    private const magic_cooldown_max = 2;

    private var heal_cooldown = 0;
    private const heal_cooldown_max = 3;

    private const spell_range = 3;
    
    
    function initialize() {
        Enemy.initialize();
        id = 33;
        name = "Shaman Orc";
        damage = 15;
		current_health = 100;
		maxHealth = current_health;
		energy_per_turn = 100;
		armor = 0;
        kill_experience = 125;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_orc_shaman;
    }

    function findNextMove(map as Map) as Point2D {
        var player_pos = $.getApp().getPlayer().getPos();
        var dist = $.MathUtil.abs(player_pos[0] - pos[0]) + $.MathUtil.abs(player_pos[1] - pos[1]);
        if (dist <= 3) {
            return Enemy.walkAwayFromPlayer(map);
        }
        return Enemy.followPlayerSimple(map);
    }


    function doAction(map ) as Boolean {
        // Check if player is in range of spell attack
        if (MapUtil.getPlayerInRangeLinear(map, pos , spell_range)) {
            if (magic_cooldown <= 0) {
                var player = $.getApp().getPlayer();
                player.takeDamage(spell_damage, self);
                magic_cooldown = magic_cooldown_max;
                return true;
            }
        }
        //Check if another enemy is in range of heal and if it is not at full health
        var enemies = $.getApp().getCurrentDungeon().getCurrentRoom().getEnemies() as Dictionary<Point2D, Enemy>;
        enemies = enemies.values() as Array<Enemy>;
        for (var i = 0; i < enemies.size(); i++) {
            var enemy = enemies[i];
            if (enemy != self && MapUtil.calcDistance(pos, enemy.getPos()) <= spell_range) {
                if (enemy.current_health < enemy.maxHealth) {
                    if (heal_cooldown <= 0) {
                        enemy.doHealthDelta(heal_amount);
                        heal_cooldown = heal_cooldown_max;
                        return true;
                    }
                }
            }
        }
        return false;
    }
}