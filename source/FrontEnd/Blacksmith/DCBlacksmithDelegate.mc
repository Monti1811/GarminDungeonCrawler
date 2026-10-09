import Toybox.WatchUi;
import Toybox.Lang;

class DCBlacksmithDelegate extends WatchUi.Menu2InputDelegate {

    private var _smith as Blacksmith;
    private var _filter as Symbol = :affordable;

    function initialize(smith as Blacksmith) {
        Menu2InputDelegate.initialize();
        _smith = smith;
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :upgrade:
                showUpgradeMenu();
                break;
            case :talk:
                WatchUi.pushView(new TextView(_smith.getDialog()), new TextDelegate(), WatchUi.SLIDE_UP);
                break;
        }
    }

    function onBack() as Void {
        _smith.closeForge();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function showUpgradeMenu() as Void {
        _smith.updateForgeTitle();
        var upgradable = getUpgradableItems();
        var menu = new WatchUi.Menu2({:title => _smith.getForgeTitle()});
        menu.addItem(new WatchUi.MenuItem("Filter", getFilterStr(), :filter, null));
        for (var i = 0; i < upgradable.size(); i++) {
            var item = upgradable[i];
            var icon = new DCItemIcon(item);
            menu.addItem(new WatchUi.IconMenuItem(item.getName(), getUpgradeSubtitle(item), item, icon, null));
        }
        WatchUi.pushView(menu, new DCBlacksmithItemDelegate(_smith, self), WatchUi.SLIDE_UP);
    }

    function setFilter(filter as Symbol) as Void {
        _filter = filter;
    }

    function getFilterStr() as String {
        if (_filter == :affordable) {
            return "Can afford";
        }
        return "All items";
    }

    function passesFilter(item as Item) as Boolean {
        if (_filter == :affordable) {
            return canAffordUpgrade(item);
        }
        return true;
    }

    function canAffordUpgrade(item as Item) as Boolean {
        if (!(item instanceof EquippableItem)) {
            return false;
        }
        var equipp = item as EquippableItem;
        if (!equipp.canUpgrade()) {
            return false;
        }
        var mat_id = MaterialUtil.getMaterialForItem(item);
        if (mat_id == -1) {
            return false;
        }
        var player = getApp().getPlayer();
        if (player.getGold() < $.Constants.SMITH_COST_GOLD[equipp.upgrade_level]) {
            return false;
        }
        var mat_item = player.getInventory().find(mat_id);
        if (mat_item == null) {
            return false;
        }
        return mat_item.amount >= $.Constants.SMITH_COST_MATERIAL[equipp.upgrade_level];
    }

    function getUpgradableItems() as Array<Item> {
        var player = getApp().getPlayer();
        var result = [] as Array<Item>;
        var inventory_items = player.getInventory().getItems();
        for (var i = 0; i < inventory_items.size(); i++) {
            if (MaterialUtil.getMaterialForItem(inventory_items[i]) != -1 && passesFilter(inventory_items[i])) {
                result.add(inventory_items[i]);
            }
        }
        var equipped_items = player.getEquippedItems();
        for (var j = 0; j < equipped_items.size(); j++) {
            if (MaterialUtil.getMaterialForItem(equipped_items[j]) != -1 && passesFilter(equipped_items[j])) {
                result.add(equipped_items[j]);
            }
        }
        return result;
    }

    function getUpgradeSubtitle(item as Item) as String {
        if (!(item instanceof EquippableItem)) {
            return "";
        }
        var equipp = item as EquippableItem;
        if (!equipp.canUpgrade()) {
            return "Maximum level";
        }
        var gold_cost = $.Constants.SMITH_COST_GOLD[equipp.upgrade_level];
        var mat_cost = $.Constants.SMITH_COST_MATERIAL[equipp.upgrade_level];
        return gold_cost + " gold + " + mat_cost + "x " + getMaterialName(item);
    }

    static function getMaterialName(item as Item) as String {
        var mat_id = MaterialUtil.getMaterialForItem(item);
        var mat = Items.createItemFromId(mat_id);
        if (mat != null) {
            return mat.getName();
        }
        return "Material";
    }

}

class DCBlacksmithItemDelegate extends WatchUi.Menu2InputDelegate {

    private var _smith as Blacksmith;
    private var _main_delegate as DCBlacksmithDelegate;

