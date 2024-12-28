//
// Copyright 2015-2023 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
import Toybox.WatchUi;

var itemslot as ItemSlot = HEAD;

//! ViewLoop Delegate for handling the main primate views
//! and indicates the current page
class DCPlayerDetailsEquipmentDelegate extends WatchUi.BehaviorDelegate {

    private const num_to_equipslot as Array<ItemSlot> = [HEAD, CHEST, BACK, LEGS, FEET, LEFT_HAND, RIGHT_HAND, ACCESSORY];

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Detect Menu button input
    function onKey(keyEvent as KeyEvent) as Boolean {
        if (keyEvent.getKey() == KEY_ENTER) {
            var menu = new WatchUi.Menu2({:title=>"Equipped Items"});
            for (var i = 0; i < 8; i++) {
                var slot = num_to_equipslot[i] as ItemSlot;
                var item = getApp().getPlayer().getEquip(slot) as Item?;
                var name = "No equipped item";
                if (item != null) {
                    name = item.getName();
                }
                menu.addItem(new WatchUi.MenuItem(name, Constants.EQUIPSLOT_TO_STR[slot], item, null));
            }

            WatchUi.pushView(menu, new DCPlayerDetailsEquipment2Delegate(), SLIDE_UP);
        }
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(SLIDE_DOWN);
        return true;
    }

}

class DCPlayerDetailsEquipment2Delegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // Detect Menu button input
    function onSelect(menuItem as MenuItem) as Void {
        var item = menuItem.getId() as Item?;
        var menu = new WatchUi.Menu2({:title=>"Item options"});
        if (item != null) {
            menu.addItem(new WatchUi.MenuItem("Unequip", null, :unequip, null));
            menu.addItem(new WatchUi.MenuItem("Drop", null, :drop, null));
            menu.addItem(new WatchUi.MenuItem("Info", "More information", :info, null));
        } else {
            menu.addItem(new WatchUi.MenuItem("Equip", menuItem.getSubLabel(), :equip, null));
        }

        WatchUi.pushView(menu, new DCPlayerDetailsEquipmentOptionsDelegate(item), SLIDE_UP);
    }

}

class DCPlayerDetailsEquipmentOptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var _item as Item;

    function initialize(item as Item) {
        Menu2InputDelegate.initialize();
        _item = item;
    }

    // Detect Menu button input
    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :equip:
                openInventoryForSlot(item.getSubLabel() as String);
                break;
            case :unequip:
                getApp().getPlayer().unequipItem(_item, _item.getItemSlot());
                WatchUi.popView(SLIDE_DOWN);
                WatchUi.popView(SLIDE_DOWN);
                WatchUi.requestUpdate();
                break;
            case :drop:
                showConfirmation("Do you want to drop " + _item.getName() + "?",_item, :drop);
                break;
            case :info:
                showInfo(_item);
                break;
        }
    }

    function openInventoryForSlot(itemslot_str as String?) as Void {
        var itemslot = Constants.STR_TO_EQUIPSLOT[itemslot_str] as ItemSlot;
        var inventoryMenu = new WatchUi.Menu2({:title=>"Inventory"});
        var player = $.getApp().getPlayer() as Player;
        var inventory_items = player.getInventory().getItems();
        for (var i = 0; i < inventory_items.size(); i++) {
            var item = inventory_items[i] as Item;
            if (item.getItemSlot() == itemslot) {
                var amount = item.getAmount();
                inventoryMenu.addItem(new WatchUi.MenuItem(item.getName() + " x" + amount, item.getDescription(), item, {:icon=>item.getSprite()}));
            }
        }
        WatchUi.pushView(inventoryMenu, new DCInventoryEquipDelegate(), WatchUi.SLIDE_UP);
    }

    function showConfirmation(message as String, item as Item, action as Symbol) {
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(
            dialog,
            new DCConfirmUseItem(getApp().getPlayer(), item, action, 2),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    function showInfo(item as Item) {
        var factory = new DCGameMenuItemInfoFactory(item);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCGameMenuItemInfoDelegate(viewLoop), WatchUi.SLIDE_IMMEDIATE);
    }

}

class DCInventoryEquipDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        item = item.getId() as Item;
        var player = getApp().getPlayer() as Player;
        player.equipItem(item, item.getItemSlot(), true);
        WatchUi.popView(SLIDE_DOWN);
        WatchUi.popView(SLIDE_DOWN);
        WatchUi.popView(SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

}