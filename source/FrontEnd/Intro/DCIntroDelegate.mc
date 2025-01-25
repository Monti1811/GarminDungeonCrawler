import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCIntroDelegate extends WatchUi.BehaviorDelegate {

    private var _view as DCIntroView;
    private var _story as Array<String> = [
        "In the depths of a forgotten dungeon, a dark power stirs.",
        "Long ago, this dungeon was sealed to contain the evil within.",
        "But now, the seal has weakened, and the creatures of the dark have begun to emerge.",
        "The nearby villages live in fear, as monsters raid their homes and steal their peace.",
        "Hope seems lost, but a group of brave adventurers has risen to the challenge.",
        "These heroes, each with their own unique skills and strengths, have ventured into the dungeon.",
        "Their mission: to defeat the dark power and restore peace to the land.",
        "And so, the dungeon crawl begins..."
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

        self._view.setText(_story[index], _font);
        index++;
    }

    function onTap(evt as ClickEvent) as Boolean {
        return self.advance();
    }

    function onBack() as Boolean {
        return self.advance();
    }

    function advance() as Boolean {
        if (index < _story.size()) {
            _view.setText(_story[index], _font);
            index++;
            WatchUi.requestUpdate();
            return true;
        }
        // Start game
        $.Main.startGame();
        return true;
    }

 

}

