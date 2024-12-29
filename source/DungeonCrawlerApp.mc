import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class DungeonCrawlerApp extends Application.AppBase {

    public var tile_width as Number = 16;
    public var tile_height as Number = 16;

    public var _player as Player;
    public var _curr_dungeon as Dungeon;

    function initialize() {
        AppBase.initialize();
        _player = new Player();
        _player.setSprite($.Rez.Drawables.Player);
        _player.addInventoryItem(new Axe());

        _curr_dungeon = new Dungeon1(tile_width, tile_height, {:width => 360, :height => 360});

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

    function showDungeon1() as [Views] or [Views, InputDelegates] {
        var dungeon1View = new DCGameView(_player, _curr_dungeon, null);
        var dungeon1Delegate = new DCGameDelegate(dungeon1View);
        return [ dungeon1View, dungeon1Delegate ];
    }

    function showMainMenu() as [Views] or [Views, InputDelegates] {
        var mainMenu = new DCMainMenuView();
        var mainMenuDelegate = new DCMainMenuDelegate();
        SaveData.saves = {"save1"=>["Level 1"], "save2"=>["Level 2"], "save3"=>["Level 3"]};
        return [mainMenu, mainMenuDelegate];
    }

    function getPlayer() as Player {
        return _player;
    }

    function getCurrentDungeon() as Dungeon {
        return _curr_dungeon;
    }

}

function getApp() as DungeonCrawlerApp {
    return Application.getApp() as DungeonCrawlerApp;
}