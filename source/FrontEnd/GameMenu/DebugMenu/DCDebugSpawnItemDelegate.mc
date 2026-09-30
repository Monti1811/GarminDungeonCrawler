import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugSpawnItemDelegate extends WatchUi.Menu2InputDelegate {

    private var _delegate as DCDebugMenuDelegate;

    function initialize(delegate as DCDebugMenuDelegate) {
        Menu2InputDelegate.initialize();
        _delegate = delegate;
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id == :filter) {
            showFilter();
            return;
        }
        if (spawnItem(id as Number)) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

    function showFilter() as Void {
        var filterMenu = new WatchUi.Menu2({:title=>"Filter/Sort"});
        filterMenu.addItem(new WatchUi.MenuItem("All Items", null, :all, null));
        filterMenu.addItem(new WatchUi.MenuItem("Weapons", null, :weapons, null));
        filterMenu.addItem(new WatchUi.MenuItem("Armor", null, :armor, null));
        filterMenu.addItem(new WatchUi.MenuItem("Consumables", null, :consumables, null));
        filterMenu.addItem(new WatchUi.MenuItem("Materials", null, :materials, null));
        filterMenu.addItem(new WatchUi.MenuItem("Sort by id", null, :sort_id, null));
        filterMenu.addItem(new WatchUi.MenuItem("Sort by name", null, :sort_name, null));
        filterMenu.addItem(new WatchUi.MenuItem("Sort by weight", null, :sort_weight, null));
        filterMenu.addItem(new WatchUi.MenuItem("Sort by value", null, :sort_value, null));
        WatchUi.pushView(filterMenu, new DCDebugItemFilterDelegate(_delegate), WatchUi.SLIDE_UP);
    }

	function spawnItem(item_id as Number) as Boolean {
        var room = $.Game.getCurrentRoom();
        var spawn_pos = $.MapUtil.getDebugSpawnPos();
        if (spawn_pos == null) {
            WatchUi.showToast("No free space", {:icon=>Rez.Drawables.cancelToastIcon});
            return false;
        }
        var item = $.Items.createItemFromId(item_id);
        if (item instanceof TreasureChest) {
            item = $.Items.createTreasureChestWithRandomLoot();
        }
        item.setPos(spawn_pos);
        room.addItem(item);
        WatchUi.showToast("Spawned " + item.getName(), {:icon=>Rez.Drawables.aboutToastIcon});
        return true;
    }
}
