import Toybox.Graphics;
import Toybox.WatchUi;

class HintHelper {

    static function createRightTopHint(rezId) {
        var pos = getRightTopPos() as Point2D;
        return new WatchUi.Bitmap({:rezId=>rezId, :locX=>pos[0], :locY=>pos[1]});
    }

    static function createRightBottomHint(rezId) {
        var pos = getRightBottomPos() as Point2D;
        return new WatchUi.Bitmap({:rezId=>rezId, :locX=>pos[0], :locY=>pos[1]});
    }

    (:venu2)
    static function getRightTopPos() { return [345, 67]; }
    (:venu2)
    static function getRightBottomPos() { return [332, 258]; }

    (:venu2plus)
    static function getRightTopPos() { return [345, 67]; }
    (:venu2plus)
    static function getRightBottomPos() { return [332, 258]; }

    (:venu2s)
    static function getRightTopPos() { return [300, 59]; }
    (:venu2s)
    static function getRightBottomPos() { return [287, 223]; }

    (:venu3)
    static function getRightTopPos() { return [360, 54]; }
    (:venu3)
    static function getRightBottomPos() { return [342, 256]; }

    (:venu3s)
    static function getRightTopPos() { return [318, 59]; }
    (:venu3s)
    static function getRightBottomPos() { return [304, 234]; }

    (:venu441mm)
    static function getRightTopPos() { return [319, 72]; }
    (:venu441mm)
    static function getRightBottomPos() { return [322, 258]; }

    (:venu445mm)
    static function getRightTopPos() { return [360, 54]; }
    (:venu445mm)
    static function getRightBottomPos() { return [342, 256]; }

    (:fenix7s)
    static function getRightTopPos() { return [207, 44]; }
    (:fenix7s)
    static function getRightBottomPos() { return [206, 159]; }

    (:fenix7spro)
    static function getRightTopPos() { return [207, 44]; }
    (:fenix7spro)
    static function getRightBottomPos() { return [206, 159]; }

    (:fenix7)
    static function getRightTopPos() { return [225, 48]; }
    (:fenix7)
    static function getRightBottomPos() { return [225, 172]; }

    (:fenix7pro)
    static function getRightTopPos() { return [225, 48]; }
    (:fenix7pro)
    static function getRightBottomPos() { return [225, 172]; }

    (:fenix7pronowifi)
    static function getRightTopPos() { return [225, 48]; }
    (:fenix7pronowifi)
    static function getRightBottomPos() { return [225, 172]; }

    (:fenix8solar47mm)
    static function getRightTopPos() { return [206, 42]; }
    (:fenix8solar47mm)
    static function getRightBottomPos() { return [206, 165]; }

    (:fenix9prosolar47mm)
    static function getRightTopPos() { return [206, 42]; }
    (:fenix9prosolar47mm)
    static function getRightBottomPos() { return [206, 165]; }

    (:fenix7x)
    static function getRightTopPos() { return [242, 52]; }
    (:fenix7x)
    static function getRightBottomPos() { return [242, 185]; }

    (:fenix7xpro)
    static function getRightTopPos() { return [242, 52]; }
    (:fenix7xpro)
    static function getRightBottomPos() { return [242, 185]; }

    (:fenix7xpronowifi)
    static function getRightTopPos() { return [242, 52]; }
    (:fenix7xpronowifi)
    static function getRightBottomPos() { return [242, 185]; }

    (:fenix8solar51mm)
    static function getRightTopPos() { return [222, 44]; }
    (:fenix8solar51mm)
    static function getRightBottomPos() { return [222, 178]; }

    (:fenix9prosolar51mm)
    static function getRightTopPos() { return [225, 55]; }
    (:fenix9prosolar51mm)
    static function getRightBottomPos() { return [222, 178]; }

    (:fenix843mm)
    static function getRightTopPos() { return [323, 71]; }
    (:fenix843mm)
    static function getRightBottomPos() { return [323, 266]; }

    (:fenix943mm)
    static function getRightTopPos() { return [323, 71]; }
    (:fenix943mm)
    static function getRightBottomPos() { return [323, 266]; }

    (:fenix9pro43mm)
    static function getRightTopPos() { return [323, 71]; }
    (:fenix9pro43mm)
    static function getRightBottomPos() { return [323, 266]; }

    (:fenixe)
    static function getRightTopPos() { return [323, 71]; }
    (:fenixe)
    static function getRightBottomPos() { return [323, 266]; }

    (:fenix847mm)
    static function getRightTopPos() { return [353, 77]; }
    (:fenix847mm)
    static function getRightBottomPos() { return [353, 291]; }

    (:fenix8pro47mm)
    static function getRightTopPos() { return [353, 77]; }
    (:fenix8pro47mm)
    static function getRightBottomPos() { return [353, 291]; }

    (:fenix947mm)
    static function getRightTopPos() { return [353, 77]; }
    (:fenix947mm)
    static function getRightBottomPos() { return [353, 291]; }

    (:fenix9pro47mm)
    static function getRightTopPos() { return [353, 77]; }
    (:fenix9pro47mm)
    static function getRightBottomPos() { return [353, 291]; }

    (:fenix9pro51mm)
    static function getRightTopPos() { return [353, 77]; }
    (:fenix9pro51mm)
    static function getRightBottomPos() { return [353, 291]; }

