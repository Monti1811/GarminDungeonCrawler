import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

class DCCompendiumDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId() as Symbol;
        switch (id) {
            case :compendium_enemies:
                openEnemyList();
                break;
            case :compendium_items:
                openItemList();
                break;
        }
    }

    function openEnemyList() as Void {
        var menu = new WatchUi.Menu2({:title=>"Enemies"});
        var discovered_ids = $.SaveData.discovered_enemies.keys();
        discovered_ids.sort(new NumberCompare());
        
        for (var i = 0; i < discovered_ids.size(); i++) {
            var enemy_id = discovered_ids[i];
            var enemy = $.Enemies.createEnemyFromId(enemy_id);
            var subtitle = "HP: " + enemy.maxHealth + " ATK: " + enemy.damage;
            var icon = new DCCompendiumEnemyIcon(enemy);
            menu.addItem(new WatchUi.IconMenuItem(enemy.getName(), subtitle, enemy_id, icon, null));
        }
        
        if (discovered_ids.size() == 0) {
            menu.addItem(new WatchUi.MenuItem("No enemies discovered", "Defeat enemies to fill the compendium", null, null));
        }
        
        WatchUi.pushView(menu, new DCCompendiumEnemyListDelegate(), WatchUi.SLIDE_UP);
    }

    function openItemList() as Void {
        var menu = new WatchUi.Menu2({:title=>"Items"});
        var discovered_ids = $.SaveData.discovered_items.keys();
        discovered_ids.sort(new NumberCompare());
        
        for (var i = 0; i < discovered_ids.size(); i++) {
            var item_id = discovered_ids[i];
            var item = $.Items.createItemFromId(item_id);
            var subtitle = "Value: " + item.getValue();
            var icon = new DCCompendiumItemIcon(item);
            menu.addItem(new WatchUi.IconMenuItem(item.getName(), subtitle, item_id, icon, null));
        }
        
        if (discovered_ids.size() == 0) {
            menu.addItem(new WatchUi.MenuItem("No items discovered", "Pick up items to fill the compendium", null, null));
        }
        
        WatchUi.pushView(menu, new DCCompendiumItemListDelegate(), WatchUi.SLIDE_UP);
    }
}

class DCCompendiumEnemyIcon extends WatchUi.Drawable {
    
    private var _icon as Graphics.BitmapReference;

    function initialize(enemy as Enemy) {
        Drawable.initialize({});
        _icon = enemy.getSpriteRef() as Graphics.BitmapReference;
    }

    function draw(dc as Toybox.Graphics.Dc) as Void {
        var icon_x = (Constants.SCREEN_WIDTH * 15 / 360).toNumber();
        var icon_y = (Constants.SCREEN_HEIGHT * 25 / 360).toNumber();
        var icon_size = (Constants.SCREEN_WIDTH * 32 / 360).toNumber();
        dc.drawScaledBitmap(icon_x, icon_y, icon_size, icon_size, _icon);
    }
}

class DCCompendiumItemIcon extends WatchUi.Drawable {
    
    private var _icon as Graphics.BitmapReference;

    function initialize(item as Item) {
        Drawable.initialize({});
        _icon = item.getSpriteRef() as Graphics.BitmapReference;
    }

    function draw(dc as Toybox.Graphics.Dc) as Void {
        var icon_x = (Constants.SCREEN_WIDTH * 15 / 360).toNumber();
        var icon_y = (Constants.SCREEN_HEIGHT * 25 / 360).toNumber();
        var icon_size = (Constants.SCREEN_WIDTH * 32 / 360).toNumber();
        dc.drawScaledBitmap(icon_x, icon_y, icon_size, icon_size, _icon);
    }
}

class DCCompendiumEnemyListDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var enemy_id = item.getId();
        if (enemy_id == null) {
            return;
        }
        var enemy = $.Enemies.createEnemyFromId(enemy_id as Number);
        showEnemyDetails(enemy);
    }

    function showEnemyDetails(enemy as Enemy) as Void {
        var factory = new DCEnemyInfoFactory(enemy);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCGameMenuItemInfoDelegate(viewLoop), WatchUi.SLIDE_IMMEDIATE);
    }
}

class DCCompendiumItemListDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var item_id = item.getId();
        if (item_id == null) {
            return;
        }
        var compendium_item = $.Items.createItemFromId(item_id as Number);
        showItemDetails(compendium_item);
    }

    function showItemDetails(item as Item) as Void {
        var factory = new DCGameMenuItemInfoFactory(item);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCGameMenuItemInfoDelegate(viewLoop), WatchUi.SLIDE_IMMEDIATE);
    }
}
