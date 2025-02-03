import Toybox.Lang;

class BronzeKatana extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 14;
        name = "Bronze Katana";
        description = "A simple bronze katana";
        slot = RIGHT_HAND;
        value = 25;
        weight = 4;
        attribute_bonus = {
            :strength => 3,
            :dexterity => 3
        };

        attack = 12;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }


    function getSprite() as ResourceId {
        return $.Rez.Drawables.bronze_katana;
    }

    function deepcopy() as Item {
        var katana = new BronzeKatana();
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

    function toString() as String {
        return name;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

}