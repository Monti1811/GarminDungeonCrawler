import Toybox.Lang;
import Toybox.Application;
import Toybox.Application.Storage;

module Settings {

    var settings as Dictionary<String, PropertyValueType> = {
        "rooms_amount"=> 4,
        "min_room_size"=> 5,
        "max_room_size"=> 15,
        "save_on_exit"=> false,
        "autosave"=> -1
    };

    function initSetting(key as String, default_value as PropertyValueType) as Void {
        var value = Storage.getValue(key) as PropertyValueType?;
        if (value == null) {
            Storage.setValue(key, default_value);
        } else {
            settings[key] = value;
        }
    }

    function init() as Void {
        var setting_keys = settings.keys();
        for (var i = 0; i < setting_keys.size(); i++) {
            initSetting(setting_keys[i], settings[setting_keys[i]]);
        }
    }

    function setValue(key as String, value as PropertyValueType) as Void {
        settings[key] = value;
        Storage.setValue(key, value);
    }

    function getAutoSaveString(val as Number) as String {
        switch (val) {
            case -1:
                return "Off";
            case 0:
                return "Every turn";
            default:
                return "Every " + val + " minutes";
        }
    }
}