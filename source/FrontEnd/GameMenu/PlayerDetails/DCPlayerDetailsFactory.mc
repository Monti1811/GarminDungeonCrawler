import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DCPlayerDetailsFactory extends WatchUi.ViewLoopFactory {
    private const NUM_PAGES = 3;
    private var _player as Player;

    function initialize(player as Player) {
        ViewLoopFactory.initialize();
        _player = player;
    }

    //! Retrieve a view/delegate pair for the page at the given index
    function getView(page as Number) as [View] or [View, BehaviorDelegate] {
        switch (page) {
            case 0:
                return [new $.DCPlayerDetailsOverviewView(_player), new WatchUi.BehaviorDelegate()];
            case 1:
                return [new $.DCPlayerDetailsAttributesView(_player, true), new DCPlayerDetailsAttributesDelegate()];
            case 2: 
                var view = new $.DCPlayerDetailsEquipmentsView(_player, true);
                return [view, new DCPlayerDetailsEquipmentDelegate()];
        }
        return [new $.DCPlayerDetailsOverviewView(_player), new WatchUi.BehaviorDelegate()];
    }

    //! Return the number of view/delegate pairs that are managed by this factory
    function getSize() {
        return NUM_PAGES;
    }
}