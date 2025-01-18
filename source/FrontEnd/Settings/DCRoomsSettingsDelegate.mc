import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;

class DCRoomsSettingsDelegate extends WatchUi.Menu2InputDelegate {

    var roomsSettings as Menu2;

    function initialize(roomsSettings as Menu2) {
        Menu2InputDelegate.initialize();
        self.roomsSettings = roomsSettings;
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :amount:
                showRoomsAmountSettings();
                break;
            case :min:
                showRoomsSizeSettings(false);
                break;
            case :max:
                showRoomsSizeSettings(true);
                break;
        }
    }

    function showRoomsAmountSettings() as Void {
        var roomsAmountSettings = new WatchUi.Menu2({:title=>"Rooms amount settings"});
        roomsAmountSettings.addItem(new WatchUi.MenuItem("2x2 (4)", null, 2, null));
        roomsAmountSettings.addItem(new WatchUi.MenuItem("3x3 (9)", null, 3, null));
        roomsAmountSettings.addItem(new WatchUi.MenuItem("4x4 (16)", null, 4, null));
        roomsAmountSettings.addItem(new WatchUi.MenuItem("5x5 (25)", null, 5, null));
        roomsAmountSettings.addItem(new WatchUi.MenuItem("6x6 (36)", null, 6, null));

        WatchUi.pushView(roomsAmountSettings, new DCRoomsAmountSettingsDelegate(roomsSettings), WatchUi.SLIDE_UP);
    }

    function showRoomsSizeSettings(is_max as Boolean) as Void {
        var roomsSizeSettings = new WatchUi.Menu2({:title=>"Rooms size settings"});
        var min = 5;
        var max = 15;
        if (!is_max) {
            max = Storage.getValue("max_room_size");
        } else {
            min = Storage.getValue("min_room_size");
        }
        var symbol = is_max ? :max : :min;
        for (var i = min; i <= max; i++) {
            roomsSizeSettings.addItem(new WatchUi.MenuItem(i + "x" + i, null, symbol, null));
        }

        WatchUi.pushView(roomsSizeSettings, new DCRoomsSizeSettingsDelegate(roomsSettings), WatchUi.SLIDE_UP);
    }

}

class DCRoomsAmountSettingsDelegate extends WatchUi.Menu2InputDelegate {

    var parent as Menu2;

    function initialize(parent as Menu2) {
        Menu2InputDelegate.initialize();
        self.parent = parent;
    }

    function onSelect(item as MenuItem) as Void {
        Storage.setValue("rooms_amount", item.getId());
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        var size = item.getId().toString() as String;
        parent.updateItem(new MenuItem("Max rooms per dungeon", size + "x" + size, :amount, null), 0);
    }
}

class DCRoomsSizeSettingsDelegate extends WatchUi.Menu2InputDelegate {

    var parent as Menu2;

    function initialize(parent as Menu2) {
        Menu2InputDelegate.initialize();
        self.parent = parent;
    }

    function onSelect(item as MenuItem) as Void {
        var symbol = item.getId() as Symbol;
        var value = item.getLabel().toNumber();
        Storage.setValue(symbol == :min ? "min_room_size" : "max_room_size", value);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        parent.updateItem(new MenuItem(symbol == :min ? "Min room size" : "Max room size", value.toString() + "x" + value.toString(), symbol, null), symbol == :min ? 1 : 2);
    }
}