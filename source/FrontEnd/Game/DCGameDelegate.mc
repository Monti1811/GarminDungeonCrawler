import Toybox.Lang;
import Toybox.WatchUi;

enum WalkDirection {
    UP,
    DOWN,
    LEFT,
    RIGHT,
    STANDING,
    SKIPPING
}

class DCGameDelegate extends WatchUi.BehaviorDelegate {

    private var _view as DCGameView;

    private var _up_array = [0, 0, 360, 0, 180, 180];
    private var _down_array = [0, 360, 360, 360, 180, 180];
    private var _left_array = [0, 0, 0, 360, 180, 180];
    private var _right_array = [360, 0, 360, 360, 180, 180];

    function initialize(view as DCGameView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onBack() as Boolean {
        showConfirmation("Do you want to exit the game?");
        return true;
    }

    function showConfirmation(message as String) {
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(dialog, new DCGameExitConfirmDelegate(), WatchUi.SLIDE_UP);
    }


    function onTap(clickEvent as ClickEvent) as Boolean {
        var coord = clickEvent.getCoordinates() as Array<Number>;
        if (coord[0] > 180 && coord[1] > 180) {
            if (MathUtil.isInTriangleArray(coord, _down_array)) {
                _view.getTurns().doTurn(DOWN);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _right_array)) {
                _view.getTurns().doTurn(RIGHT);
                return true;
            }
        } else if (coord[0] < 180 && coord[1] > 180) {
            if (MathUtil.isInTriangleArray(coord, _down_array)) {
                _view.getTurns().doTurn(DOWN);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _left_array)) {
                _view.getTurns().doTurn(LEFT);
                return true;
            }
        } else if (coord[0] > 180 && coord[1] < 180) {
            if (MathUtil.isInTriangleArray(coord, _up_array)) {
                _view.getTurns().doTurn(UP);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _right_array)) {
                _view.getTurns().doTurn(RIGHT);
                return true;
            }
        } else if (coord[0] < 180 && coord[1] < 180) {
            if (MathUtil.isInTriangleArray(coord, _up_array)) {
                _view.getTurns().doTurn(UP);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _left_array)) {
                _view.getTurns().doTurn(LEFT);
                return true;
            }
        }
        return false;
    }


    function onMenu() as Boolean {
        var actionMenu = new WatchUi.Menu2({:title=>"Game Menu"});
        actionMenu.addItem(new WatchUi.MenuItem(getApp().getPlayer().getName(), "Show details", :player, null));
        actionMenu.addItem(new WatchUi.MenuItem("Inventory", "Show inventory", :inventory, null));
        actionMenu.addItem(new WatchUi.MenuItem("Map", "Show map", :map, null));
        actionMenu.addItem(new WatchUi.MenuItem("Save", "Save the game", :save, null));
        actionMenu.addItem(new WatchUi.MenuItem("Log", "Show last actions", :log, null));
        actionMenu.addItem(new WatchUi.MenuItem("Settings", "Change settings", :settings, null));

        WatchUi.pushView(actionMenu, new DCGameMenuDelegate(), SLIDE_UP);
        return true;
    }

}

class DCGameExitConfirmDelegate extends WatchUi.ConfirmationDelegate {
    
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    public function onResponse(value as Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            if ($.Settings.settings["save_on_exit"]) {
                saveGame();
            }
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            var app = getApp();
            app.setPlayer(null);
            app.setCurrentDungeon(null);
        }
        return true;
    }

    function saveGame() as Void {
        $.SaveData.saveGame();
    }

}