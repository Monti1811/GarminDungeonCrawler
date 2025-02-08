import Toybox.Lang;

class BloodDagger extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 82;
        name = "Blood Dagger";
        description = "A powerful blood dagger";
        slot = EITHER_HAND;
        value = 4000;
        weight = 0.5;
        attribute_bonus = {
            :dexterity => 10,
            :luck => 10
        };

        attack = 32;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.blood_dagger;
    }

    function deepcopy() as Item {
        var dagger = new BloodDagger();
        // ...existing code...
        dagger.attack = attack;
        dagger.range = range;
        return dagger;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
