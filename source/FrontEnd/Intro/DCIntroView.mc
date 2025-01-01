import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;


class DCIntroView extends WatchUi.View {

    //private var _continue_icon as BitmapResource;
    //private var _new_game_icon as BitmapResource;
    //private var _knight as AnimationLayer;
    //private var _font as FontResource;
    private var _text as Array<String>;
    private var _font as FontDefinition | FontReference;
    private var _distance as Number;

    private var _middle as Number = 180;


    function initialize() {
        View.initialize();
        _text = ["Welcome to the game!"];
        _font = WatchUi.loadResource($.Rez.Fonts.small);
        _distance = 20;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.clear();

        var start = _middle - Math.floor(_text.size()/2) * 35;
        for (var i = 0; i < _text.size(); i++) {
            dc.drawText(180, start + i * _distance, _font, _text[i], Graphics.TEXT_JUSTIFY_CENTER);
        }

    }

    function setText(text as Array<String>, font as FontDefinition | FontReference, distance as Number) as Void {
        _text = text;
        _font = font;
        _distance = distance;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
