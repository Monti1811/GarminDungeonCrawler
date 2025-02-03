import Toybox.Lang;

class BronzeSword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 18;
        name = "Bronze Sword";
        description = "A simple bronze sword";
        slot = RIGHT_HAND;
        value = 20;
        weight = 4;
        attribute_bonus = {
            :strength => 4,
            :constitution => 2
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
        return $.Rez.Drawables.bronze_sword;
    }

    function deepcopy() as Item {
        var sword = new BronzeSword();
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
