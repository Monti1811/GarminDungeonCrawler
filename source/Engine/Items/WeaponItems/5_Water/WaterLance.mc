import Toybox.Lang;

class WaterLance extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 55;
        name = "Water Lance";
        description = "A powerful water lance";
        slot = RIGHT_HAND;
        value = 100;
        weight = 3;
        attribute_bonus = {
			:dexterity => 3,
            :intelligence => 2,
            :luck => 3,
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
        return $.Rez.Drawables.water_lance;
    }

    function deepcopy() as Item {
        var lance = new WaterLance();
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
