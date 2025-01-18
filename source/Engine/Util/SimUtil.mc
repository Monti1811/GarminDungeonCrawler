import Toybox.Lang;

// This is a utility module that contains helper functions for the simulation
module SimUtil {

    function addDictToDict(dict1 as Dictionary, dict2 as Dictionary) {
        var dict2_keys = dict2.keys();
        for (var k = 0; k < dict2_keys.size(); k++) {
            dict1[dict2_keys[k]] = dict2[dict2_keys[k]];
        }
    }

    function createAllPossibleCharacters() as Array<Player> {
        return [
            new Warrior("Warrior"),
            new Mage("Mage"),
            new God("God"),
        ];
    }

    function getRoomName(x as Number, y as Number) as String {
        return $.SaveData.chosen_save + "_dungeon_" + x + "_" + y;
    }

    function getPosFromRoomName(room_name as String) as Point2D {
        var x = room_name.substring(room_name.length() - 3, room_name.length() - 2).toNumber();
        var y = room_name.substring(room_name.length() - 1, room_name.length()).toNumber();
        return [x, y];
        /*return [
            name_array[name_array.size() - 3].toNumber(), 
            name_array[name_array.size() - 1].toNumber()
        ];*/
    }

    function getRandomFromArray(arr as Array) {
        var rand = MathUtil.random(0, arr.size() - 1);
        return arr[rand];
    }

    function getRandomKeyFromDict(dict as Dictionary) {
        var keys = dict.keys();
        var rand = MathUtil.random(0, keys.size() - 1);
        return keys[rand];
    }

    function getRandomFromDict(dict as Dictionary) {
        var keys = dict.keys();
        var rand = MathUtil.random(0, keys.size() - 1);
        return dict[keys[rand]];
    }

}