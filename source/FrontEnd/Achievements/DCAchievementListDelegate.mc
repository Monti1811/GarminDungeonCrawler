import Toybox.Lang;
import Toybox.WatchUi;

class DCAchievementListDelegate extends WatchUi.Menu2InputDelegate {

    function initialize(menu as Menu2) {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        if (!(id instanceof String)) {
            return;
        }
        var def = $.Achievements.findDefinition(id as String);
        if (def == null) {
            return;
        }
        var factory = new DCAchievementDetailFactory(def);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCAchievementDetailDelegate(viewLoop), WatchUi.SLIDE_UP);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
