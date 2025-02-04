import Toybox.Lang;

class IceSword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 38;
        name = "Ice Sword";
        description = "A powerful ice sword";
        slot = RIGHT_HAND;
        value = 100;
        weight = 4;
        attribute_bonus = {
			:strength => 3,
            :wisdom => 2,
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
        return $.Rez.Drawables.ice_sword;
    }

    function deepcopy() as Item {
        var sword = new IceSword();
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
