import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;

class DCSaveSettingsDelegate extends WatchUi.Menu2InputDelegate {

    private var _saveSettings as Menu2;

    function initialize(saveSettings as Menu2) {
        Menu2InputDelegate.initialize();
        _saveSettings = saveSettings;
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :exit:
                item = item as ToggleMenuItem;
                var val = item.isEnabled();
                Settings.setValue("save_on_exit", val);
                break;
            case :autosave:
                showAutoSaveSettings();
                break;
        }
    }

    function showAutoSaveSettings() as Void {
        var autoSaveSettings = new WatchUi.Menu2({:title=>"Autosave settings"});
        autoSaveSettings.addItem(new WatchUi.MenuItem("Off", null, -1, null));
        autoSaveSettings.addItem(new WatchUi.MenuItem("Every turn", null, 0, null));
        autoSaveSettings.addItem(new WatchUi.MenuItem("Every 1 minute", null, 1, null));
        autoSaveSettings.addItem(new WatchUi.MenuItem("Every 3 minutes", null, 2, null));
        autoSaveSettings.addItem(new WatchUi.MenuItem("Every 5 minutes", null, 5, null));
        autoSaveSettings.addItem(new WatchUi.MenuItem("Every 10 minutes", null, 10, null));
        autoSaveSettings.addItem(new WatchUi.MenuItem("Every 15 minutes", null, 15, null));

        WatchUi.pushView(autoSaveSettings, new DCAutoSaveSettingsDelegate(_saveSettings), WatchUi.SLIDE_UP);
    }
}

class DCAutoSaveSettingsDelegate extends WatchUi.Menu2InputDelegate {

    private var _saveSettings as Menu2;

    function initialize(saveSettings as Menu2) {
        Menu2InputDelegate.initialize();
        _saveSettings = saveSettings;
    }

    function onSelect(item as MenuItem) as Void {
        var autoSave = item.getId() as Number;
        Settings.setValue("autosave", autoSave);
        _saveSettings.updateItem(new WatchUi.MenuItem("Autosave", $.Settings.getAutoSaveString(autoSave), :autosave, null), 1);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}