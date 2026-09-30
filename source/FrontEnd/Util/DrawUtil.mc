import Toybox.Graphics;
import Toybox.Lang;

class DrawUtil {

    static function drawScaledBitmap(dc as Dc, x as Numeric, y as Numeric, width as Numeric, height as Numeric, bitmap as Graphics.BitmapType) as Void {
        if (dc has :drawScaledBitmap) {
            dc.drawScaledBitmap(x, y, width, height, bitmap);
        } else {
            var transform = new Graphics.AffineTransform();
            transform.setToScale(width.toFloat() / bitmap.getWidth().toFloat(), height.toFloat() / bitmap.getHeight().toFloat());
            dc.drawBitmap2(x, y, bitmap, {:transform => transform, :filterMode => Graphics.FILTER_MODE_POINT});
        }
    }

}
