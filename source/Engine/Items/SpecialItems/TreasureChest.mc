import Toybox.Lang;
import Toybox.WatchUi;

class TreasureChest extends Item {
    const KEY_ITEM_ID = 3000;

    var id as Number = 6000;
    var name as String = "Treasure Chest";
    var description as String = "A sturdy chest. It might hold something valuable.";
    var weight as Number = 0;

    var _opened as Boolean = false;
    var _item_taken as Boolean = false;
    var _contents as Item?;

    function initialize() {
        Item.initialize();
    }

    function setContents(item as Item?) as Void {
        _contents = item;
        _item_taken = item == null;
    }

    function hasContents() as Boolean {
        return _contents != null;
    }

    function canBePickedUp(player as Player) as Boolean {
        // Chests stay in the world; they are never added to inventory.
        return false;
    }

    function onInteract(player as Player, room as Room) as Boolean {
        if (!_opened) {
            var inventory = player.getInventory();
            var key = inventory.find(KEY_ITEM_ID) as KeyItem?;
            if (key == null || inventory.remove(key) == null) {
                WatchUi.showToast("You need a key to open this chest.", {:icon=>$.Rez.Drawables.key});
                return false;
            }
            _opened = true;
        }

        if (_contents != null && !_item_taken) {
            var success = player.pickupItem(_contents);
            if (success) {
                _item_taken = true;
                _contents = null;
            }
        }

        return true;
    }

    function getSprite() as ResourceId {
        if (!_opened) {
            return $.Rez.Drawables.chest_closed;
        }
        return _item_taken ? $.Rez.Drawables.chest_open_empty : $.Rez.Drawables.chest_open_full;
    }

    function save() as Dictionary {
        var data = Item.save();
        data["opened"] = _opened;
        data["item_taken"] = _item_taken;
        if (_contents != null) {
            data["contents"] = _contents.save();
        }
        return data;
    }

    function onLoad(save_data as Dictionary) as Void {
        Item.onLoad(save_data);
        if (save_data["opened"] != null) {
            _opened = save_data["opened"] as Boolean;
        }
        if (save_data["item_taken"] != null) {
            _item_taken = save_data["item_taken"] as Boolean;
        }
        if (save_data["contents"] != null) {
            _contents = Item.load(save_data["contents"] as Dictionary);
        }
    }

    function deepcopy() as Item {
        var chest = new TreasureChest();
        chest.pos = pos;
        chest.in_inventory = in_inventory;
        chest._opened = _opened;
        chest._item_taken = _item_taken;
        if (_contents != null) {
            chest._contents = _contents.deepcopy();
        }
        return chest;
    }
}