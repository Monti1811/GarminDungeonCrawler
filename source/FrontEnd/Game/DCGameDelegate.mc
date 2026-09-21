import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

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

    private var _up_array = [0, 0, Constants.SCREEN_WIDTH, 0, Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2];
    private var _down_array = [0, Constants.SCREEN_HEIGHT, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2];
    private var _left_array = [0, 0, 0, Constants.SCREEN_HEIGHT, Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2];
    private var _right_array = [Constants.SCREEN_WIDTH, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2];

    function initialize(view as DCGameView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onBack() as Boolean {
        if (_view.getTurns().isProcessingTurn()) {
            return true;
        }
        showConfirmation("Do you want to exit the game?");
        return true;
    }

    function showConfirmation(message as String) {
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(dialog, new DCGameExitConfirmDelegate(), WatchUi.SLIDE_UP);
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        if (_view.getTurns().isProcessingTurn()) {
            return true;
        }
        if (keyEvent.getKey() == KEY_ENTER) {
            showMenu();
        }
        return true;
    }


    function onTap(clickEvent as ClickEvent) as Boolean {
        if (_view.getTurns().isProcessingTurn()) {
            return true;
        }
        var coord = clickEvent.getCoordinates() as Array<Number>;
        var center_x = Constants.SCREEN_WIDTH / 2;
        var center_y = Constants.SCREEN_HEIGHT / 2;
        if (coord[0] > center_x && coord[1] > center_y) {
            if (MathUtil.isInTriangleArray(coord, _down_array)) {
                _view.getTurns().doTurn(DOWN);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _right_array)) {
                _view.getTurns().doTurn(RIGHT);
                return true;
            }
        } else if (coord[0] < center_x && coord[1] > center_y) {
            if (MathUtil.isInTriangleArray(coord, _down_array)) {
                _view.getTurns().doTurn(DOWN);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _left_array)) {
                _view.getTurns().doTurn(LEFT);
                return true;
            }
        } else if (coord[0] > center_x && coord[1] < center_y) {
            if (MathUtil.isInTriangleArray(coord, _up_array)) {
                _view.getTurns().doTurn(UP);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _right_array)) {
                _view.getTurns().doTurn(RIGHT);
                return true;
            }
        } else if (coord[0] < center_x && coord[1] < center_y) {
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


    function showMenu() as Void {
        var actionMenu = new WatchUi.Menu2({:title=>"Game Menu"});
        actionMenu.addItem(new WatchUi.IconMenuItem(getApp().getPlayer().getName(), "Show details", :player, new GameMenuIconDrawable(WatchUi.loadResource($.Rez.Drawables.gameMenuPlayer) as Graphics.BitmapReference), null));
        actionMenu.addItem(new WatchUi.IconMenuItem("Inventory", "Show inventory", :inventory, new GameMenuIconDrawable(WatchUi.loadResource($.Rez.Drawables.gameMenuInventory) as Graphics.BitmapReference), null));
        actionMenu.addItem(new WatchUi.IconMenuItem("Quests", "Show active quests", :quests, new GameMenuIconDrawable(WatchUi.loadResource($.Rez.Drawables.gameMenuQuests) as Graphics.BitmapReference), null));
        actionMenu.addItem(new WatchUi.IconMenuItem("Map", "Show map", :map, new GameMenuIconDrawable(WatchUi.loadResource($.Rez.Drawables.gameMenuMap) as Graphics.BitmapReference), null));
        actionMenu.addItem(new WatchUi.IconMenuItem("Compendium", "Discovered enemies & items", :compendium, new GameMenuIconDrawable(WatchUi.loadResource($.Rez.Drawables.gameMenuCompendium) as Graphics.BitmapReference), null));
        actionMenu.addItem(new WatchUi.IconMenuItem("Save", "Save the game", :save, new GameMenuIconDrawable(WatchUi.loadResource($.Rez.Drawables.gameMenuSave) as Graphics.BitmapReference), null));
        actionMenu.addItem(new WatchUi.IconMenuItem("Log", "Show last actions", :log, new GameMenuIconDrawable(WatchUi.loadResource($.Rez.Drawables.gameMenuLog) as Graphics.BitmapReference), null));
        actionMenu.addItem(new WatchUi.IconMenuItem("Settings", "Change settings", :settings, new GameMenuIconDrawable(WatchUi.loadResource($.Rez.Drawables.gameMenuSettings) as Graphics.BitmapReference), null));
        self.addDebugMenu(actionMenu);

        WatchUi.pushView(actionMenu, new DCGameMenuDelegate(), SLIDE_UP);
    }

    (:debug) 
    function addDebugMenu(actionMenu as Menu2) {
        actionMenu.addItem(new WatchUi.MenuItem("Debug", "Debug tools", :debug, null));
    }

    (:release) 
    function addDebugMenu(actionMenu as Menu2) {
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
            $.Game.clearSession();
        }
        return true;
    }

    function saveGame() as Void {
        $.SaveData.saveGame();
    }

}