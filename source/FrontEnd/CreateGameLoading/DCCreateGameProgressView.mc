using Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Lang;

class DCCreateGameProgressView extends WatchUi.ProgressBar {

    function initialize(displayString as String, startValue as Float or Null) {
        ProgressBar.initialize(displayString, startValue);
    }

    function setProgress(progressValue as Lang.Float or Null) as Void {
        ProgressBar.setProgress(progressValue);
    }

    function setDisplayString(displayString as String) as Void {
        ProgressBar.setDisplayString(displayString);
    }
}