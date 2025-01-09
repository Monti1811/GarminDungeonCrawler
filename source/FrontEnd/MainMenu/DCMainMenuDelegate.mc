import Toybox.Lang;
import Toybox.WatchUi;

class DCMainMenuDelegate extends WatchUi.BehaviorDelegate {

    private var continue_coordinates = [
        Constants.COORDINATES_LOADGAME[0] - Constants.COORDINATES_LOADGAME[2]/2,
        Constants.COORDINATES_LOADGAME[0] + Constants.COORDINATES_LOADGAME[2]/2,
        Constants.COORDINATES_LOADGAME[1] - Constants.COORDINATES_LOADGAME[3]/2,
        Constants.COORDINATES_LOADGAME[1] + Constants.COORDINATES_LOADGAME[3]/2
    ] as Array<Numeric>;

    private var new_game_coordinates = [
        Constants.COORDINATES_NEWGAME[0] - Constants.COORDINATES_NEWGAME[2]/2,
        Constants.COORDINATES_NEWGAME[0] + Constants.COORDINATES_NEWGAME[2]/2,
        Constants.COORDINATES_NEWGAME[1] - Constants.COORDINATES_NEWGAME[3]/2,
        Constants.COORDINATES_NEWGAME[1] + Constants.COORDINATES_NEWGAME[3]/2
    ] as Array<Numeric>;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        //WatchUi.pushView(new Rez.Menus.MainMenu(), new RPGMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onTap(evt as ClickEvent) as Boolean {
        var tap_coordinates = evt.getCoordinates() as Array<Numeric>;
        
        
        if (MathUtil.isInAreaArray(tap_coordinates, continue_coordinates, Constants.TAP_TOLERANCE)) {
            loadGame();
            return true;
        } else {
            if (MathUtil.isInAreaArray(tap_coordinates, new_game_coordinates, Constants.TAP_TOLERANCE)) {
                showConfirmation("Do you want to start a new game?");
                return true;
            }
        }
        return false;
    }

    function loadGame() as Void {
        var loadMenu = new WatchUi.Menu2({:title=>"Load Game"});
        var saves = SaveData.saves;
        var save_keys = saves.keys();
        for (var i = 0; i < save_keys.size(); i++) {
            var save_key = save_keys[i] as String;
            var save = SaveData.getSaveInfo(save_key);
            var save_item = new WatchUi.MenuItem(save_key, save, null, null);
            loadMenu.addItem(save_item);
        }
        WatchUi.pushView(loadMenu, new RPGLoadGameDelegate(), WatchUi.SLIDE_UP);

    }

    function showConfirmation(message as String) {
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(
            dialog,
            new RPGConfirmateNewGame(),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

}


class RPGLoadGameDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var savegame = item.getLabel() as String;
        var message = "Do you want to load " + savegame + "?";
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(
            dialog,
            new DCConfirmLoadGame(savegame),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    //! Handle the back key being pressed
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

//! Input handler for the confirmation dialog
class DCConfirmLoadGame extends WatchUi.ConfirmationDelegate {

    private var _savegame as String;

    //! Constructor
    //! @param view The app view
    public function initialize(savegame as String) {
        ConfirmationDelegate.initialize();
        _savegame = savegame;
    }

    //! Handle a confirmation selection
    //! @param value The confirmation value
    //! @return true if handled, false otherwise
    public function onResponse(value as Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            SaveData.chosen_save = _savegame;
            SaveData.loadGame(_savegame);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            var app = getApp();
            var player = app.getPlayer();
            var roomView = new DCGameView(player, app.getCurrentDungeon().getCurrentRoom(), null);
            var roomDelegate = new DCGameDelegate(roomView);
            WatchUi.switchToView(roomView, roomDelegate, WatchUi.SLIDE_UP);
            WatchUi.pushView(new EmptyView(), new EmptyDelegate(), WatchUi.SLIDE_UP);
        }
        return true;
    }

}

//! Input handler for the confirmation dialog
class RPGConfirmateNewGame extends WatchUi.ConfirmationDelegate {


    //! Constructor
    //! @param view The app view
    public function initialize() {
        ConfirmationDelegate.initialize();
    }

    //! Handle a confirmation selection
    //! @param value The confirmation value
    //! @return true if handled, false otherwise
    public function onResponse(value as Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            // Create new character, then save it to SaveData
            var characterMenu = new WatchUi.Menu2({:title=>"Characters"});
            var characters = SimUtil.createAllPossibleCharacters();
            for (var i = 0; i < characters.size(); i++) {
                var character = characters[i] as Player;
                var character_item = new WatchUi.MenuItem(character.getName(), character.getDescription(), character, null);
                characterMenu.addItem(character_item);
            }
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(characterMenu, new DCCharacterCreationDelegate(), WatchUi.SLIDE_UP);
            WatchUi.pushView(new EmptyView(), new EmptyDelegate(), WatchUi.SLIDE_UP);
        }
        return true;
    }

}