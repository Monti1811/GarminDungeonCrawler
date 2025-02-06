import Toybox.Lang;

class GoldLance extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 65;
        name = "Gold Lance";
        description = "A powerful gold lance";
        slot = RIGHT_HAND;
        value = 500;
        weight = 2;
        attribute_bonus = {
            :dexterity => 5,
            :luck => 5
        };

        attack = 16;
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
        return $.Rez.Drawables.gold_lance;
    }

    function deepcopy() as Item {
        var lance = new GoldLance();
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

    // ...existing code...
}
