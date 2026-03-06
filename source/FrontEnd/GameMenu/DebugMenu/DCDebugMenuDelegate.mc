import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as Symbol;
        switch (id) {
            case :debug_enemies:
                openEnemyList();
                break;
            case :debug_items:
                openItemList();
                break;
            case :debug_player:
                openPlayerStats();
                break;
        }
    }

	function openEnemyList() as Void {
        var menu = new WatchUi.Menu2({:title=>"Enemies (Debug)"});
        var enemy_ids = $.Enemies.enemy_ids;
        enemy_ids.sort(new NumberCompare());
        for (var i = 0; i < enemy_ids.size(); i++) {
            var enemy = $.Enemies.createEnemyFromId(enemy_ids[i]);
            var subtitle = "Id " + enemy_ids[i];
			var icon = new DCDebugEnemyIcon(enemy);
			menu.addItem(new WatchUi.IconMenuItem(enemy.getName(), subtitle, enemy_ids[i], icon, null));
        }
        WatchUi.pushView(menu, new DCDebugSpawnEnemyDelegate(), WatchUi.SLIDE_UP);
    }

    function openItemList() as Void {
        var menu = new WatchUi.Menu2({:title=>"Items (Debug)"});
        var item_ids = $.Items.item_ids;
        item_ids.sort(new NumberCompare());
        for (var i = 0; i < item_ids.size(); i++) {
			Toybox.System.println("Item ID: " + item_ids[i]);
            var item = $.Items.createItemFromId(item_ids[i]);
            var subtitle = "Id " + item_ids[i];
			var icon = new DCItemIcon(item);
			menu.addItem(new WatchUi.IconMenuItem(item.getName(), subtitle, item_ids[i], icon, null));
        }
        WatchUi.pushView(menu, new DCDebugSpawnItemDelegate(), WatchUi.SLIDE_UP);
    }

    function openPlayerStats() as Void {
        var player = $.getApp().getPlayer();
        if (player == null) {
            WatchUi.showToast("No player", {:icon=>Rez.Drawables.cancelToastIcon});
            return;
        }
        var menu = new WatchUi.Menu2({:title=>"Player Stats (:debug)"});
        menu.addItem(new WatchUi.MenuItem("Health", player.getHealth() + "/" + player.getMaxHealth(), :set_health, null));
        menu.addItem(new WatchUi.MenuItem("Max Health", player.getMaxHealth().toString(), :set_max_health, null));
        if (player.getMaxMana() > 0) {
            menu.addItem(new WatchUi.MenuItem("Mana", player.getCurrentMana() + "/" + player.getMaxMana(), :set_mana, null));
            menu.addItem(new WatchUi.MenuItem("Max Mana", player.getMaxMana().toString(), :set_max_mana, null));
        }
        menu.addItem(new WatchUi.MenuItem("Gold", player.getGold().toString(), :set_gold, null));

        var att_keys = $.Constants.ATT_SYMBOL_TO_STR.keys();
        for (var i = 0; i < att_keys.size(); i++) {
            var att = att_keys[i] as Symbol;
            var label = $.Constants.ATT_SYMBOL_TO_STR[att];
            menu.addItem(new WatchUi.MenuItem(label, "Current: " + player.getAttribute(att), att, null));
        }
        menu.addItem(new WatchUi.MenuItem("Attribute Points", player.getAttributePoints().toString(), :attribute_points, null));

        WatchUi.pushView(menu, new DCDebugPlayerStatsDelegate(), WatchUi.SLIDE_UP);
    }

}
