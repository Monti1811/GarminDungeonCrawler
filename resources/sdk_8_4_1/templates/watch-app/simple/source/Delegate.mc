import Toybox.Lang;
import Toybox.WatchUi;

class ${delegateClassName} extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new ${menuDelegateClassName}(), WatchUi.SLIDE_UP);
        return true;
    }

}