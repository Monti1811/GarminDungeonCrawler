import Toybox.Lang;
import Toybox.WatchUi;

class DCAchievementDetailFactory extends WatchUi.ViewLoopFactory {
    private const NUM_PAGES = 2;
    private var _def as Dictionary;

    function initialize(def as Dictionary) {
        ViewLoopFactory.initialize();
        _def = def;
    }

    function getView(page as Number) as [ViewLoopFactory.Views] or [ViewLoopFactory.Views, ViewLoopFactory.Delegates] {
        switch (page) {
            case 0:
                return [new DCAchievementDetailView(_def), new WatchUi.BehaviorDelegate()];
            case 1:
                return [new DCAchievementDescriptionView(_def), new WatchUi.BehaviorDelegate()];
        }
        return [new DCAchievementDetailView(_def), new WatchUi.BehaviorDelegate()];
    }

    function getSize() {
        return NUM_PAGES;
    }
}
