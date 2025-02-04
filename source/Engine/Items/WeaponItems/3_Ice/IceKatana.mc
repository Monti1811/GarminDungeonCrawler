import Toybox.Lang;

class IceKatana extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 34;
        name = "Ice Katana";
        description = "A powerful ice katana";
        slot = RIGHT_HAND;
        value = 100;
        weight = 4;
        attribute_bonus = {
			:strength => 3,
            :wisdom => 3,
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
        return $.Rez.Drawables.ice_katana;
    }

    function deepcopy() as Item {
        var katana = new IceKatana();
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
