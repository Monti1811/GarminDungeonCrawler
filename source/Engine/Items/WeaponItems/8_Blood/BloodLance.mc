import Toybox.Lang;

class BloodLance extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 85;
        name = "Blood Lance";
        description = "A powerful blood lance";
        slot = RIGHT_HAND;
        value = 5000;
        weight = 2;
        attribute_bonus = {
            :dexterity => 10,
            :luck => 10
        };

        attack = 40;
        range = 2;
        range_type = LINEAR;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.blood_lance;
    }

    function deepcopy() as Item {
        var lance = new BloodLance();
        // ...existing code...
        lance.attack = attack;
        lance.range = range;
        return lance;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
