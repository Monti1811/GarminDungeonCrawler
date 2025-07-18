import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;

class DCSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
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
    
}



