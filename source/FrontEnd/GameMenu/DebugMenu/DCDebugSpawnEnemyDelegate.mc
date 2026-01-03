import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugSpawnEnemyDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var enemy_id = item.getId() as Number;
        if (spawnEnemy(enemy_id)) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

	function spawnEnemy(enemy_id as Number) as Boolean {
        var room = $.Game.getCurrentRoom();
        var spawn_pos = $.MapUtil.getDebugSpawnPos();
        if (spawn_pos == null) {
            WatchUi.showToast("No free space", {:icon=>Rez.Drawables.cancelToastIcon});
            return false;
        }
        var enemy = $.Enemies.createEnemyFromId(enemy_id);
        enemy.setPos(spawn_pos);
        enemy.register();
        room.addEnemy(enemy);
        WatchUi.showToast("Spawned " + enemy.getName(), {:icon=>Rez.Drawables.aboutToastIcon});
        return true;
    }
}
