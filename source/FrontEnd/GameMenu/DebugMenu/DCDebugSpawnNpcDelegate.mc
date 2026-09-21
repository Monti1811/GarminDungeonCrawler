import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugSpawnNpcDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var npc_id = item.getId() as Number;
        if (spawnNpc(npc_id)) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

    function spawnNpc(npc_id as Number) as Boolean {
        var room = $.Game.getCurrentRoom();
        var spawn_pos = $.MapUtil.getDebugSpawnPos();
        if (spawn_pos == null) {
            WatchUi.showToast("No free space", {:icon=>Rez.Drawables.cancelToastIcon});
            return false;
        }
        var npc = $.NPCs.createNPCFromId(npc_id);
        npc.setPos(spawn_pos);
        room.addNPC(npc);
        WatchUi.showToast("Spawned " + npc.getName(), {:icon=>Rez.Drawables.aboutToastIcon});
        return true;
    }
}
