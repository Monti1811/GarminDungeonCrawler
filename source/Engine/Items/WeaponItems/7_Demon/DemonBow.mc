import Toybox.Lang;

class DemonBow extends Bow {

    function initialize() {
        Bow.initialize();
        id = 71;
        name = "Demon Bow";
        description = "A powerful demon bow";
        slot = RIGHT_HAND;
        value = 2000;
        weight = 1;
        attribute_bonus = {
            :dexterity => 8
        };

        attack = 9;
        range = 3;
        range_type = LINEAR;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player) as Void {
        Bow.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        Bow.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.demon_bow;
    }

    function deepcopy() as Item {
        var bow = new DemonBow();
        // ...existing code...
        bow.attack = attack;
        bow.range = range;
        return bow;
    }

    function onLoad(save_data as Dictionary) as Void {
        Bow.onLoad(save_data);
    }

    // ...existing code...
}
