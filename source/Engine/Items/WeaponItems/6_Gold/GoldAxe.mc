import Toybox.Lang;

class GoldAxe extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 60;
        name = "Gold Axe";
        description = "A powerful gold axe";
        value = 500;
        weight = 2;
        slot = RIGHT_HAND;
        attribute_bonus = {
            :strength => 8,
            :dexterity => -1,
            :luck => -1
        };

        attack = 14;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.gold_axe;
    }

    function deepcopy() as Item {
        var axe = new GoldAxe();
        axe.name = name;
        axe.description = description;
        axe.value = value;
        axe.amount = amount;
        axe.attribute_bonus = attribute_bonus;
        axe.pos = pos;
        axe.equipped = equipped;
        axe.in_inventory = in_inventory;
        axe.attack = attack;
        axe.range = range;
        return axe;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
