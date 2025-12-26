import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;

class DCSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _settingsMenu as Menu2;

    function initialize(settingsMenu as Menu2) {
        Menu2InputDelegate.initialize();
        _settingsMenu = settingsMenu;
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :rooms:
                showRoomsSettings();
                break;
            case :save:
                showSaveSettings();
                break;
            case :movement:
                showMovementSettings();
                break;

        }
    }

    function showRoomsSettings() as Void {
        var max_rooms = Storage.getValue("rooms_amount").toString();
        var min_room_size = Storage.getValue("min_room_size").toString();
        var max_room_size = Storage.getValue("max_room_size").toString();
        var roomsSettings = new WatchUi.Menu2({:title=>"Rooms settings"});
        roomsSettings.addItem(new WatchUi.MenuItem("Max rooms per dungeon", max_rooms + "x" + max_rooms, :amount, null));
        roomsSettings.addItem(new WatchUi.MenuItem("Min room size", min_room_size + "x" + min_room_size, :min, null));
        roomsSettings.addItem(new WatchUi.MenuItem("Max room size", max_room_size + "x" + max_room_size, :max, null));

        WatchUi.pushView(roomsSettings, new DCRoomsSettingsDelegate(roomsSettings), WatchUi.SLIDE_UP);
    }

    function showSaveSettings() as Void {
        var exit_enabled = Storage.getValue("save_on_exit");
        var auto_save = Storage.getValue("autosave") as Number;
        var saveSettings = new WatchUi.Menu2({:title=>"Save settings"});
        saveSettings.addItem(new WatchUi.ToggleMenuItem("Save on exit", {:enabled=>"Automatic save when exiting",:disabled=>"No save when exiting"}, :exit, exit_enabled, null));
        saveSettings.addItem(new WatchUi.MenuItem("Autosave", $.Settings.getAutoSaveString(auto_save), :autosave, null));
        saveSettings.addItem(new WatchUi.MenuItem("Reset all data", "Reset all saves and configurations", :reset, null));

        WatchUi.pushView(saveSettings, new DCSaveSettingsDelegate(saveSettings), WatchUi.SLIDE_UP);
    }

    function showMovementSettings() as Void {

        var movementSettings = new WatchUi.Menu2({:title=>"Movement settings"});
        movementSettings.addItem(new WatchUi.MenuItem("Off", "No step requirement", 0, null));
        movementSettings.addItem(new WatchUi.MenuItem("5 steps per turn", null, 5, null));
        movementSettings.addItem(new WatchUi.MenuItem("10 steps per turn", null, 10, null));
        movementSettings.addItem(new WatchUi.MenuItem("20 steps per turn", null, 20, null));
        movementSettings.addItem(new WatchUi.MenuItem("50 steps per turn", null, 50, null));

        WatchUi.pushView(movementSettings, new DCMovementSettingsDelegate(_settingsMenu), WatchUi.SLIDE_UP);
    }
    
}

class DCMovementSettingsDelegate extends WatchUi.Menu2InputDelegate {

    private const MOVEMENT_ITEM_INDEX = 2;
    private var _parent as Menu2;

    function initialize(parent as Menu2) {
        Menu2InputDelegate.initialize();
        _parent = parent;
    }

    function onSelect(item as MenuItem) as Void {
        var steps = item.getId() as Number;
        $.Settings.setValue("steps_per_turn", steps);
        $.StepGate.updateFromSetting(steps);
        _parent.updateItem(new WatchUi.MenuItem("Movement", $.Settings.getStepsPerTurnString(steps), :movement, null), MOVEMENT_ITEM_INDEX);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}



