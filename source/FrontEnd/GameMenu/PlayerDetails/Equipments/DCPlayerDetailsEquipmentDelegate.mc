//
// Copyright 2015-2023 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
import Toybox.WatchUi;

//! ViewLoop Delegate for handling the main primate views
//! and indicates the current page
class DCPlayerDetailsEquipmentDelegate extends WatchUi.BehaviorDelegate {

    private var _view as DCPlayerDetailsEquipmentsView;
    private const num_to_equipslot as Array<ItemSlot> = [HEAD, CHEST, BACK, LEGS, FEET, LEFT_HAND, RIGHT_HAND, ACCESSORY];

    function initialize(view as DCPlayerDetailsEquipmentsView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Detect Menu button input
    function onKey(keyEvent as KeyEvent) as Void {
        if (keyEvent.getKey() == KEY_ENTER) {
            var menu = new WatchUi.Menu2({:title=>"Equipped Items"});
            for (var i = 0; i < 8; i++) {
                var slot = num_to_equipslot[i];
                var item = _view._player.getEquip(slot);
                if (item != null) {
                    menu.addItem(new WatchUi.MenuItem(item.getName(), null, item, slot));
                }
            }

            WatchUi.pushView(menu, new DCPlayerDetailsEquipment2Delegate(_view), SLIDE_UP);
        }
        return true;
    }

}

class DCPlayerDetailsEquipment2Delegate extends WatchUi.Menu2InputDelegate {

    private var _view as DCPlayerDetailsEquipmentsView;

    function initialize(view as DCPlayerDetailsEquipmentsView) {
        Menu2InputDelegate.initialize();
        _view = view;
    }

    // Detect Menu button input
    function onSelect(item as MenuItem) as Void {
        item = item.getId() as Item;
        var menu = new WatchUi.Menu2({:title=>"Item options"});
        menu.addItem(new WatchUi.MenuItem("Unequip", null, :unequip, null));
        menu.addItem(new WatchUi.MenuItem("Drop", null, :drop, null));
        menu.addItem(new WatchUi.MenuItem("Info", "More information", :info, null));

        WatchUi.pushView(menu, new DCPlayerDetailsEquipmentOptionsDelegate(_view, item), SLIDE_UP);

        return true;
    }

}

class DCPlayerDetailsEquipmentOptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as DCPlayerDetailsEquipmentsView;
    private var _item as Item;

    function initialize(view as DCPlayerDetailsEquipmentsView, item as Item) {
        Menu2InputDelegate.initialize();
        _view = view;
        _item = item;
    }

    // Detect Menu button input
    function onSelect(item as MenuItem) as Void {
        item = item.getId() as Symbol;
        switch (item) {
            case :equip:
                getApp().getPlayer().unequipItem(_item, _item.getItemSlot());
                break;
            case :drop:
                showConfirmation("Do you want to drop " + item.getName() + "?",_item, :drop);
                break;
            case :use:
                showConfirmation("Do you want to use " + item.getName() + "?", _item, :use);
                break;
            case :info:
                showInfo(_item);
                break;
        }
    }

    function showConfirmation(message as String, item as Item, action as Symbol) {
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