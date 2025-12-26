import Toybox.ActivityMonitor;
import Toybox.Math;
import Toybox.Lang;
import Toybox.WatchUi;

module StepGate {

    var _stepsPerTurn as Number = 0;
    var _lastStepReading as Number = 0;
    var _bankedSteps as Number = 0;
    var _lastSyncSuccess as Boolean = true;

    function init() as Void {
        _stepsPerTurn = $.Settings.settings["steps_per_turn"] as Number;
        refreshBaseline();
    }

    function refreshBaseline() as Void {
        var info = ActivityMonitor.getInfo();
        _lastStepReading = info.steps;
        _bankedSteps = 0;
        _lastSyncSuccess = info.steps != null;
    }

    function syncSteps() as Boolean {
        if (_stepsPerTurn <= 0) {
            return true;
        }
        var info = ActivityMonitor.getInfo();
        _lastSyncSuccess = info.steps != null;
        if (info.steps == null) {
            return false;
        }
        var current = info.steps;
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
}
