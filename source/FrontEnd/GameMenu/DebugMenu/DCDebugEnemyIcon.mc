import Toybox.WatchUi;
import Toybox.Graphics;


(:debug)
class DCDebugEnemyIcon extends WatchUi.Drawable {

    private var _icon as BitmapReference;

    function initialize(enemy as Enemy) {
        Drawable.initialize({});
        _icon = enemy.getSpriteRef();
    }

    function draw(dc as Dc) as Void {
        dc.drawScaledBitmap(15, 25, 32, 32, _icon);
    }
}