using Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;

class DCCreateGameProgressView extends WatchUi.ProgressBar {

    private var _timer as Timer.Timer;

    function initialize(displayString as String, startValue as Float or Null) {
        ProgressBar.initialize(displayString, startValue);
        _timer = new Timer.Timer();
        _timer.start(method(:onTimer), 1000, false);
    }


    function onTimer() as Void {
        //Main.createNewGame(_player, self);
    }

    function setProgress(progressValue as Lang.Float or Null) as Void {
        ProgressBar.setProgress(progressValue);
    }

    function setDisplayString(displayString as String) as Void {
        ProgressBar.setDisplayString(displayString);
    }
}