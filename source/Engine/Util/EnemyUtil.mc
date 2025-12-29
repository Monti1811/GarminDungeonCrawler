import Toybox.Lang;


module EnemyUtil {

	function summonEnemy(summons as Dictionary, map as Map, pos as Point2D) as Entity? {
		var chosen_summon = $.MathUtil.weighted_random(summons);
        var summon_pos = $.MapUtil.findRandomEmptyTileAround(map, pos);
        if (summon_pos != null) {
            var summon = $.Enemies.createEnemyFromId(chosen_summon);
            summon.setPos(summon_pos);
            summon.register();
            var room = $.Game.getCurrentRoom();
            room.addEnemy(summon);
            return summon;
        }
		return null;
	}
}