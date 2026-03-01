import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugSpawnItemDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var item_id = item.getId() as Number;
        if (spawnItem(item_id)) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

	function spawnItem(item_id as Number) as Boolean {
        var room = $.Game.getCurrentRoom();
        var spawn_pos = $.MapUtil.getDebugSpawnPos();
        if (spawn_pos == null) {
            WatchUi.showToast("No free space", {:icon=>Rez.Drawables.cancelToastIcon});
            return false;
        }
        var item = $.Items.createItemFromId(item_id);
        item.setPos(spawn_pos);
        room.addItem(item);
        WatchUi.showToast("Spawned " + item.getName(), {:icon=>Rez.Drawables.aboutToastIcon});
        return true;
    }
}