import Toybox.Lang;

class IceLance extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 35;
        name = "Ice Lance";
        description = "A powerful ice lance";
        slot = RIGHT_HAND;
        value = 100;
        weight = 3;
        attribute_bonus = {
            :dexterity => 3,
            :luck => 3,
            :wisdom => 2
        };

        attack = 14;
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
        return $.Rez.Drawables.ice_lance;
    }

    function deepcopy() as Item {
        var lance = new IceLance();
        lance.name = name;
        lance.description = description;
        lance.value = value;
        lance.amount = amount;
        lance.attribute_bonus = attribute_bonus;
        lance.pos = pos;
        lance.equipped = equipped;
        lance.in_inventory = in_inventory;
        lance.attack = attack;
        lance.range = range;
        return lance;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

}
