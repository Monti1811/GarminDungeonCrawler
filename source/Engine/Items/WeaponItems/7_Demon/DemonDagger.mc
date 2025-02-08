import Toybox.Lang;

class DemonDagger extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 72;
        name = "Demon Dagger";
        description = "A powerful demon dagger";
        slot = EITHER_HAND;
        value = 1600;
        weight = 0.5;
        attribute_bonus = {
            :dexterity => 6,
            :luck => 6
        };

        attack = 16;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.demon_dagger;
    }

    function deepcopy() as Item {
        var dagger = new DemonDagger();
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
