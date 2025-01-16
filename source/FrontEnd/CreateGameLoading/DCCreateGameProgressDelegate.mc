import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;

class DCCreateGameProgressDelegate extends WatchUi.BehaviorDelegate {

    private var _timer as Timer.Timer;
    private var _time_inbetween as Number = 1000;
    private var _player as Player;
    private var _progress_bar as WatchUi.ProgressBar;
    private var _progress as Number = 0;

    private var _dungeon as Dungeon?;
    private var _size_dungeon as Point2D?;
    private var _room_counter as Number = 0;

    function initialize(player as Player, progressBar as WatchUi.ProgressBar) {
        BehaviorDelegate.initialize();
        _timer = new Timer.Timer();
        _player = player;
        _progress_bar = progressBar;
        _timer.start(method(:onTimer), _time_inbetween, false);
    }


    function onTimer() as Void {
        switch (_progress) {
            case 0:
                Main.createNewGame1(_player, _progress_bar);
                _time_inbetween = 100;
                _progress = 1;
                break;
            case 1:
                _dungeon = Main.createNewDungeon(_progress_bar);
                _size_dungeon = _dungeon.getSize();
                _progress = 2;
                break;
            case 2:
                if (_room_counter < _dungeon.getSize()[0] * _dungeon.getSize()[1]) {
                    Main.createRoomForDungeon(_dungeon, _room_counter % _size_dungeon[0], Math.floor(_room_counter / _size_dungeon[0]));
                    _room_counter += 1;
                    _progress_bar.setProgress(10.0 + _room_counter * 80 / (_size_dungeon[0] * _size_dungeon[1]));
                    _progress_bar.setDisplayString("Creating room " + _room_counter + " of " + (_size_dungeon[0] * _size_dungeon[1]));
                } else {
                    _time_inbetween = 500;
                    _progress = 3;
                }
                break;
            case 3:
                Main.createNewGame2(_player, _progress_bar, _dungeon);
                _progress = 4;
                return;
        }
        
        _timer.start(method(:onTimer), _time_inbetween, false);  
    }

    function onBack() {
        return true;
    }
}