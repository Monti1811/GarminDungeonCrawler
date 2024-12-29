import Toybox.Lang;
import Toybox.WatchUi;

class DCMainMenuDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        //WatchUi.pushView(new Rez.Menus.MainMenu(), new RPGMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onTap(evt as ClickEvent) as Boolean {
        var tap_coordinates = evt.getCoordinates() as Array<Numeric>;
        var continue_coordinates = Constants.COORDINATES_LOADGAME as Array<Numeric>;
        continue_coordinates[2] = continue_coordinates[0] + continue_coordinates[2];
        continue_coordinates[3] = continue_coordinates[1] + continue_coordinates[3];
        
        if (MathUtil.isInAreaArray(tap_coordinates, continue_coordinates, Constants.TAP_TOLERANCE)) {
            loadGame();
            return true;
        } else {
            var new_game_coordinates = Constants.COORDINATES_NEWGAME as Array<Numeric>;
            new_game_coordinates[2] = new_game_coordinates[0] + new_game_coordinates[2];
            new_game_coordinates[3] = new_game_coordinates[1] + new_game_coordinates[3];
            if (MathUtil.isInAreaArray(tap_coordinates, new_game_coordinates, Constants.TAP_TOLERANCE)) {
                showConfirmation();
                return true;
            }
        }
        return false;
    }

    function loadGame() as Void {
        var loadMenu = new WatchUi.Menu2({:title=>"Load Game"});

    }

    function showConfirmation() {
        var message = "Attention! Starting a new game will delete your save!";
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(
            dialog,
            new RPGConfirmateNewGame(),
            WatchUi.SLIDE_IMMEDIATE
        );
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
        }
        return true;
    }

}