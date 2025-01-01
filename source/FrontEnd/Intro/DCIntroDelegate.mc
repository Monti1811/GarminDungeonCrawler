import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class DCIntroDelegate extends WatchUi.BehaviorDelegate {

    private var _view as DCIntroView;
    private var story as Array<Array<String>> = [
        ["Once upon a time, in a land far away, there was a kingdom called Toybox."],
        ["The kingdom was ruled by a wise and just king, who was loved by all his subjects."],
        ["But one day, a dark shadow fell over the land, and the king fell ill."],
        ["The king's daughter, Princess Lily, set out on a quest to find a cure for her father."],
        ["She traveled far and wide, facing many dangers along the way."],
        ["But with the help of her friends, she was able to find the cure and save her father."],
        ["And so, the kingdom was saved, and Princess Lily became a hero to all."],
        ["And they all lived happily ever after."]
    ];
    private var _font as FontDefinition | FontReference;
    private var _distance as Number;
    private var index as Number = 0;

    function initialize(view as DCIntroView, font as FontDefinition | FontReference, distance as Number) {
        BehaviorDelegate.initialize();
        _view = view;
        _font = font;
        _distance = distance;
    }

    function onTap(evt as ClickEvent) as Boolean {
        var tap_coordinates = evt.getCoordinates() as Array<Numeric>;
        if (index < story.size()) {
            _view.setText(story[index], _font, _distance);
            index++;
            WatchUi.requestUpdate();
            return true;
        }
        // Start game
        Main.startGame();
        return true;
    }

 

}

