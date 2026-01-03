import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DCEnemyInfoFactory extends WatchUi.ViewLoopFactory {
    private const NUM_PAGES = 2;
    private var _enemy as Enemy;

    function initialize(enemy as Enemy) {
        ViewLoopFactory.initialize();
        _enemy = enemy;
    }

    //! Retrieve a view/delegate pair for the page at the given index
    function getView(page as Number) as [ViewLoopFactory.Views ] or [ ViewLoopFactory.Views, ViewLoopFactory.Delegates] {
        switch (page) {
            case 0:
                return [new $.DCEnemyInfoOverviewView(_enemy), new WatchUi.BehaviorDelegate()];
            case 1:
                return [new $.DCEnemyInfoStatsView(_enemy), new WatchUi.BehaviorDelegate()];
        }
        return [new $.DCEnemyInfoOverviewView(_enemy), new WatchUi.BehaviorDelegate()];
    }

    //! Return the number of view/delegate pairs that are managed by this factory
    function getSize() {
        return NUM_PAGES;
    }
}
