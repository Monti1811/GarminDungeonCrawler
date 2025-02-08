import Toybox.Lang;

class DemonSword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 78;
        name = "Demon Sword";
        description = "A powerful demon sword";
        slot = RIGHT_HAND;
        value = 2000;
        weight = 3;
        attribute_bonus = {
            :strength => 6,
            :constitution => 6
        };

        attack = 20;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.demon_sword;
    }

    function deepcopy() as Item {
        var sword = new DemonSword();
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
