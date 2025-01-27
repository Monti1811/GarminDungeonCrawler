import Toybox.Lang;
import Toybox.WatchUi;


class DCGameMenuDelegate extends WatchUi.Menu2InputDelegate {

    private const LOG_AMOUNT = 20;
    var inventory_filter as Symbol | ItemType = :all;
    var item_list as Array<Item>?;

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var label = item.getId() as Symbol;
        if (label == :player) {
            openPlayerDetails();
        } else if (label == :inventory) {
            openInventory();
        } else if (label == :map ) {
            openMap();
        } else if (label == :save) {
            saveGame();
        } else if (label == :log ) {
            openLog();
        } else if (label == :settings) {
            openSettings();
        }
    }

    //! Handle the back key being pressed
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    //! Handle the done item being selected
    function onDone() as Void {
    }

    function openPlayerDetails() as Void {
        var player = $.getApp().getPlayer() as Player;
        var factory = new DCPlayerDetailsFactory(player);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCPlayerDetailsDelegate(viewLoop), WatchUi.SLIDE_UP);
    }

    function createInventoryMenuItem(item as Item) as MenuItem {
        var amount = item.getAmount();
        var icon = new DCItemIcon(item);
        return new WatchUi.IconMenuItem(item.getName() + " x" + amount, item.getDescription(), item, icon, null);
    }

    function openInventory() as Void {
        if (inventory_filter != :all) {
            openItemTypeInventory(inventory_filter, $.Constants.ITEMTYPE_TO_STR[inventory_filter] + " Items");
            return;
        }
        var player = $.getApp().getPlayer() as Player;
        var inventory = player.getInventory();
        var inventory_items = inventory.getItems();
        var weight_items = inventory.getCurrentItemWeight() as Numeric;
        var max_weight_items = inventory.getMaxItemWeight() as Numeric;
        var inventoryMenu = new WatchUi.Menu2({:title=>"Inventory (" + weight_items.format("%.1f") + "/" + max_weight_items + ")"});
        inventoryMenu.addItem(new WatchUi.MenuItem("Filter/Sort", "All", :filter, null));
        
        for (var i = 0; i < inventory_items.size(); i++) {
            var item = inventory_items[i] as Item;
            inventoryMenu.addItem(createInventoryMenuItem(item));
        }
        WatchUi.pushView(inventoryMenu, new DCInventoryDelegate(self), WatchUi.SLIDE_UP);
    }

    function openItemTypeInventory(item_type as ItemType, filter_str as String) as Void {
        var player = $.getApp().getPlayer() as Player;
        var inventory = player.getInventory();
        var inventory_items = inventory.getItems();
        var weight_items = inventory.getCurrentItemWeight() as Numeric;
        var max_weight_items = inventory.getMaxItemWeight() as Numeric;
        var inventoryMenu = new WatchUi.Menu2({:title=>"Inventory (" + weight_items.format("%.1f") + "/" + max_weight_items + ")"});
        inventoryMenu.addItem(new WatchUi.MenuItem("Filter", filter_str, :filter, null));
        for (var i = 0; i < inventory_items.size(); i++) {
            var item = inventory_items[i] as Item;
            if (item.type == item_type) {
                inventoryMenu.addItem(createInventoryMenuItem(item));
            }
        }
        WatchUi.pushView(inventoryMenu, new DCInventoryDelegate(self), WatchUi.SLIDE_UP);
    }

    function openMap() as Void {
        var map = new DCMapView();
        var delegate = new DCMapDelegate(map);
        WatchUi.pushView(map, delegate, WatchUi.SLIDE_UP);
    }

    function openLog() as Void {
        var logMenu = new WatchUi.Menu2({:title=>"Log"});
        var log = $.Log.getLastMessages(LOG_AMOUNT);
        for (var i = 0; i < log.size(); i++) {
            logMenu.addItem(new WatchUi.MenuItem(log[i], null, null, null));
        }
        WatchUi.pushView(logMenu, new WatchUi.Menu2InputDelegate(), WatchUi.SLIDE_UP);
    }

    function openSettings() as Void {
        var settingsMenu = new WatchUi.Menu2({:title=>"Settings"});
        settingsMenu.addItem(new WatchUi.MenuItem("Sound", "Change sound settings", null, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Graphics", "Change graphics settings", null, null));
        WatchUi.pushView(settingsMenu, new WatchUi.Menu2InputDelegate(), WatchUi.SLIDE_UP);
    }

    function saveGame() as Void {
        $.SaveData.saveGame();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.showToast("Saved game", {:icon=>Rez.Drawables.saveToastIcon});
    }
}

class DCItemIcon extends WatchUi.Drawable {
    
    private var _icon as BitmapResource;

    function initialize(item as Item) {
        Drawable.initialize({});
        _icon = item.getSpriteRef() as BitmapResource;
    }

    function draw(dc as Toybox.Graphics.Dc) as Void {
        dc.drawScaledBitmap(15, 25, 32, 32, _icon);
    }
}

class DCInventoryDelegate extends WatchUi.Menu2InputDelegate {

    private var _delegate as DCGameMenuDelegate;

    function initialize(delegate as DCGameMenuDelegate) {
        Menu2InputDelegate.initialize();
        _delegate = delegate;
    }

    function onSelect(item as MenuItem) as Void {
        if (item.getId() == :filter) {
            showFilter();
            return;
        }
        item = item.getId() as Item;
        var menuitems = [] as Array<MenuItem>;
        if (item instanceof WeaponItem || item instanceof ArmorItem) {
            menuitems.add(new WatchUi.MenuItem("Equip", null, :equip, null));
            menuitems.add(new WatchUi.MenuItem("Drop", null, :drop, null));
            menuitems.add(new WatchUi.MenuItem("Info", "More information", :info, null));
        } else if (item instanceof ConsumableItem) {
            menuitems.add(new WatchUi.MenuItem("Use", null, :use, null));
            menuitems.add(new WatchUi.MenuItem("Drop", null, :drop, null));
            menuitems.add(new WatchUi.MenuItem("Info", "More information", :info, null));
        }
        showOptions(item, menuitems);
    }

    function showOptions(item as Item, options as Array<MenuItem>) {
        var optionsMenu = new WatchUi.Menu2({:title=>"Inventory"});
        for (var i = 0; i < options.size(); i++) {
            optionsMenu.addItem(options[i]);
        }
        WatchUi.pushView(optionsMenu, new DCOptionsDelegate(item, _delegate), WatchUi.SLIDE_UP);
    }

    function showFilter() {
        var player = $.getApp().getPlayer() as Player;
        var inventoryMenu = new WatchUi.Menu2({:title=>"Filter/Sort"});
        // Filters
        inventoryMenu.addItem(new WatchUi.MenuItem("All", null, :all, null));
        inventoryMenu.addItem(new WatchUi.MenuItem("Weapons", null, :weapons, null));
        inventoryMenu.addItem(new WatchUi.MenuItem("Armor", null, :armor, null));
        inventoryMenu.addItem(new WatchUi.MenuItem("Consumables", null, :consumables, null));
        // Sort 
        inventoryMenu.addItem(new WatchUi.MenuItem("Sort by name", null, :sort_name, null));
        inventoryMenu.addItem(new WatchUi.MenuItem("Sort by weight", null, :sort_weight, null));
        inventoryMenu.addItem(new WatchUi.MenuItem("Sort by value", null, :sort_value, null));
        WatchUi.pushView(inventoryMenu, new DCInventoryFilterDelegate(_delegate), WatchUi.SLIDE_UP);
    }
}

class DCInventoryFilterDelegate extends WatchUi.Menu2InputDelegate {

    private var _delegate as DCGameMenuDelegate;

    function initialize(delegate as DCGameMenuDelegate) {
        Menu2InputDelegate.initialize();
        _delegate = delegate;
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :all:
                _delegate.inventory_filter = :all;
                break;
            case :weapons:
                _delegate.inventory_filter = WEAPON;
                break;
            case :armor:
                _delegate.inventory_filter = ARMOR;
                break;
            case :consumables:
                _delegate.inventory_filter = CONSUMABLE;
                break;
            case :sort_name:
            case :sort_weight:
            case :sort_value:
                // Add menu where user is asked if they want to sort ascending or descending
                var sortMenu = new WatchUi.Menu2({:title:"Sort by"});
                sortMenu.addItem(new WatchUi.MenuItem("Ascending", null, true, null));
                sortMenu.addItem(new WatchUi.MenuItem("Descending", null, false, null));
                WatchUi.pushView(sortMenu, new DCInventorySortDelegate(_delegate, type), WatchUi.SLIDE_UP);
                return;
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _delegate.openInventory();
    }
}

class DCInventorySortDelegate extends WatchUi.Menu2InputDelegate {

    private var _delegate as DCGameMenuDelegate;
    private var _sort_type as Symbol;

    function initialize(delegate as DCGameMenuDelegate, sort_type as Symbol) {
        Menu2InputDelegate.initialize();
        _delegate = delegate;
        _sort_type = sort_type;
    }

    function onSelect(item as MenuItem) as Void {
        var is_ascending = item.getId() as Boolean;
        var sort_comparator = null;
        if (_sort_type == :sort_name) {
            sort_comparator = new NameCompare(type);
        } else if (_sort_type == :sort_weight) {
            sort_comparator = new WeightCompare(type);
        } else if (_sort_type == :sort_value) {
            sort_comparator = new ValueCompare(type);
        }
        var player = $.getApp().getPlayer() as Player;
        var inventory = player.getInventory();
        inventory.sortItems(_sort_type, sort);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _delegate.openInventory();
    }
}


class DCOptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var _item as Item;
    private var _delegate as DCGameMenuDelegate;

    function initialize(item as Item, delegate as DCGameMenuDelegate) {
        Menu2InputDelegate.initialize();
        _item = item;
        _delegate = delegate;
    }

    private function updateInventoryMenu() as Void {
        _delegate.openInventory();
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :equip:
                if (_item.getItemSlot() == EITHER_HAND) {
                    var equipMenu = new WatchUi.Menu2({:title=>"Equip Slot"});
                    equipMenu.addItem(new WatchUi.MenuItem("Left Hand", null, :left, null));
                    equipMenu.addItem(new WatchUi.MenuItem("Right Hand", null, :right, null));
                    WatchUi.pushView(equipMenu, new DCEquipOptionsDelegate(_item, _delegate), WatchUi.SLIDE_UP);
                    break;
                }
                var success = getApp().getPlayer().equipItem(_item, _item.getItemSlot(), true);
                if (!success) {
                    WatchUi.showToast("Could not equip item", {:icon=>Rez.Drawables.cancelToastIcon});
                }
                WatchUi.popView(SLIDE_DOWN);
                WatchUi.popView(SLIDE_DOWN);
                updateInventoryMenu();
                break;
            case :drop:
                showConfirmation("Do you want to drop " + _item.getName() + "?",_item, :drop);
                break;
            case :use:
                showConfirmation("Do you want to use " + _item.getName() + "?", _item, :use);
                break;
            case :info:
                showInfo(_item);
                break;
            case :delete:
                showConfirmation("Do you want to delete " + _item.getName() + "?", _item, :delete);
                break;
        }
    }

    function showConfirmation(message as String, item as Item, action as Symbol) {
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(
            dialog,
            new DCConfirmUseItem(getApp().getPlayer(), item, action, 3),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    function showInfo(item as Item) {
        var factory = new DCGameMenuItemInfoFactory(item);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCGameMenuItemInfoDelegate(viewLoop), WatchUi.SLIDE_IMMEDIATE);
    }
}

class DCEquipOptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var _item as Item;
    private var _delegate as DCGameMenuDelegate;

    function initialize(item as Item, delegate as DCGameMenuDelegate) {
        Menu2InputDelegate.initialize();
        _item = item;
        _delegate = delegate;
    }

    private function updateInventoryMenu() as Void {
        _delegate.openInventory();
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        var success = false;
        switch (type) {
            case :left:
                success = getApp().getPlayer().equipItem(_item, LEFT_HAND, true);
                break;
            case :right:
                success = getApp().getPlayer().equipItem(_item, RIGHT_HAND, true); 
                break;    
        }
        if (!success) {
            WatchUi.showToast("Could not equip item", {:icon=>Rez.Drawables.cancelToastIcon});
        }
        WatchUi.popView(SLIDE_DOWN);
        WatchUi.popView(SLIDE_DOWN);
        WatchUi.popView(SLIDE_DOWN);
        updateInventoryMenu();
    }
}

//! Input handler for the confirmation dialog
class DCConfirmUseItem extends WatchUi.ConfirmationDelegate {

    private var _item as Item;
    private var _player as Player;
    private var _action as Symbol;
    private var _screens_to_pop as Number = 1;

    //! Constructor
    //! @param view The app view
    public function initialize(player as Player, item as Item, action as Symbol, screens_to_pop as Number) {
        ConfirmationDelegate.initialize();
        _player = player;
        _item = item;
        _action = action;
        _screens_to_pop = screens_to_pop;
    }

    //! Handle a confirmation selection
    //! @param value The confirmation value
    //! @return true if handled, false otherwise
    public function onResponse(value as Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            switch (_action) {
                case :use:
                    _player.onUseItem(_item);
                    $.Game.turns.doTurn(SKIPPING);
                    break;
                case :drop:
                    if (_item.isEquipped()) {
                        _player.unequipItem(_item.getItemSlot());
                    }
                    if (_item.isInInventory()) {
                        _player.dropItem(_item);
                    }
                    break;
                case :delete:
                    _player.deleteItem(_item);
                    break;
            }
            for (var i = 0; i < _screens_to_pop; i++) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            }
            WatchUi.requestUpdate();
        }
        return true;
    }

}