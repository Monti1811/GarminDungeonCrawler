import Toybox.WatchUi;
import Toybox.Lang;

typedef DebugItemComparator as NameCompare | WeightCompare | ValueCompare;

(:debug)
class DCDebugMenuDelegate extends WatchUi.Menu2InputDelegate {

    var item_filter as Array<ItemType>? = null;
    var item_filter_str as String = "All Items";
    var item_sort as String = "Id";
    var item_sort_ascending as Boolean = true;
    var item_sort_comparator as DebugItemComparator?;

    private var _all_items as Array<Item>? = null;
    private var _item_icons as Dictionary<Number, DCItemIcon>? = null;

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as Symbol;
        switch (id) {
            case :debug_enemies:
                openEnemyList();
                break;
            case :debug_npcs:
                openNpcList();
                break;
            case :debug_items:
                openItemList();
                break;
            case :debug_player:
                openPlayerStats();
                break;
            case :debug_functions:
                openFunctions();
                break;
        }
    }

    function openFunctions() as Void {
        var menu = new WatchUi.Menu2({:title=>"Functions (Debug)"});
        menu.addItem(new WatchUi.MenuItem("Materials x6", "6x of each material", :action_materials, null));
        WatchUi.pushView(menu, new DCDebugFunctionsDelegate(), WatchUi.SLIDE_UP);
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

    function openNpcList() as Void {
        var menu = new WatchUi.Menu2({:title=>"NPCs (Debug)"});
        var npc_ids = $.NPCs.npc_ids;
        npc_ids.sort(new NumberCompare());
        for (var i = 0; i < npc_ids.size(); i++) {
            var npc = $.NPCs.createNPCFromId(npc_ids[i]);
            var subtitle = "Id " + npc_ids[i];
            menu.addItem(new WatchUi.MenuItem(npc.getName(), subtitle, npc_ids[i], null));
        }
        WatchUi.pushView(menu, new DCDebugSpawnNpcDelegate(), WatchUi.SLIDE_UP);
    }

    function openItemList() as Void {
        var menu = new WatchUi.Menu2({:title=>"Items (Debug)"});
        menu.addItem(new WatchUi.MenuItem(
            "Filter/Sort",
            item_filter_str + "/" + item_sort + " " + (item_sort_ascending ? "Asc" : "Desc"),
            :filter,
            null
        ));
        var items = getDebugItemList();
        for (var i = 0; i < items.size(); i++) {
            var item = items[i];
            var subtitle = "Id " + item.id;
            menu.addItem(new WatchUi.IconMenuItem(item.getName(), subtitle, item.id, getDebugItemIcon(item), null));
        }
        WatchUi.pushView(menu, new DCDebugSpawnItemDelegate(self), WatchUi.SLIDE_UP);
    }

    function getAllDebugItems() as Array<Item> {
        if (_all_items == null) {
            var ids = [] as Array<Number>;
            for (var i = 0; i < $.Items.item_ids.size(); i++) {
                ids.add($.Items.item_ids[i]);
            }
            for (var id = $.MaterialUtil.MATERIAL_STEEL; id <= $.MaterialUtil.MATERIAL_BLOOD; id++) {
                ids.add(id);
            }
            ids.sort(new NumberCompare());

            var items = [] as Array<Item>;
            for (var i = 0; i < ids.size(); i++) {
                var item = $.Items.createItemFromId(ids[i]);
                if (item != null) {
                    items.add(item);
                }
            }
            _all_items = items;
        }
        return _all_items;
    }

    function getDebugItemIcon(item as Item) as DCItemIcon {
        if (_item_icons == null) {
            _item_icons = {} as Dictionary<Number, DCItemIcon>;
        }
        var icons = _item_icons as Dictionary<Number, DCItemIcon>;
        var icon = icons[item.id] as DCItemIcon?;
        if (icon == null) {
            icon = new DCItemIcon(item);
            icons[item.id] = icon;
        }
        return icon;
    }

    function getDebugItemList() as Array<Item> {
        var all = getAllDebugItems();
        var filter = item_filter as Array<ItemType>?;
        var items = [] as Array<Item>;
        for (var i = 0; i < all.size(); i++) {
            var item = all[i];
            if (filter != null && filter.indexOf(item.getItemType()) == -1) {
                continue;
            }
            items.add(item);
        }

        var comparator = item_sort_comparator as DebugItemComparator?;
        if (comparator != null) {
            items.sort(comparator);
        } else if (!item_sort_ascending) {
            var reversed = [] as Array<Item>;
            for (var i = items.size() - 1; i >= 0; i--) {
                reversed.add(items[i]);
            }
            items = reversed;
        }
        return items;
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
        if (player.getMaxSecondBar() > 0) {
            menu.addItem(new WatchUi.MenuItem(player.getSecondBarName(), player.getCurrentSecondBar() + "/" + player.getMaxSecondBar(), :set_second_bar, null));
            menu.addItem(new WatchUi.MenuItem("Max " + player.getSecondBarName(), player.getMaxSecondBar().toString(), :set_max_second_bar, null));
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
