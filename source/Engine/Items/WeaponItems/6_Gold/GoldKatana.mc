import Toybox.Lang;

class GoldKatana extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 64;
        name = "Gold Katana";
        description = "A powerful gold katana";
        slot = RIGHT_HAND;
        value = 500;
        weight = 4;
        attribute_bonus = {
            :strength => 5,
            :dexterity => 5
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
        return $.Rez.Drawables.gold_katana;
    }

    function deepcopy() as Item {
        var katana = new GoldKatana();
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
