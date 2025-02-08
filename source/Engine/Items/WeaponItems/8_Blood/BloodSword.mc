import Toybox.Lang;

class BloodSword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 88;
        name = "Blood Sword";
        description = "A powerful blood sword";
        slot = RIGHT_HAND;
        value = 5000;
        weight = 3;
        attribute_bonus = {
            :strength => 10,
            :constitution => 10
        };

        attack = 40;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.blood_sword;
    }

    function deepcopy() as Item {
        var sword = new BloodSword();
        // ...existing code...
        sword.attack = attack;
        sword.range = range;
        return sword;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
