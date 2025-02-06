import Toybox.Lang;

class GoldSword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 68;
        name = "Gold Sword";
        description = "A powerful gold sword";
        slot = RIGHT_HAND;
        value = 500;
        weight = 3;
        attribute_bonus = {
            :strength => 4,
            :constitution => 4
        };

        attack = 16;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.gold_sword;
    }

    function deepcopy() as Item {
        var sword = new GoldSword();
        sword.name = name;
        sword.description = description;
        sword.value = value;
        sword.amount = amount;
        sword.attribute_bonus = attribute_bonus;
        sword.pos = pos;
        sword.equipped = equipped;
        sword.in_inventory = in_inventory;
        sword.attack = attack;
        sword.range = range;
        return sword;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

}
