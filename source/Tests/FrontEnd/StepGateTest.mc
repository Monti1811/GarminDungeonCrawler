import Toybox.Test;
import Toybox.Lang;
import Toybox.System;

(:test)
module StepGateHelpers {

    function setupSensorMock(sensorMock as Mock.MockInstance) as Void {
        Sensor.setMock(sensorMock);
    }

    function teardownSensorMock() as Void {
        Sensor.setMock(null);
        Mock.resetAll();
    }
}

// --- refreshBaseline reads from Sensor ---

(:test)
function refreshBaselineReadsSensorSteps(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(500);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate.refreshBaseline();

    Test.assertMessage(MockAssert.callCount("sensor", :getSteps, 1, logger), "getSteps should be called once");
    Test.assertEqual(StepGate._lastStepReading, 500);
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function refreshBaselineResetsBankedSteps(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(100);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._bankedSteps = 999;
    StepGate.refreshBaseline();

    Test.assertEqual(StepGate._bankedSteps, 0);
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function refreshBaselineSetsSyncSuccessOnNullSteps(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(null);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate.refreshBaseline();

    Test.assertMessage(!StepGate._lastSyncSuccess, "lastSyncSuccess should be false when steps is null");
    StepGateHelpers.teardownSensorMock();
    return true;
}

// --- syncSteps reads from Sensor and computes delta ---

(:test)
function syncStepsAddsDeltaToBankedSteps(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(500);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;
    StepGate._bankedSteps = 10;

    StepGate.syncSteps();

    Test.assertEqual(StepGate._bankedSteps, 110);
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function syncStepsUpdatesLastStepReading(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(800);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;
    StepGate._bankedSteps = 0;

    StepGate.syncSteps();

    Test.assertEqual(StepGate._lastStepReading, 800);
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function syncStepsReturnsFalseOnNullSteps(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(null);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;

    var result = StepGate.syncSteps();

    Test.assertMessage(!result, "syncSteps should return false when steps is null");
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function syncStepsSetsLastSyncSuccessFalseOnNullSteps(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(null);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;

    StepGate.syncSteps();

    Test.assertMessage(!StepGate._lastSyncSuccess, "lastSyncSuccess should be false");
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function syncStepsSetsLastSyncSuccessTrueOnValidSteps(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(500);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;
    StepGate._lastSyncSuccess = false;

    StepGate.syncSteps();

    Test.assertMessage(StepGate._lastSyncSuccess, "lastSyncSuccess should be true");
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function syncStepsSkipsWhenDisabled(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(500);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 0;
    StepGate._lastStepReading = 0;
    StepGate._bankedSteps = 0;

    StepGate.syncSteps();

    Test.assertMessage(MockAssert.callCount("sensor", :getSteps, 0, logger), "getSteps should not be called when disabled");
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function syncStepsHandlesNegativeDelta(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(100);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 5000;
    StepGate._bankedSteps = 200;

    StepGate.syncSteps();

    Test.assertMessage(StepGate._bankedSteps >= 0, "bankedSteps must not go negative on rollover");
    StepGateHelpers.teardownSensorMock();
    return true;
}

// --- consumeTurn integration: reads sensor, deducts, blocks ---

(:test)
function consumeTurnReadsSensorAndDeducts(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(600);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;
    StepGate._bankedSteps = 50;

    var result = StepGate.consumeTurn();

    Test.assertMessage(result, "consumeTurn should succeed with 250 banked (400->600 + 50 existing)");
    Test.assertEqual(StepGate._bankedSteps, 150);
    Test.assertMessage(MockAssert.callCount("sensor", :getSteps, 1, logger), "getSteps should be called once during consumeTurn");
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function consumeTurnBlocksWhenSensorReturnsNull(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(null);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;
    StepGate._bankedSteps = 200;

    var result = StepGate.consumeTurn();

    Test.assertMessage(!result, "consumeTurn should block when sensor returns null");
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function consumeTurnBlocksWhenNotEnoughStepsFromSensor(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(410);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;
    StepGate._bankedSteps = 5;

    var result = StepGate.consumeTurn();

    Test.assertMessage(!result, "consumeTurn should block (only 15 banked, need 100)");
    Test.assertEqual(StepGate._bankedSteps, 15);
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function consumeTurnAllowedWhenDisabled(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(100);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 0;
    StepGate._bankedSteps = 0;

    var result = StepGate.consumeTurn();

    Test.assertMessage(result, "consumeTurn should allow when disabled");
    Test.assertMessage(MockAssert.callCount("sensor", :getSteps, 0, logger), "getSteps should not be called when disabled");
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function multipleConsumeTurnsWithSensor(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(700);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 400;
    StepGate._bankedSteps = 0;

    StepGate.consumeTurn();
    Test.assertEqual(StepGate._bankedSteps, 200);

    StepGate.consumeTurn();
    Test.assertEqual(StepGate._bankedSteps, 100);

    StepGate.consumeTurn();
    Test.assertEqual(StepGate._bankedSteps, 0);

    Test.assertMessage(!StepGate.consumeTurn(), "4th turn should block (0 banked, sensor still 700)");
    StepGateHelpers.teardownSensorMock();
    return true;
}

// --- Turn guard integration (mirrors Turn.doTurn():55) ---

(:test)
function turnAllowedWhenStepGateDisabled(logger as Test.Logger) as Boolean {
    StepGateHelpers.teardownSensorMock();
    StepGate._stepsPerTurn = 0;
    StepGate._bankedSteps = 0;
    Test.assertMessage(StepGate.consumeTurn(), "Turn allowed when StepGate disabled");
    return true;
}

(:test)
function turnBlockedWhenEnabledNoSteps(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(100);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._bankedSteps = 0;
    StepGate._lastStepReading = 100;

    Test.assertMessage(!StepGate.consumeTurn(), "Turn blocked when enabled but no banked steps");
    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function turnBlockedThenAllowedAfterStepsAccumulate(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 0;
    StepGate._bankedSteps = 0;

    sensorMock.when(:getSteps).thenReturn(30);
    Test.assertMessage(!StepGate.consumeTurn(), "1st turn blocked (30 steps)");

    Test.assertMessage(!StepGate.consumeTurn(), "2nd turn blocked (sensor still 30)");

    sensorMock.when(:getSteps).thenReturn(150);
    Test.assertMessage(StepGate.consumeTurn(), "3rd turn allowed (150 steps, 150 banked)");
    Test.assertEqual(StepGate._bankedSteps, 50);

    StepGateHelpers.teardownSensorMock();
    return true;
}

(:test)
function stepsRemainingReflectsSensorData(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    sensorMock.when(:getSteps).thenReturn(530);
    StepGateHelpers.setupSensorMock(sensorMock);

    StepGate._stepsPerTurn = 100;
    StepGate._lastStepReading = 500;
    StepGate._bankedSteps = 0;

    Test.assertEqual(StepGate.stepsRemaining(), 70);

    StepGateHelpers.teardownSensorMock();
    return true;
}

// --- save/load round-trip ---

(:test)
function stepGateSavePreservesLastStepReading(logger as Test.Logger) as Boolean {
    StepGate._lastStepReading = 1234;
    StepGate._bankedSteps = 50;

    var data = StepGate.save();

    Test.assertEqual(data["lastStepReading"], 1234);
    Test.assertEqual(data["bankedSteps"], 50);
    return true;
}

(:test)
function stepGateLoadRestoresLastStepReading(logger as Test.Logger) as Boolean {
    StepGate._lastStepReading = 0;
    StepGate._bankedSteps = 0;

    StepGate.load({"lastStepReading" => 5000, "bankedSteps" => 75});

    Test.assertEqual(StepGate._lastStepReading, 5000);
    Test.assertEqual(StepGate._bankedSteps, 75);
    return true;
}

(:test)
function stepGateLoadNullDoesNotCrash(logger as Test.Logger) as Boolean {
    StepGate._lastStepReading = 999;
    StepGate._bankedSteps = 99;

    StepGate.load(null);

    Test.assertEqual(StepGate._lastStepReading, 999);
    Test.assertEqual(StepGate._bankedSteps, 99);
    return true;
}

(:test)
function stepGateSaveLoadRoundTrip(logger as Test.Logger) as Boolean {
    StepGate._lastStepReading = 3000;
    StepGate._bankedSteps = 200;

    var data = StepGate.save();
    StepGate._lastStepReading = 0;
    StepGate._bankedSteps = 0;
    StepGate.load(data);

    Test.assertEqual(StepGate._lastStepReading, 3000);
    Test.assertEqual(StepGate._bankedSteps, 200);
    return true;
}

(:test)
function stepGateLoadThenSyncComputesCorrectDelta(logger as Test.Logger) as Boolean {
    var sensorMock = Mock.create("sensor");
    StepGateHelpers.setupSensorMock(sensorMock);

    // Simulate: saved with lastStepReading=500, bankedSteps=50
    StepGate._stepsPerTurn = 100;
    StepGate.load({"lastStepReading" => 500, "bankedSteps" => 50});

    // Now sensor reports 700 steps (200 new since save)
    sensorMock.when(:getSteps).thenReturn(700);
    StepGate.syncSteps();

    Test.assertEqual(StepGate._bankedSteps, 250); // 50 existing + 200 delta
    Test.assertEqual(StepGate._lastStepReading, 700);

    StepGateHelpers.teardownSensorMock();
    return true;
}
