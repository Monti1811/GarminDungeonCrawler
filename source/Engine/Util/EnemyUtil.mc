import Toybox.Lang;


module EnemyUtil {

	function summonEnemy(summons as Dictionary, map as Map, pos as Point2D) as Entity? {
        var room = $.Game.getCurrentRoom();
        if (room.getEnemies().size() >= $.Constants.MAX_ENEMIES_PER_ROOM) {
            // Too many enemies will trigger Watchdog
            return null;
        }
		var chosen_summon = $.MathUtil.weighted_random(summons);
        var summon_pos = $.MapUtil.findRandomEmptyTileAround(map, pos);
        if (summon_pos != null) {
            var summon = $.Enemies.createEnemyFromId(chosen_summon);
            summon.setPos(summon_pos);
            summon.register();
            room.addEnemy(summon);
            return summon;
        }
		return null;
	}
}