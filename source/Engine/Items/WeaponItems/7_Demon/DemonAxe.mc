import Toybox.Lang;

class DemonAxe extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 70;
        name = "Demon Axe";
        description = "A powerful demon axe";
        value = 2000;
        weight = 2;
        slot = RIGHT_HAND;
        attribute_bonus = {
            :strength => 12,
            :dexterity => -2,
            :luck => -2
        };

        attack = 20;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.demon_axe;
    }

    function deepcopy() as Item {
        var axe = new DemonAxe();
        // ...existing code...
        axe.attack = attack;
        axe.range = range;
        return axe;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
