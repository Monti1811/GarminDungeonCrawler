import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;


class DCGameOverView extends WatchUi.View {

    //private var _continue_icon as BitmapResource;
    //private var _new_game_icon as BitmapResource;
    //private var _knight as AnimationLayer;
    //private var _font as FontResource;
    private var _icon as Bitmap;


    function initialize() {
        View.initialize();
        //_font = WatchUi.loadResource($.Rez.Fonts.small);
        _icon = new WatchUi.Bitmap({:rezId => $.Rez.Drawables.LauncherIcon, :locX => 150, :locY => 150});
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

        dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_BLACK);
        dc.drawText(180, 75, Graphics.FONT_MEDIUM, "You", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(180, 290, Graphics.FONT_MEDIUM, "Died!", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);


    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
