
import Toybox.Lang;

class FireAxe extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 20;
        name = "Fire Axe";
        description = "A powerful fire axe";
        value = 100;
        weight = 3;
        slot = RIGHT_HAND;
        attribute_bonus = {
            :strength => 8,
            :dexterity => -2,
            :luck => -2
        };

        attack = 12;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.fire_axe;
    }

    function deepcopy() as Item {
        var axe = new FireAxe();
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
}