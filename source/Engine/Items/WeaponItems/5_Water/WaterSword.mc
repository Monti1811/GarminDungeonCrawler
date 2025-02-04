import Toybox.Lang;

class WaterSword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 58;
        name = "Water Sword";
        description = "A powerful water sword";
        slot = RIGHT_HAND;
        value = 100;
        weight = 4;
        attribute_bonus = {
			:strength => 3,
            :intelligence => 2,
            :constitution => 2
        };

        attack = 14;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.water_sword;
    }

    function deepcopy() as Item {
        var sword = new WaterSword();
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

    // ...existing code...
}