    (:fr955)
    static function getRightTopPos() { return [224, 50]; }
    (:fr955)
    static function getRightBottomPos() { return [224, 172]; }

    (:enduro3)
    static function getRightTopPos() { return [222, 44]; }
    (:enduro3)
    static function getRightBottomPos() { return [222, 178]; }

    (:fr265s)
    static function getRightTopPos() { return [297, 69]; }
    (:fr265s)
    static function getRightBottomPos() { return [294, 227]; }

    (:approachs50)
    static function getRightTopPos() { return [338, 73]; }
    (:approachs50)
    static function getRightBottomPos() { return [337, 259]; }

    (:approachs7042mm)
    static function getRightTopPos() { return [338, 73]; }
    (:approachs7042mm)
    static function getRightBottomPos() { return [337, 259]; }

    (:descentg2)
    static function getRightTopPos() { return [337, 72]; }
    (:descentg2)
    static function getRightBottomPos() { return [337, 258]; }

    (:descentmk343mm)
    static function getRightTopPos() { return [337, 72]; }
    (:descentmk343mm)
    static function getRightBottomPos() { return [337, 258]; }

    (:epix2pro42mm)
    static function getRightTopPos() { return [337, 72]; }
    (:epix2pro42mm)
    static function getRightBottomPos() { return [337, 258]; }

    (:fr170)
    static function getRightTopPos() { return [323, 73]; }
    (:fr170)
    static function getRightBottomPos() { return [318, 241]; }

    (:fr170m)
    static function getRightTopPos() { return [323, 73]; }
    (:fr170m)
    static function getRightBottomPos() { return [318, 241]; }

    (:fr57042mm)
    static function getRightTopPos() { return [323, 73]; }
    (:fr57042mm)
    static function getRightBottomPos() { return [318, 241]; }

    (:fr70)
    static function getRightTopPos() { return [323, 73]; }
    (:fr70)
    static function getRightBottomPos() { return [318, 241]; }

    (:marq2)
    static function getRightTopPos() { return [337, 72]; }
    (:marq2)
    static function getRightBottomPos() { return [337, 258]; }

    (:marq2aviator)
    static function getRightTopPos() { return [337, 72]; }
    (:marq2aviator)
    static function getRightBottomPos() { return [337, 258]; }

    (:venusq2)
    static function getRightTopPos() { return [307, 70]; }
    (:venusq2)
    static function getRightBottomPos() { return [307, 287]; }

    (:venusq2m)
    static function getRightTopPos() { return [307, 70]; }
    (:venusq2m)
    static function getRightBottomPos() { return [307, 287]; }

    (:venux1)
    static function getRightTopPos() { return [389, 80]; }
    (:venux1)
    static function getRightBottomPos() { return [389, 325]; }

    (:vivoactive5)
    static function getRightTopPos() { return [318, 59]; }
    (:vivoactive5)
    static function getRightBottomPos() { return [304, 234]; }

    (:vivoactive6)
    static function getRightTopPos() { return [319, 72]; }
    (:vivoactive6)
    static function getRightBottomPos() { return [322, 258]; }

    (:d2airx10)
    static function getRightTopPos() { return [345, 67]; }
    (:d2airx10)
    static function getRightBottomPos() { return [332, 258]; }

    (:d2mach1)
    static function getRightTopPos() { return [360, 77]; }
    (:d2mach1)
    static function getRightBottomPos() { return [360, 275]; }

    (:epix2)
    static function getRightTopPos() { return [360, 77]; }
    (:epix2)
    static function getRightBottomPos() { return [360, 275]; }

    (:epix2pro47mm)
    static function getRightTopPos() { return [360, 77]; }
    (:epix2pro47mm)
    static function getRightBottomPos() { return [360, 275]; }

    (:fr265)
    static function getRightTopPos() { return [343, 81]; }
    (:fr265)
    static function getRightBottomPos() { return [339, 259]; }

    (:approachs7047mm)
    static function getRightTopPos() { return [393, 85]; }
    (:approachs7047mm)
    static function getRightBottomPos() { return [392, 302]; }

    (:d2mach2)
    static function getRightTopPos() { return [353, 77]; }
    (:d2mach2)
    static function getRightBottomPos() { return [353, 291]; }

    (:d2mach2pro)
    static function getRightTopPos() { return [353, 77]; }
    (:d2mach2pro)
    static function getRightBottomPos() { return [353, 291]; }

    (:descentmk351mm)
    static function getRightTopPos() { return [393, 84]; }
    (:descentmk351mm)
    static function getRightBottomPos() { return [393, 300]; }

    (:epix2pro51mm)
    static function getRightTopPos() { return [393, 84]; }
    (:epix2pro51mm)
    static function getRightBottomPos() { return [393, 300]; }

    (:fr57047mm)
    static function getRightTopPos() { return [379, 89]; }
    (:fr57047mm)
    static function getRightBottomPos() { return [369, 283]; }

    (:fr965)
    static function getRightTopPos() { return [379, 89]; }
    (:fr965)
    static function getRightBottomPos() { return [369, 283]; }

    (:fr970)
    static function getRightTopPos() { return [379, 89]; }
    (:fr970)
    static function getRightBottomPos() { return [369, 283]; }

}
