import Toybox.Lang;
import Toybox.WatchUi;

enum WalkDirection {
    UP,
    DOWN,
    LEFT,
    RIGHT,
    STANDING,
}

class DCGameDelegate extends WatchUi.BehaviorDelegate {

    private var _view as DCGameView;

    private var _up_array = [0, 0, 360, 0, 180, 180];
    private var _down_array = [0, 360, 360, 360, 180, 180];
    private var _left_array = [0, 0, 0, 360, 180, 180];
    private var _right_array = [360, 0, 360, 360, 180, 180];

    function initialize(view as DCGameView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onBack() as Boolean {
        return false;
    }


    function onTap(clickEvent as ClickEvent) as Boolean {
        var coord = clickEvent.getCoordinates() as Array<Number>;
        if (coord[0] > 180 && coord[1] > 180) {
            if (MathUtil.isInTriangleArray(coord, _down_array)) {
                _view.doTurn(DOWN);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _right_array)) {
                _view.doTurn(RIGHT);
                return true;
            }
        } else if (coord[0] < 180 && coord[1] > 180) {
            if (MathUtil.isInTriangleArray(coord, _down_array)) {
                _view.doTurn(DOWN);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _left_array)) {
                _view.doTurn(LEFT);
                return true;
            }
        } else if (coord[0] > 180 && coord[1] < 180) {
            if (MathUtil.isInTriangleArray(coord, _up_array)) {
                _view.doTurn(UP);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _right_array)) {
                _view.doTurn(RIGHT);
                return true;
            }
        } else if (coord[0] < 180 && coord[1] < 180) {
            if (MathUtil.isInTriangleArray(coord, _up_array)) {
                _view.doTurn(UP);
                return true;
            } else if (MathUtil.isInTriangleArray(coord, _left_array)) {
                _view.doTurn(LEFT);
                return true;
            }
        }
        return false;
    }


    function onMenu() as Boolean {
        var actionMenu = new WatchUi.Menu2({:title=>"Game Menu"});
        actionMenu.addItem(new WatchUi.MenuItem(_view.getPlayer().getName(), "Show details", :player, null));
        actionMenu.addItem(new WatchUi.MenuItem("Inventory", "Show inventory", :inventory, null));
        actionMenu.addItem(new WatchUi.MenuItem("Log", "Show last actions", :log, null));
        actionMenu.addItem(new WatchUi.MenuItem("Settings", "Change settings", :settings, null));

        WatchUi.pushView(actionMenu, new DCGameMenuDelegate(), SLIDE_UP);
        return true;
    }

}