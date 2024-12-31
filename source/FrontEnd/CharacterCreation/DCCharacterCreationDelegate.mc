import Toybox.Lang;
import Toybox.WatchUi;

class DCCharacterCreationDelegate extends WatchUi.Menu2InputDelegate {


    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var character = item.getId() as Player;
        showCharacterDetails(character);
    }

    function showCharacterDetails(character as Player) {
        var factory = new DCCharacterCreationDetailsFactory(character);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCCharacterCreationDetailsDelegate(viewLoop), WatchUi.SLIDE_IMMEDIATE);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }


}

