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
        var x = ($.Constants.SCREEN_WIDTH * 15 / 360).toNumber();
        var y = ($.Constants.SCREEN_HEIGHT * 25 / 360).toNumber();
        var s = ($.Constants.SCREEN_WIDTH * 32 / 360).toNumber();
        dc.drawScaledBitmap(x, y, s, s, _icon);
    }
}