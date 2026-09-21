import Toybox.Lang;
import Toybox.Test;

(:test)
module Mock {

    var _mocks as Dictionary<String, MockInstance> = {};

    class MockInstance {
        var _returnValues as Dictionary<Symbol, Object?> = {};
        var _calls as Dictionary<Symbol, Number> = {};

        function when(methodName as Symbol) as MockWhen {
            return new MockWhen(self, methodName);
        }

        function recordCall(methodName as Symbol) as Void {
            if (!_calls.hasKey(methodName)) {
                _calls.put(methodName, 0);
            }
            _calls.put(methodName, (_calls[methodName] as Number) + 1);
        }

        function invoke(methodName as Symbol) as Object? {
            recordCall(methodName);
            if (_returnValues.hasKey(methodName)) {
                return _returnValues[methodName];
            }
            return null;
        }

        function getCallCount(methodName as Symbol) as Number {
            if (_calls.hasKey(methodName)) {
                return _calls[methodName] as Number;
            }
            return 0;
        }

        function reset() as Void {
            _returnValues = {} as Dictionary<Symbol, Object?>;
            _calls = {} as Dictionary<Symbol, Number>;
        }
    }

    class MockWhen {
        var _instance as MockInstance;
        var _methodName as Symbol;

        function initialize(instance as MockInstance, methodName as Symbol) {
            _instance = instance;
            _methodName = methodName;
        }

        function thenReturn(value as Object?) as MockInstance {
            _instance._returnValues.put(_methodName, value);
            return _instance;
        }
    }

    function create(name as String) as MockInstance {
        var instance = new MockInstance();
        _mocks.put(name, instance);
        return instance;
    }

    function get(name as String) as MockInstance? {
        if (_mocks.hasKey(name)) {
            return _mocks[name] as MockInstance;
        }
        return null;
    }

    function resetAll() as Void {
        var names = _mocks.keys();
        for (var i = 0; i < names.size(); i++) {
            var instance = _mocks[names[i]] as MockInstance;
            instance.reset();
        }
    }
}

(:test)
module MockAssert {

    function called(mockName as String, methodName as Symbol, logger as Test.Logger) as Boolean {
        var m = Mock.get(mockName);
        if (m == null) {
            logger.error("Mock '" + mockName + "' not found");
            return false;
        }
        var count = m.getCallCount(methodName);
        if (count == 0) {
            logger.error("Expected '" + mockName + "." + methodName + "' to be called, but was called 0 times");
            return false;
        }
        return true;
    }

    function notCalled(mockName as String, methodName as Symbol, logger as Test.Logger) as Boolean {
        var m = Mock.get(mockName);
        if (m == null) {
            return true;
        }
        var count = m.getCallCount(methodName);
        if (count > 0) {
            logger.error("Expected '" + mockName + "." + methodName + "' to NOT be called, but was called " + count + " times");
            return false;
        }
        return true;
    }

    function callCount(mockName as String, methodName as Symbol, expected as Number, logger as Test.Logger) as Boolean {
        var m = Mock.get(mockName);
        if (m == null) {
            logger.error("Mock '" + mockName + "' not found");
            return false;
        }
        var count = m.getCallCount(methodName);
        if (count != expected) {
            logger.error("Expected '" + mockName + "." + methodName + "' to be called " + expected + " times, but was called " + count + " times");
            return false;
        }
        return true;
    }
}
