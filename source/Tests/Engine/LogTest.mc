import Toybox.Test;
import Toybox.Lang;

// --- log and getLastMessage ---

(:test)
function logAddsMessageAndGetsLast(logger as Test.Logger) as Boolean {
    Log.clear();
    Log.log("hello");
    Test.assertEqual(Log.getLastMessage(), "hello");
    Log.clear();
    return true;
}

(:test)
function logLastMessageReturnsNullWhenEmpty(logger as Test.Logger) as Boolean {
    Log.clear();
    Test.assertMessage(Log.getLastMessage() == null, "should be null when empty");
    Log.clear();
    return true;
}

(:test)
function logOverwritesPreviousMessage(logger as Test.Logger) as Boolean {
    Log.clear();
    Log.log("first");
    Log.log("second");
    Test.assertEqual(Log.getLastMessage(), "second");
    Log.clear();
    return true;
}

// --- getLastMessages ---

(:test)
function getLastMessagesReturnsNMostRecent(logger as Test.Logger) as Boolean {
    Log.clear();
    Log.log("a");
    Log.log("b");
    Log.log("c");
    var msgs = Log.getLastMessages(2);
    Test.assertEqual(msgs.size(), 2);
    Test.assertEqual(msgs[0], "b");
    Test.assertEqual(msgs[1], "c");
    Log.clear();
    return true;
}

(:test)
function lastMessagesReturnsAllIfNTooLarge(logger as Test.Logger) as Boolean {
    Log.clear();
    Log.log("x");
    Log.log("y");
    var msgs = Log.getLastMessages(10);
    Test.assertEqual(msgs.size(), 2);
    Log.clear();
    return true;
}

(:test)
function lastMessagesReturnsEmptyWhenNone(logger as Test.Logger) as Boolean {
    Log.clear();
    var msgs = Log.getLastMessages(5);
    Test.assertEqual(msgs.size(), 0);
    Log.clear();
    return true;
}

// --- clear ---

(:test)
function clearRemovesAllMessages(logger as Test.Logger) as Boolean {
    Log.clear();
    Log.log("a");
    Log.log("b");
    Log.clear();
    Test.assertMessage(Log.getLastMessage() == null, "should be null after clear");
    Log.clear();
    return true;
}

// --- clearLastMessages ---

(:test)
function clearLastMessagesRemovesOldest(logger as Test.Logger) as Boolean {
    Log.clear();
    Log.log("a");
    Log.log("b");
    Log.log("c");
    Log.clearLastMessages(1);
    Test.assertEqual(Log.messages.size(), 1);
    Test.assertEqual(Log.getLastMessage(), "c");
    Log.clear();
    return true;
}

// --- overflow behavior ---

(:test)
function logTriggersOverflowAtMaxSize(logger as Test.Logger) as Boolean {
    Log.clear();
    // max_size is 100, fill it up
    for (var i = 0; i < 101; i++) {
        Log.log("msg" + i);
    }
    // After overflow, should have ~50 messages (max_size/2)
    Test.assertMessage(Log.messages.size() <= 51, "messages should be trimmed after overflow, got " + Log.messages.size());
    Test.assertEqual(Log.getLastMessage(), "msg100");
    Log.clear();
    return true;
}
