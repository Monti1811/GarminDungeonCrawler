import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class DungeonCrawlerApp extends Application.AppBase {

    public var tile_width as Number = 16;
    public var tile_height as Number = 16;

    public var _player as Player;
    public var _curr_dungeon as Dungeon?;

    function initialize() {
        AppBase.initialize();
        _player = new Warrior("Warrior");
        _player.setSprite($.Rez.Drawables.Player);
        _player.addInventoryItem(new Axe());

        //_curr_dungeon = new Dungeon1(tile_width, tile_height, {:width => 360, :height => 360});

        Log.log("Game started");
        Log.log("Player: " + _player.getName());
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        //return showPlayerDetails();
        //return showItemInfo();
        //return showDungeon1();
        //return showNewDungeon();
        return showMainMenu();        
    }

    function showItemInfo(item as Item) as [Views] or [Views, InputDelegates] {
        var factory = new DCGameMenuItemInfoFactory(item);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        return [viewLoop, new DCGameMenuItemInfoDelegate(viewLoop)];
    }

    function showPlayerDetails() as [Views] or [Views, InputDelegates] {
        var factory = new DCPlayerDetailsFactory(_player);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        return [viewLoop, new DCPlayerDetailsDelegate(viewLoop)];
    }

    function showIntro() as [Views] or [Views, InputDelegates] {
        var introView = new DCIntroView();
        return [introView, new DCIntroDelegate(introView, null, Graphics.FONT_SMALL)];
    }

    function showRoom() as [Views] or [Views, InputDelegates] {
        var roomView = new DCGameView(_player, _curr_dungeon.getCurrentRoom(), null);
        var roomDelegate = new DCGameDelegate(roomView);
        return [ roomView, roomDelegate ];
    }

    function showMainMenu() as [Views] or [Views, InputDelegates] {
        var mainMenu = new DCMainMenuView();
        var mainMenuDelegate = new DCMainMenuDelegate();
        SaveData.saves = {"save1"=>["Level 1"], "save2"=>["Level 2"], "save3"=>["Level 3"]};
        return [mainMenu, mainMenuDelegate];
    }

    function showNewDungeon() as [Views] or [Views, InputDelegates] {
        var progressBar = new WatchUi.ProgressBar(
            "Creating new game...",
            0.0
        );
        return [progressBar, new DCCreateGameProgressDelegate(_player, progressBar)];
    }

    function getPlayer() as Player {
        return _player;
    }

    function setPlayer(player as Player) as Void {
        _player = player;
    }

    function getCurrentDungeon() as Dungeon {
        return _curr_dungeon;
    }

    function setCurrentDungeon(dungeon as Dungeon) as Void {
        _curr_dungeon = dungeon;
    }

}

function getApp() as DungeonCrawlerApp {
    return Application.getApp() as DungeonCrawlerApp;
}