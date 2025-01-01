import Toybox.Lang;
import Toybox.WatchUi;

class DCCharacterCreationDetailsLoopDelegate extends WatchUi.BehaviorDelegate {

    private var _player as Player;

    function initialize(player as Player) {
        BehaviorDelegate.initialize();
        _player = player;
    }

    function onMenu() as Boolean {
        //WatchUi.pushView(new Rez.Menus.MainMenu(), new RPGMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onBack() as Boolean {
        showConfirmation("Do you want to choose this character?");
        return true;
    }

    function showConfirmation(message as String) {
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(dialog, new DCCharacterCreationConfirmDelegate(_player), WatchUi.SLIDE_UP);
    }

}

class DCCharacterCreationConfirmDelegate extends WatchUi.ConfirmationDelegate {

    private var _player as Player;
    
    function initialize(player as Player) {
        ConfirmationDelegate.initialize();
        _player = player;
    }

    public function onResponse(value as Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {

            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(new WatchUi.TextPicker(_player.getName()), new DCCharacterNamingDelegate(_player), WatchUi.SLIDE_UP);
            WatchUi.pushView(new EmptyView(), null, WatchUi.SLIDE_UP);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            
        }
        return true;
    }

}

class DCCharacterNamingDelegate extends WatchUi.TextPickerDelegate {
    
    private var _player as Player;

    function initialize(player as Player) {
        TextPickerDelegate.initialize();
        _player = player;
    }

    function onTextEntered(text as String, changed as Boolean) as Boolean {
        _player.setName(text);
        Main.createNewGame(_player);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