    function initialize(smith as Blacksmith, main_delegate as DCBlacksmithDelegate) {
        Menu2InputDelegate.initialize();
        _smith = smith;
        _main_delegate = main_delegate;
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (id instanceof Symbol) {
            if (id == :filter) {
                openFilterMenu();
            }
            return;
        }
        var target = id as Item;
        var options_menu = new WatchUi.Menu2({:title => target.getName()});
        options_menu.addItem(new WatchUi.MenuItem("Upgrade", null, :upgrade, null));
        options_menu.addItem(new WatchUi.MenuItem("Info", "More information", :info, null));
        WatchUi.pushView(options_menu, new DCBlacksmithOptionsDelegate(_smith, _main_delegate, target), WatchUi.SLIDE_UP);
    }

    function openFilterMenu() as Void {
        var menu = new WatchUi.Menu2({:title => "Filter"});
        menu.addItem(new WatchUi.MenuItem("All items", "Regardless of resources", :filter_all, null));
        menu.addItem(new WatchUi.MenuItem("Can afford", "Enough gold + materials", :filter_affordable, null));
        WatchUi.pushView(menu, new DCBlacksmithFilterDelegate(_main_delegate), WatchUi.SLIDE_UP);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}

class DCBlacksmithOptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var _smith as Blacksmith;
    private var _main_delegate as DCBlacksmithDelegate;
    private var _target as Item;

    function initialize(smith as Blacksmith, main_delegate as DCBlacksmithDelegate, target as Item) {
        Menu2InputDelegate.initialize();
        _smith = smith;
        _main_delegate = main_delegate;
        _target = target;
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :upgrade:
                doUpgrade();
                break;
            case :info:
                showInfo();
                break;
        }
    }

    function doUpgrade() as Void {
        if (!(_target instanceof EquippableItem)) {
            return;
        }
        var equipp = _target as EquippableItem;
        var player = getApp().getPlayer();

        if (!equipp.canUpgrade()) {
            WatchUi.showToast("Maximum level reached", {:icon => $.Rez.Drawables.cancelToastIcon});
            return;
        }

        var target_index = equipp.upgrade_level;
        var gold_cost = $.Constants.SMITH_COST_GOLD[target_index];
        var mat_cost = $.Constants.SMITH_COST_MATERIAL[target_index];
        var mat_id = MaterialUtil.getMaterialForItem(_target);
        var inventory = player.getInventory();
        var mat_item = inventory.find(mat_id);
        var available = 0;
        if (mat_item != null) {
            available = mat_item.amount;
        }

        if (available < mat_cost) {
            var mat_name = DCBlacksmithDelegate.getMaterialName(_target);
            WatchUi.showToast("Need " + mat_cost + "x " + mat_name, {:icon => $.Rez.Drawables.cancelToastIcon});
            return;
        }
        if (!player.doGoldDelta(-gold_cost)) {
            WatchUi.showToast("Not enough gold", {:icon => $.Rez.Drawables.cancelToastIcon});
            return;
        }

        inventory.removeMultiple(mat_item as Item, mat_cost);
        equipp.upgrade_level += 1;
        $.Achievements.bump("upgrades", 1);
        if (equipp.upgrade_level >= $.Constants.SMITH_COST_GOLD.size()) {
            $.Achievements.unlock("masterwork");
        }
        WatchUi.showToast(equipp.getName() + " upgraded!", {:icon => _target.getSprite()});

        _smith.updateForgeTitle();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _main_delegate.showUpgradeMenu();
    }

    function showInfo() as Void {
        var factory = new DCGameMenuItemInfoFactory(_target);
        var view_loop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(view_loop, new DCGameMenuItemInfoDelegate(view_loop), WatchUi.SLIDE_IMMEDIATE);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}

class DCBlacksmithFilterDelegate extends WatchUi.Menu2InputDelegate {

    private var _main_delegate as DCBlacksmithDelegate;

    function initialize(main_delegate as DCBlacksmithDelegate) {
        Menu2InputDelegate.initialize();
        _main_delegate = main_delegate;
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        if (type == :filter_all) {
            _main_delegate.setFilter(:all);
        } else if (type == :filter_affordable) {
            _main_delegate.setFilter(:affordable);
        } else {
            return;
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _main_delegate.showUpgradeMenu();
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}
