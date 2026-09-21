import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

module StepGate {

    var _stepsPerTurn as Number = 0;
    var _lastStepReading as Number = 0;
    var _bankedSteps as Number = 0;
    var _lastSyncSuccess as Boolean = true;

    function init() as Void {
        _stepsPerTurn = $.Settings.settings["steps_per_turn"] as Number;
        refreshBaseline();
    }

    function getSteps() as Number? {
        return Sensor.getSteps();
    }

    function refreshBaseline() as Void {
        _lastStepReading = getSteps();
        _bankedSteps = 0;
        _lastSyncSuccess = _lastStepReading != null;
    }

    function syncSteps() as Boolean {
        if (_stepsPerTurn <= 0) {
            return true;
        }
        var current = getSteps();
        _lastSyncSuccess = current != null;
        if (current == null) {
            return false;
        }
        var delta = current - _lastStepReading;
        if (delta < 0) {
            // Steps counter likely rolled over (e.g. new day). Preserve existing banked steps and
            // update the baseline to the current reading without crediting extra steps.
            _bankedSteps = MathUtil.max(0, _bankedSteps);
        } else {
            _bankedSteps += delta;
        }
        _lastStepReading = current;
        return true;
    }

    function consumeTurn() as Boolean {
        if (_stepsPerTurn <= 0) {
            return true;
        }
		if (!syncSteps()) {
            notifyUser();
            return false;
        }
        if (_bankedSteps < _stepsPerTurn) {
            notifyUser();
            return false;
        }
        _bankedSteps -= _stepsPerTurn;
        return true;
    }

    function notifyUser() as Void {
        var remaining = self.stepsRemaining();
        var message = self.lastSyncSucceeded() ?
            (remaining <= 0 ? "Walk more to move" : remaining + " steps needed") :
            "Steps data unavailable";
        WatchUi.showToast(message, {:icon=>Rez.Drawables.cancelToastIcon});
        return;
    }

    function stepsRemaining() as Number {
        if (_stepsPerTurn <= 0) {
            return 0;
        }
        if (!syncSteps()) {
            return _stepsPerTurn;
        }
        var remaining = _stepsPerTurn - _bankedSteps;
        return remaining < 0 ? 0 : remaining;
    }

    function isEnabled() as Boolean {
        return _stepsPerTurn > 0;
    }

    function lastSyncSucceeded() as Boolean {
        return _lastSyncSuccess;
    }

    function updateFromSetting(val as Number) as Void {
        _stepsPerTurn = val;
        refreshBaseline();
    }

    function resetForSession() as Void {
        init();
    }

    function save() as Dictionary {
        return {
            "lastStepReading" => _lastStepReading,
            "bankedSteps" => _bankedSteps,
        };
    }

    function load(data as Dictionary?) as Void {
        if (data == null) {
            return;
        }
        _lastStepReading = data["lastStepReading"] as Number;
        _bankedSteps = data["bankedSteps"] as Number;
    }
}
