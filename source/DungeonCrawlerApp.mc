import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class DungeonCrawlerApp extends Application.AppBase {

    public var tile_width as Number = 16;
    public var tile_height as Number = 16;

    public var _player as Player;

    function initialize() {
        AppBase.initialize();
        _player = new Player();
        _player.setSprite($.Rez.Drawables.Player);
        _player.addInventoryItem(new Axe());

        Log.log("Game started");
        Log.log("Player: " + _player);
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        ///*
        var dungeon = new Dungeon1(tile_width, tile_height, {:width => 360, :height => 360});
        var dungeon1View = new DCGameView(_player, dungeon, null);
        var dungeon1Delegate = new DCGameDelegate(dungeon1View);
        return [ dungeon1View, dungeon1Delegate ];
        //*/

        /*var factory = new DCGameMenuItemInfoFactory(new Axe());
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        return [viewLoop, new DCGameMenuItemInfoDelegate(viewLoop)];*/
    }

    function getPlayer() as Player {
        return _player;
    }

}

function getApp() as DungeonCrawlerApp {
    return Application.getApp() as DungeonCrawlerApp;
}