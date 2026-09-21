import Toybox.Test;
import Toybox.Lang;

// --- getAutoSaveString ---

(:test)
function getAutoSaveStringOffForNegativeOne(logger as Test.Logger) as Boolean {
    Test.assertEqual(Settings.getAutoSaveString(-1), "Off");
    return true;
}

(:test)
function getAutoSaveStringEveryNTurnsForZero(logger as Test.Logger) as Boolean {
    Test.assertEqual(Settings.getAutoSaveString(0), "Every 3 turns");
    return true;
}

(:test)
function getAutoSaveStringEveryNMinutesForPositive(logger as Test.Logger) as Boolean {
    Test.assertEqual(Settings.getAutoSaveString(5), "Every 5 minutes");
    Test.assertEqual(Settings.getAutoSaveString(10), "Every 10 minutes");
    Test.assertEqual(Settings.getAutoSaveString(1), "Every 1 minutes");
    return true;
}

// --- getStepsPerTurnString ---

(:test)
function getStepsPerTurnStringOffForZero(logger as Test.Logger) as Boolean {
    Test.assertEqual(Settings.getStepsPerTurnString(0), "Off");
    return true;
}

(:test)
function getStepsPerTurnStringOffForNegative(logger as Test.Logger) as Boolean {
    Test.assertEqual(Settings.getStepsPerTurnString(-1), "Off");
    Test.assertEqual(Settings.getStepsPerTurnString(-5), "Off");
    return true;
}

(:test)
function getStepsPerTurnStringShowsStepsForPositive(logger as Test.Logger) as Boolean {
    Test.assertEqual(Settings.getStepsPerTurnString(100), "100 steps/turn");
    Test.assertEqual(Settings.getStepsPerTurnString(1), "1 steps/turn");
    Test.assertEqual(Settings.getStepsPerTurnString(500), "500 steps/turn");
    return true;
}

// --- Settings defaults ---

(:test)
function settingsDefaultsExist(logger as Test.Logger) as Boolean {
    Test.assertMessage(Settings.settings.hasKey("rooms_amount"), "should have rooms_amount");
    Test.assertMessage(Settings.settings.hasKey("min_room_size"), "should have min_room_size");
    Test.assertMessage(Settings.settings.hasKey("max_room_size"), "should have max_room_size");
    Test.assertMessage(Settings.settings.hasKey("save_on_exit"), "should have save_on_exit");
    Test.assertMessage(Settings.settings.hasKey("autosave"), "should have autosave");
    Test.assertMessage(Settings.settings.hasKey("steps_per_turn"), "should have steps_per_turn");
    return true;
}

(:test)
function settingsDefaultValuesCorrect(logger as Test.Logger) as Boolean {
    Settings.settings["rooms_amount"] = 4;
    Settings.settings["min_room_size"] = 5;
    Settings.settings["max_room_size"] = 15;
    Settings.settings["save_on_exit"] = false;
    Settings.settings["autosave"] = -1;
    Settings.settings["steps_per_turn"] = 0;
    return true;
}
