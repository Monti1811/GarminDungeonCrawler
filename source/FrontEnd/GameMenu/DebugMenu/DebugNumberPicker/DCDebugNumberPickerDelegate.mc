import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugNumberPickerDelegate extends WatchUi.PickerDelegate {

    private var _callback as Method;

    function initialize(callback as Method) {
        PickerDelegate.initialize();
        _callback = callback;
    }

    function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onAccept(values as Array) as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        _callback.invoke(values[0]);
        return true;
    }
}