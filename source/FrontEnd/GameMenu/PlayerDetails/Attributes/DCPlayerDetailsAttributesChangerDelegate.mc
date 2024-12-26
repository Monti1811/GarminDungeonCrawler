import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class DCPlayerDetailsAttributesChangerDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as WatchUi.Menu2;
    private var _delegate as DCPlayerDetailsAttributesDelegate;

    function initialize(view as WatchUi.Menu2, delegate as DCPlayerDetailsAttributesDelegate) {
        Menu2InputDelegate.initialize();
        _view = view;
        _delegate = delegate;
    }

    function onSelect(item as MenuItem) as Void {
        var player = getApp().getPlayer();
        var changed_attributes = _delegate.changed_attributes;
        var attribute_type = item.getId() as Symbol;
        var att_string = Constants.ATT_SYMBOL_TO_STR[attribute_type];
        var changeMenu = new WatchUi.Menu2({:title=>"Change " + att_string + " (" + changed_attributes[:available] + " points)"});
        changeMenu.addItem(new WatchUi.MenuItem(att_string + ": " + changed_attributes[attribute_type], null, :none, null));
        if (changed_attributes[:available] > 0 && changed_attributes[:total_used] < changed_attributes[:available]) {
            changeMenu.addItem(new WatchUi.MenuItem("Increase", "Increase " + att_string, attribute_type, null));
        }
        if (player.getAttribute(attribute_type) < changed_attributes[attribute_type]) {
            changeMenu.addItem(new WatchUi.MenuItem("Decrease", "Decrease " + att_string, attribute_type, null));
        }
        WatchUi.pushView(changeMenu, new DCPlayerDetailsAttributesChanger2Delegate(self, changeMenu, _delegate), WatchUi.SLIDE_UP);
    }

    public function updateMenu() as Void {
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

    public function onBack() as Void {
        showConfirmation();
    }

    function showConfirmation() {
        var message = "Do you want to use set the chosen attributes?";
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(
            dialog,
            new DCConfirmSetAttributes(getApp().getPlayer(), _delegate.changed_attributes),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

}

class DCPlayerDetailsAttributesChanger2Delegate extends WatchUi.Menu2InputDelegate {

    private var _view as WatchUi.Menu2;
    private var _parent as DCPlayerDetailsAttributesChangerDelegate;
    private var _delegate as DCPlayerDetailsAttributesDelegate;

    function initialize(parent as DCPlayerDetailsAttributesChangerDelegate, view as WatchUi.Menu2, delegate as DCPlayerDetailsAttributesDelegate) {
        Menu2InputDelegate.initialize();
        _view = view;
        _delegate = delegate;
        _parent = parent;
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _parent.updateMenu();
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
        var att_string = Constants.ATT_SYMBOL_TO_STR[attribute_type];
        _view.setTitle("Change " + att_string + " (" + points_available + " points)");
        var updated_item = new WatchUi.MenuItem(att_string + ": " + changed_attributes[attribute_type], null, attribute_type, null);
        _view.updateItem(updated_item, 0);
        if (changed_attributes[attribute_type] == getApp().getPlayer().getAttribute(attribute_type)) {
            _view.deleteItem(2);
        } else if (_view.getItem(2) == null && _view.getItem(1).getLabel().equals("Increase")) {
            _view.addItem(new WatchUi.MenuItem("Decrease", "Decrease " + att_string, attribute_type, null));
        }
        if (changed_attributes[:total_used] == changed_attributes[:available]) {
            _view.deleteItem(1);
        } else if (_view.getItem(2) == null && _view.getItem(1).getLabel().equals("Decrease")) {
            _view.addItem(new WatchUi.MenuItem("Increase", "Increase " + att_string, attribute_type, null));
            var decrease = _view.getItem(1);
            _view.deleteItem(1);
            _view.addItem(decrease);
        }
        WatchUi.requestUpdate();
    }

}




//! Input handler for the confirmation dialog
class DCConfirmSetAttributes extends WatchUi.ConfirmationDelegate {

    private var _player as Player;
    private var _changed_attributes as Dictionary<Symbol, Number>;

    //! Constructor
    //! @param view The app view
    public function initialize(player as Player, changed_attributes as Dictionary<Symbol, Number>) {
        ConfirmationDelegate.initialize();
        _player = player;
        _changed_attributes = changed_attributes;
    }

    //! Handle a confirmation selection
    //! @param value The confirmation value
    //! @return true if handled, false otherwise
    public function onResponse(value as Confirm) as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (value == WatchUi.CONFIRM_YES) {
            _player.setAttribute(:strength, _changed_attributes[:strength]);
            _player.setAttribute(:constitution, _changed_attributes[:constitution]);
            _player.setAttribute(:dexterity, _changed_attributes[:dexterity]);
            _player.setAttribute(:intelligence, _changed_attributes[:intelligence]);
            _player.setAttribute(:wisdom, _changed_attributes[:wisdom]);
            _player.setAttribute(:charisma, _changed_attributes[:charisma]);
            _player.setAttribute(:luck, _changed_attributes[:luck]);
            _player.setAttributePoints(_changed_attributes[:available] - _changed_attributes[:total_used]);
            WatchUi.requestUpdate();
        } else {
            _changed_attributes[:total_used] = 0;
            _changed_attributes[:strength] = _player.getAttribute(:strength);
            _changed_attributes[:constitution] = _player.getAttribute(:constitution);
            _changed_attributes[:dexterity] = _player.getAttribute(:dexterity);
            _changed_attributes[:intelligence] = _player.getAttribute(:intelligence);
            _changed_attributes[:wisdom] = _player.getAttribute(:wisdom);
            _changed_attributes[:charisma] = _player.getAttribute(:charisma);
            _changed_attributes[:luck] = _player.getAttribute(:luck);
        }
        return true;
    }

}