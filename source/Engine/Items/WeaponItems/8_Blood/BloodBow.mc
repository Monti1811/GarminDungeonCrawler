import Toybox.Lang;

class BloodBow extends Bow {

    function initialize() {
        Bow.initialize();
        id = 81;
        name = "Blood Bow";
        description = "A powerful blood bow";
        slot = RIGHT_HAND;
        value = 5000;
        weight = 1;
        attribute_bonus = {
            :dexterity => 20
        };

        attack = 18;
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
        return $.Rez.Drawables.blood_bow;
    }

    function deepcopy() as Item {
        var bow = new BloodBow();
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
