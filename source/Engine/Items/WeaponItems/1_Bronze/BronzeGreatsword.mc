import Toybox.Lang;

class BronzeGreatsword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 13;
        name = "Bronze Greatsword";
        description = "A simple bronze greatsword";
        slot = RIGHT_HAND;
        value = 40;
        weight = 6;
        attribute_bonus = {
            :strength => 6,
            :dexterity => -3
        };

        attack = 15;
        range = 2;
        weapon_type = TWOHAND;
        cooldown = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
        player.unequipItem(LEFT_HAND);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.bronze_greatsword;
    }

    function deepcopy() as Item {
        var greatsword = new BronzeGreatsword();
        greatsword.name = name;
        greatsword.description = description;
        greatsword.value = value;
        greatsword.amount = amount;
        greatsword.attribute_bonus = attribute_bonus;
        greatsword.pos = pos;
        greatsword.equipped = equipped;
        greatsword.in_inventory = in_inventory;
        greatsword.attack = attack;
        greatsword.range = range;
        return greatsword;
    }

    function toString() as String {
        return name;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

}