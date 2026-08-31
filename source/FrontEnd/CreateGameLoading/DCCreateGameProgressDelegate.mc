import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;

class DCCreateGameProgressDelegate extends WatchUi.BehaviorDelegate {

    private var _timer as Timer.Timer?;
    private var _time_inbetween as Number = 1000;
    private var _player as Player;
    private var _progress_bar as WatchUi.ProgressBar;
    private var _progress as Number = 0;

    private var _dungeon as Dungeon?;
    private var _size_dungeon as Point2D?;
    private var _room_counter as Number = 0;

    private var _pending_room as Room?;
    private var _pending_i as Number = 0;
    private var _pending_j as Number = 0;
    private var _room_phase as Number = 0;

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
                Main.createNewGame(_player, _progress_bar, null, 1);
                _time_inbetween = 100;
                _progress = 1;
                break;
            case 1:
                _dungeon = Main.createNewDungeon(_progress_bar);
                _size_dungeon = _dungeon.getSize();
                _progress = 2;
                break;
            case 2:
                var total = _size_dungeon[0] * _size_dungeon[1];

                if (_room_phase == 1) {
                    // Phase 1: cleanup orphaned walls
                    Main.cleanupRoomForDungeon(_pending_room);
                    _room_phase = 2;
                } else if (_room_phase == 2) {
                    // Phase 2: save to Storage + free memory
                    Main.saveRoomForDungeon(_dungeon, _pending_room, _pending_i, _pending_j);
                    _pending_room.freeMemory();
                    _pending_room = null;
                    _room_phase = 0;
                } else if (_room_counter < total) {
                    // Phase 0: create room + connections
                    _pending_i = _room_counter % _size_dungeon[0];
                    _pending_j = Math.floor(_room_counter / _size_dungeon[0]);
                    _pending_room = Main.createRoomForDungeon(_dungeon, _pending_i, _pending_j);
                    _room_counter += 1;
                    _room_phase = 1;
                    _progress_bar.setProgress(10.0 + _room_counter * 80 / total);
                    _progress_bar.setDisplayString("Creating room " + _room_counter + " of " + total);
                } else {
                    _time_inbetween = 500;
                    _progress = 3;
                }
                break;
            case 3:
                Main.createNewGame(_player, _progress_bar, _dungeon, 2);
                _progress = 4;
                _timer = null;
                return;
        }
        
        _timer.start(method(:onTimer), _time_inbetween, false);  
    }

    function onBack() {
        return true;
    }
}