import Toybox.Lang;
import Toybox.WatchUi;


class DCGameMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as DCGameView;
    private const LOG_AMOUNT = 20;

    function initialize(view as DCGameView) {
        Menu2InputDelegate.initialize();
        _view = view;
    }

    function onSelect(item as MenuItem) as Void {
        var label = item.getId() as Symbol;
        if (label == :details) {
            openPlayerDetails();
        } else if (label == :inventory) {
            openInventory();
        } else if (label == :log ) {
            openLog();
        } else if (label == :settings) {
            openSettings();
        }
        //WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    //! Handle the back key being pressed
    function onBack() as Void {
        System.println("RPGActionMenuDelegate.Back");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    //! Handle the done item being selected
    function onDone() as Void {
        // WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function openPlayerDetails() as Void {
        var player = $.getApp().getPlayer() as Player;
        var factory = new DCPlayerDetailsFactory(player);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCPlayerDetailsDelegate(viewLoop), WatchUi.SLIDE_UP);
    }

    function openInventory() as Void {
        var inventoryMenu = new WatchUi.Menu2({:title=>"Inventory"});
        var player = $.getApp().getPlayer() as Player;
        var inventory = player.getInventory();
        for (var i = 0; i < inventory.size(); i++) {
            var item = inventory[i] as Item;
            inventoryMenu.addItem(new WatchUi.MenuItem(item.getName(), item.getDescription(), item, {:icon=>item.getSprite()}));
        }
        WatchUi.pushView(inventoryMenu, new DCInventoryDelegate(_view), WatchUi.SLIDE_UP);
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
}

class DCInventoryDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as DCGameView;

    function initialize(view as DCGameView) {
        Menu2InputDelegate.initialize();
        _view = view;
    }

    function onSelect(item as MenuItem) as Void {
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
        WatchUi.pushView(optionsMenu, new DCOptionsDelegate(item), WatchUi.SLIDE_UP);
    }
}

class DCOptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var _item as Item;

    function initialize(item as Item) {
        Menu2InputDelegate.initialize();
        _item = item;
    }

    function onSelect(item as MenuItem) as Void {
        item = item.getId() as Symbol;
        switch (item) {
            case :equip:
                getApp().getPlayer().equipItem(_item, _item.getItemSlot());
                break;
            case :drop:
                showConfirmation(_item, :drop);
                break;
            case :use:
                showConfirmation(_item, :use);
                break;
            case :info:
                showInfo(_item);
                break;
        }
    }

    function showConfirmation(item as Item, action as Symbol) {
        var message = "Do you want to use " + item.getName() + "?";
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(
            dialog,
            new DCConfirmUseItem(getApp().getPlayer(), item, action),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    function showInfo(item as Item) {
        var factory = new DCGameMenuItemInfoFactory(item);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCGameMenuItemInfoDelegate(viewLoop), WatchUi.SLIDE_IMMEDIATE);
    }
}

//! Input handler for the confirmation dialog
class DCConfirmUseItem extends WatchUi.ConfirmationDelegate {

    private var _item as Item;
    private var _player as Player;
    private var _action as Symbol;

    //! Constructor
    //! @param view The app view
    public function initialize(player as Player, item as Item, action as Symbol) {
        ConfirmationDelegate.initialize();
        _player = player;
        _item = item;
        _action = action;
    }

    //! Handle a confirmation selection
    //! @param value The confirmation value
    //! @return true if handled, false otherwise
    public function onResponse(value as Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            switch (_action) {
                case :use:
                    _player.onUseItem(_item);
                    break;
                case :drop:
                    _player.onDropItem(_item);
                    break;
            }
        }
        return true;
    }

}