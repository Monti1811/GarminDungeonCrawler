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

    private var _confirm_shown as Boolean = false;

    private var _up_array = [0, 0, Constants.SCREEN_WIDTH, 0, Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2];
    private var _down_array = [0, Constants.SCREEN_HEIGHT, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2];
    private var _left_array = [0, 0, 0, Constants.SCREEN_HEIGHT, Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2];
    private var _right_array = [Constants.SCREEN_WIDTH, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2];

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        var turns = $.Game.getTurns();
        if (turns == null || turns.isProcessingTurn()) {
            return true;
        }
        showConfirmation("Do you want to exit the game?");
        return true;
    }

    function showConfirmation(message as String) {
        if (_confirm_shown) {
            return;
        }
        _confirm_shown = true;
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(dialog, new DCGameExitConfirmDelegate(self), WatchUi.SLIDE_UP);
    }

    function resetConfirmation() as Void {
        _confirm_shown = false;
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        var turns = $.Game.getTurns();
        if (turns == null || turns.isProcessingTurn()) {
            return true;
        }
        if (keyEvent.getKey() == KEY_ENTER) {
            showMenu();
        }
        return true;
    }


    function onTap(clickEvent as ClickEvent) as Boolean {
        var turns = $.Game.getTurns();
        if (turns == null || turns.isProcessingTurn()) {
            return true;
        }
        var coord = clickEvent.getCoordinates() as Array<Number>;
        var center_x = Constants.SCREEN_WIDTH / 2;
        var center_y = Constants.SCREEN_HEIGHT / 2;
        if (coord[0] > center_x && coord[1] > center_y) {
            if (MathUtil.isInTriangleArray(coord, _down_array)) {
                turns.doTurn(DOWN);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _right_array)) {
                turns.doTurn(RIGHT);
                return true;
            }
        } else if (coord[0] < center_x && coord[1] > center_y) {
            if (MathUtil.isInTriangleArray(coord, _down_array)) {
                turns.doTurn(DOWN);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _left_array)) {
                turns.doTurn(LEFT);
                return true;
            }
        } else if (coord[0] > center_x && coord[1] < center_y) {
            if (MathUtil.isInTriangleArray(coord, _up_array)) {
                turns.doTurn(UP);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _right_array)) {
                turns.doTurn(RIGHT);
                return true;
            }
        } else if (coord[0] < center_x && coord[1] < center_y) {
            if (MathUtil.isInTriangleArray(coord, _up_array)) {
                turns.doTurn(UP);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _left_array)) {
                turns.doTurn(LEFT);
                return true;
            }
        }
        return false;
    }


    function showMenu() as Void {
        var actionMenu = new WatchUi.Menu2({:title=>"Game Menu"});
        actionMenu.addItem(new WatchUi.IconMenuItem(getApp().getPlayer().getName(), "Show details", :player, new GameMenuIconDrawable(getApp().getPlayer().getSpriteRef()), null));
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
    
    private var _parent as DCGameDelegate;

    function initialize(parent as DCGameDelegate) {
        ConfirmationDelegate.initialize();
        _parent = parent;
    }

    public function onResponse(value as Confirm) as Boolean {
        _parent.resetConfirmation();
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