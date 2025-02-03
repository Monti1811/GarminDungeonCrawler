import Toybox.Lang;

class BronzeAxe extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 10;
        name = "Bronze Axe";
        description = "A simple bronze axe";
        value = 25;
        weight = 3;
        slot = RIGHT_HAND;
        attribute_bonus = {
            :strength => 5,
            :dexterity => -1,
            :luck => -1
        };

        attack = 10;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.bronze_axe;
    }

    function deepcopy() as Item {
        var axe = new BronzeAxe();
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
