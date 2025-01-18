import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;

class DCSaveSettingsDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :exit:
                item = item as ToggleMenuItem;
                Storage.setValue("save_on_exit", item.isEnabled());
                break;
        }
    }
}