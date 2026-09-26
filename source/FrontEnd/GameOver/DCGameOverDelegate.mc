import Toybox.Lang;
import Toybox.WatchUi;

class DCGameOverDelegate extends WatchUi.BehaviorDelegate {

    private var _exited as Boolean = false;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    //TODO change it so that either reload to last save or back to main menu
    function onTap(evt as ClickEvent) as Boolean {
        goToMainMenu();
        return true;
    }

    function onBack() as Boolean {
        goToMainMenu();
        return true;
    }

    function goToMainMenu() as Void {
        if (_exited) {
            return;
        }
        _exited = true;
        var app = getApp();
        app.setPlayer(null);
        app.setCurrentDungeon(null);
        $.SaveData.setSaveData({});
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }


}

