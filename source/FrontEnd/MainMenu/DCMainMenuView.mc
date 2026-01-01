import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;


class DCMainMenuView extends WatchUi.View {


    public var loadGamePos as Array<Numeric> = [0,0,0,0];
    public var newGamePos as Array<Numeric> = [0,0,0,0];


    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        self.loadGamePos = setButtonPos(dc, Constants.COORDINATES_LOADGAME, "Load Game");
        self.newGamePos = setButtonPos(dc, Constants.COORDINATES_NEWGAME, "New Game");
        setLayout(Rez.Layouts.DCMainMenuView(dc));
    }

    /*
    (x1,y1)----(x2,y1)
      |           |
      |           |
    (x1,y2)----(x2,y2)
    */
    private function setButtonPos(dc as Dc, pos as Array<Number>, text as String) as Array<Numeric> {
        var text_dimensions = dc.getTextDimensions(text, Graphics.FONT_GLANCE);
        var padding = 0;
        var x = pos[0];
        var y = pos[1];
        var x1 = x - text_dimensions[0]/2 - padding;
        var x2 = x + text_dimensions[0]/2 + padding;
        var y1 = y - text_dimensions[1]/2 - padding;
        var y2 = y + text_dimensions[1]/2 + padding;
        Toybox.System.println("Button " + text + " pos: " + x1 + "," + y1 + " to " + x2 + "," + y2);
        return [x1, x2, y1, y2];
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

        View.onUpdate(dc);

        drawButton(dc, self.loadGamePos, "Load Game");
        drawButton(dc, self.newGamePos, "New Game");

    }

    function drawButton(dc as Dc, pos as Array<Number>, text as String) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

        var padding = 4;
        dc.drawRoundedRectangle(
            pos[0]-padding, 
            pos[2]-padding, 
            pos[1]-pos[0]+2*padding, 
            pos[3]-pos[2]+2*padding, 
            5
        );
        dc.drawText((pos[0]+pos[1])/2, (pos[2]+pos[3])/2, Graphics.FONT_GLANCE, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
