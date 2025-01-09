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
            new Mage("Mage")
        ];
    }

}