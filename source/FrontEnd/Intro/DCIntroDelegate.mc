import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCIntroDelegate extends WatchUi.BehaviorDelegate {

    private var _view as DCIntroView;
    private var _story as Array<String> = [
        "Once upon a time, in a land far away, there was a kingdom called Toybox.",
        "The kingdom was ruled by a wise and just king, who was loved by all his subjects.",
        "But one day, the king fell ill, and the kingdom was thrown into chaos.",
        "The king's advisors, who were greedy and power-hungry, began to fight amongst themselves.",
        "The people of Toybox were afraid, and the kingdom was on the brink of civil war.",
        "But then, a hero appeared. A brave warrior, who had come from a distant land to save the kingdom.",
        "The warrior's name was Sir Toyboxalot, and he was determined to restore peace to the kingdom.",
        "And so, the adventure begins..."
    ];
    private var _font as FontDefinition | FontReference;
    private var index as Number = 0;

    function initialize(view as DCIntroView, story as Array?, font as FontDefinition | FontReference) {
        BehaviorDelegate.initialize();
        self._view = view;
        self._font = font;
        if (story != null) {
            self._story = story;
        }

        _view.setText(_story[index], _font);
        index++;
    }

    function onTap(evt as ClickEvent) as Boolean {
        return advance();
    }

    function onBack() as Boolean {
        return advance();
    }

    function advance() as Boolean {
        if (index < _story.size()) {
            _view.setText(_story[index], _font);
            index++;
            WatchUi.requestUpdate();
            return true;
        }
        // Start game
        Main.startGame();
        return true;
    }

 

}

