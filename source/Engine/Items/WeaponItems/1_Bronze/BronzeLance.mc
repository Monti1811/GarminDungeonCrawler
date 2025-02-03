import Toybox.Lang;

class BronzeLance extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 15;
        name = "Bronze Lance";
        description = "A simple bronze lance";
        slot = RIGHT_HAND;
        value = 20;
        weight = 3;
        attribute_bonus = {
            :dexterity => 4,
            :luck => 4
        };

        attack = 12;
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
        return $.Rez.Drawables.bronze_lance;
    }

    function deepcopy() as Item {
        var lance = new BronzeLance();
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
