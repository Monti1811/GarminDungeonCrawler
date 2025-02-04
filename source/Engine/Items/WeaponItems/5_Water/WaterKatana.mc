import Toybox.Lang;

class WaterKatana extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 54;
        name = "Water Katana";
        description = "A powerful water katana";
        slot = RIGHT_HAND;
        value = 100;
        weight = 4;
        attribute_bonus = {
			:strength => 3,
            :intelligence => 3,
            :dexterity => 3
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
        return $.Rez.Drawables.water_katana;
    }

    function deepcopy() as Item {
        var katana = new WaterKatana();
        katana.name = name;
        katana.description = description;
        katana.value = value;
        katana.amount = amount;
        katana.attribute_bonus = attribute_bonus;
        katana.pos = pos;
        katana.equipped = equipped;
        katana.in_inventory = in_inventory;
        katana.attack = attack;
        katana.range = range;
        return katana;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
