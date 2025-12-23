import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DCCharacterCreationDetailsFactory extends WatchUi.ViewLoopFactory {
    private const NUM_PAGES = 3;
    private var _player as Player;

    function initialize(player as Player) {
        ViewLoopFactory.initialize();
        _player = player;
    }

    //! Retrieve a view/delegate pair for the page at the given index
    function getView(page as Number) as [ViewLoopFactory.Views ] or [ ViewLoopFactory.Views, ViewLoopFactory.Delegates] {
        switch (page) {
            case 0:
                return [new $.DCPlayerDetailsOverviewView(_player, true), new DCCharacterCreationDetailsLoopDelegate(_player)];
            case 1:
                return [new $.DCPlayerDetailsAttributesView(_player, false, true), new DCCharacterCreationDetailsLoopDelegate(_player)];
            case 2: 
                var view = new $.DCPlayerDetailsEquipmentsView(_player, false, true);
                return [view, new DCCharacterCreationDetailsLoopDelegate(_player)];
        }
        return [new $.DCPlayerDetailsOverviewView(_player, false), new DCCharacterCreationDetailsLoopDelegate(_player)];
    }

    //! Return the number of view/delegate pairs that are managed by this factory
    function getSize() {
        return NUM_PAGES;
    }
}