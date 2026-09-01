import Toybox.Lang;
import Toybox.Test;

(:test) var listener_test_called as Boolean = false;
(:test) var listener_test_args as Object? = null;

(:test)
class TestListenerHandler {
    function callback(args) as Void {
        listener_test_called = true;
        listener_test_args = args;
    }
}

(:test)
function listenerAddAndTrigger(logger as Test.Logger) as Boolean {
    Listener.clear();
    listener_test_called = false;
    var handler = new TestListenerHandler();
    var cb = handler.method(:callback);
    Listener.addListener(:testEvent, cb);
    Listener.trigger(:testEvent, "hello");
    Test.assert(listener_test_called);
    Test.assertEqual(listener_test_args, "hello");
    return true;
}

(:test)
function listenerTriggerNoListenersDoesNotCrash(logger as Test.Logger) as Boolean {
    Listener.clear();
    Listener.trigger(:nonexistent, null);
    return true;
}

(:test)
function listenerMultipleListenersAllCalled(logger as Test.Logger) as Boolean {
    Listener.clear();
    listener_test_called = false;
    var handler = new TestListenerHandler();
    var cb = handler.method(:callback);
    Listener.addListener(:ev, cb);
    Listener.addListener(:ev, cb);
    Listener.trigger(:ev, null);
    Test.assert(listener_test_called);
    return true;
}

(:test)
function listenerRemoveListener(logger as Test.Logger) as Boolean {
    Listener.clear();
    listener_test_called = false;
    var handler = new TestListenerHandler();
    var cb = handler.method(:callback);
    Listener.addListener(:ev, cb);
    Listener.removeListener(:ev, cb);
    Listener.trigger(:ev, null);
    Test.assert(!listener_test_called);
    return true;
}

(:test)
function listenerRemoveNonexistentDoesNotCrash(logger as Test.Logger) as Boolean {
    Listener.clear();
    var handler = new TestListenerHandler();
    var cb = handler.method(:callback);
    Listener.removeListener(:ev, cb);
    return true;
}

(:test)
function listenerClearRemovesAll(logger as Test.Logger) as Boolean {
    Listener.clear();
    listener_test_called = false;
    var handler = new TestListenerHandler();
    var cb = handler.method(:callback);
    Listener.addListener(:ev, cb);
    Listener.clear();
    Listener.trigger(:ev, null);
    Test.assert(!listener_test_called);
    return true;
}

(:test)
function listenerDifferentEventsAreIndependent(logger as Test.Logger) as Boolean {
    Listener.clear();
    listener_test_called = false;
    var handler = new TestListenerHandler();
    var cb = handler.method(:callback);
    Listener.addListener(:ev1, cb);
    Listener.trigger(:ev2, null);
    Test.assert(!listener_test_called);
    Listener.trigger(:ev1, null);
    Test.assert(listener_test_called);
    return true;
}
