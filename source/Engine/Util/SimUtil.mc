import Toybox.Lang;

// This is a utility module that contains helper functions for the simulation
module SimUtil {

    function addDictToDict(dict1 as Dictionary, dict2 as Dictionary) {
        var dict2_keys = dict2.keys();
        for (var k = 0; k < dict2_keys.size(); k++) {
            dict1[dict2_keys[k]] = dict2[dict2_keys[k]];
        }
    }

    // Buffer room key used during play: buffer_x_y
    function getRoomName(x as Number, y as Number) as String {
        return "buffer_" + x + "_" + y;
    }

    // Real room key used only when saving: {chosen_save}_dungeon_{x}_{y}
    function getRealRoomName(x as Number, y as Number) as String {
        return $.SaveData.chosen_save + "_dungeon_" + x + "_" + y;
    }

    // Parse position from either buffer_x_y or {save}_dungeon_{x}_{y}
    function getPosFromRoomName(room_name as String) as Point2D {
        var parts = StringUtil.split(room_name, '_');
        // buffer_x_y -> parts[1], parts[2]
        // save_dungeon_x_y -> parts[2], parts[3]
        if (parts.size() == 3) {
            return [parts[1].toNumber(), parts[2].toNumber()];
        }
        return [parts[2].toNumber(), parts[3].toNumber()];
    }

    // Convert buffer_x_y -> {chosen_save}_dungeon_{x}_{y}
    function toRealRoomName(buffer_name as String) as String {
        var pos = getPosFromRoomName(buffer_name);
        return getRealRoomName(pos[0], pos[1]);
    }

    // Convert {save}_dungeon_{x}_{y} (or buffer name) -> buffer_x_y
    function toBufferRoomName(real_name as String) as String {
        var pos = getPosFromRoomName(real_name);
        return getRoomName(pos[0], pos[1]);
    }

    function getRandomFromArray(arr) {
        arr = arr as Array;
        var rand = MathUtil.random(0, arr.size() - 1);
        return arr[rand];
    }

    function getRandomKeyFromDict(dict) {
        dict = dict as Dictionary;
        var keys = dict.keys();
        var rand = MathUtil.random(0, keys.size() - 1);
        return keys[rand];
    }

    function getRandomFromDict(dict) {
        dict = dict as Dictionary;
        var keys = dict.keys();
        var rand = MathUtil.random(0, keys.size() - 1);
        return dict[keys[rand]];
    }

}
