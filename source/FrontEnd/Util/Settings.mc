import Toybox.Lang;
import Toybox.Application.Storage;

module Settings {

    function init() as Void {
        if (Storage.getValue("rooms_amount") == null) {
            Storage.setValue("rooms_amount", 4);
        }
        if (Storage.getValue("min_room_size") == null) {
            Storage.setValue("min_room_size", 5);
        }
        if (Storage.getValue("max_room_size") == null) {
            Storage.setValue("max_room_size", 15);
        }
        if (Storage.getValue("save_on_exit") == null) {
            Storage.setValue("save_on_exit", false);
        }
    }
}