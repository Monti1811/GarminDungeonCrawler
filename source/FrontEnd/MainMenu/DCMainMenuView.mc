import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;


class DCMainMenuView extends WatchUi.View {

    //private var _continue_icon as BitmapResource;
    //private var _new_game_icon as BitmapResource;
    //private var _knight as AnimationLayer;
    //private var _font as FontResource;
    private var _icon as Bitmap;
    private var rightLowHint as Bitmap;


    function initialize() {
        View.initialize();
        //_font = WatchUi.loadResource($.Rez.Fonts.small);
        _icon = new WatchUi.Bitmap({:rezId => $.Rez.Drawables.LauncherIcon, :locX => 150, :locY => 150});
        rightLowHint = new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.rightLow, :locX => 290, :locY => 220});
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

        _icon.draw(dc);

        drawButton(dc, Constants.COORDINATES_LOADGAME, "Load Game");
        drawButton(dc, Constants.COORDINATES_NEWGAME, "New Game");

        rightLowHint.draw(dc);

    }

    function drawButton(dc as Dc, pos as Array<Number>, text as String) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var x = pos[0];
        var y = pos[1];
        var top_left_x = x - pos[2]/2;
        var top_left_y = y - pos[3]/2;
        dc.drawRoundedRectangle(top_left_x, top_left_y, pos[2], pos[3], 5);
        dc.drawText(x, y, Graphics.FONT_GLANCE, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
