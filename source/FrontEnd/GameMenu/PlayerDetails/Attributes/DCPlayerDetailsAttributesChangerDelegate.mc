import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class DCPlayerDetailsAttributesChangerDelegate extends WatchUi.Menu2InputDelegate {

    private const symbol_to_string = {
        :strength => "Strength",
        :constitution => "Constitution",
        :dexterity => "Dexterity",
        :intelligence => "Intelligence",
        :wisdom => "Wisdom",
        :charisma => "Charisma",
        :luck => "Luck"
    };
    private var _view as WatchUi.Menu2;
    private var _delegate as DCPlayerDetailsAttributesDelegate;

    function initialize(view as WatchUi.Menu2, delegate as DCPlayerDetailsAttributesDelegate) {
        Menu2InputDelegate.initialize();
        _view = view;
        _delegate = delegate;
    }

    function onSelect(item as MenuItem) as Void {
        var player = getApp().getPlayer();
        var free_attribute_points = player.getAttributePoints();
        var changed_attributes = _delegate.changed_attributes;
        var attribute_type = item.getId() as Symbol;
        var changeMenu = new WatchUi.Menu2({:title=>"Change " + symbol_to_string[attribute_type] + " (" + free_attribute_points + " points)"});
        changeMenu.addItem(new WatchUi.MenuItem("Current " + symbol_to_string[attribute_type] + ": " + player.getAttribute(attribute_type), null, :none, null));
        if (changed_attributes[:available] > 0 && changed_attributes[:total_used] < changed_attributes[:available]) {
            changeMenu.addItem(new WatchUi.MenuItem("Increase", "Increase " + symbol_to_string[attribute_type], attribute_type, null));
        }
        if (player.getAttribute(attribute_type) < changed_attributes[attribute_type]) {
            changeMenu.addItem(new WatchUi.MenuItem("Decrease", "Decrease " + symbol_to_string[attribute_type], attribute_type, null));
        }
        WatchUi.pushView(changeMenu, new DCPlayerDetailsAttributesChanger2Delegate(_view, _delegate), WatchUi.SLIDE_UP);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        updateMenu();
    }

    function updateMenu() as Void {
        var player = getApp().getPlayer();
        var changed_attributes = _delegate.changed_attributes;
        var points_available = changed_attributes[:available] - changed_attributes[:total_used];
        _view.setTitle("Change Attributes (" + points_available + " points)");
        _view.updateItem(new WatchUi.MenuItem("Strength: " + changed_attributes[:strength], null, :strength, null), 0);
        _view.updateItem(new WatchUi.MenuItem("Constitution: " + changed_attributes[:constitution], null, :constitution, null), 1);
        _view.updateItem(new WatchUi.MenuItem("Dexterity: " + changed_attributes[:dexterity], null, :dexterity, null), 2);
        _view.updateItem(new WatchUi.MenuItem("Intelligence: " + changed_attributes[:intelligence], null, :intelligence, null), 3);
        _view.updateItem(new WatchUi.MenuItem("Wisdom: " + changed_attributes[:wisdom], null, :wisdom, null), 4);
        _view.updateItem(new WatchUi.MenuItem("Charisma: " + changed_attributes[:charisma], null, :charisma, null), 5);
        _view.updateItem(new WatchUi.MenuItem("Luck: " + changed_attributes[:luck], null, :luck, null), 6);
    }

}

class DCPlayerDetailsAttributesChanger2Delegate extends WatchUi.Menu2InputDelegate {

    private const symbol_to_string = {
        :strength => "Strength",
        :constitution => "Constitution",
        :dexterity => "Dexterity",
        :intelligence => "Intelligence",
        :wisdom => "Wisdom",
        :charisma => "Charisma",
        :luck => "Luck"
    };
    private var _parent as WatchUi.Menu2;
    private var _delegate as DCPlayerDetailsAttributesDelegate;

    function initialize(parent as WatchUi.Menu2, delegate as DCPlayerDetailsAttributesDelegate) {
        Menu2InputDelegate.initialize();
        _parent = parent;
        _delegate = delegate;
    }

    function onSelect(item as MenuItem) as Void {
        var changed_attributes = _delegate.changed_attributes;
        var attribute_type = item.getId() as Symbol;
        if (attribute_type == :none) {
            return;
        }
        if (changed_attributes[:available] <= 0) {
            return;
        }
        if (item.getLabel().equals("Increase")) {
            changed_attributes[:total_used] += 1;
            changed_attributes[attribute_type] += 1;
        } else if (item.getLabel().equals("Decrease")) {
            changed_attributes[:total_used] -= 1;
            changed_attributes[attribute_type] -= 1;
        }
        var points_available = changed_attributes[:available] - changed_attributes[:total_used];
        _parent.setTitle("Change " + symbol_to_string[attribute_type] + " (" + points_available + " points)");
        var updated_item = new WatchUi.MenuItem(symbol_to_string[attribute_type] + ": " + changed_attributes[attribute_type], null, attribute_type, null);
        _parent.updateItem(updated_item, 1);
        WatchUi.requestUpdate();
    }

}