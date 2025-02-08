import Toybox.Lang;

class DemonLance extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 75;
        name = "Demon Lance";
        description = "A powerful demon lance";
        slot = RIGHT_HAND;
        value = 2000;
        weight = 2;
        attribute_bonus = {
            :dexterity => 6,
            :luck => 6
        };

        attack = 20;
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
        return $.Rez.Drawables.demon_lance;
    }

    function deepcopy() as Item {
        var lance = new DemonLance();
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
