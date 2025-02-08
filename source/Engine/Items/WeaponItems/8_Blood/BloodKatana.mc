import Toybox.Lang;

class BloodKatana extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 84;
        name = "Blood Katana";
        description = "A powerful blood katana";
        slot = RIGHT_HAND;
        value = 5000;
        weight = 4;
        attribute_bonus = {
            :strength => 10,
            :dexterity => 10
        };

        attack = 48;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.blood_katana;
    }

    function deepcopy() as Item {
        var katana = new BloodKatana();
        // ...existing code...
        katana.attack = attack;
        katana.range = range;
        return katana;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
