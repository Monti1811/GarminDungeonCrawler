import Toybox.Lang;

class GoldGreatsword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 63;
        name = "Gold Greatsword";
        description = "A powerful gold greatsword";
        slot = RIGHT_HAND;
        value = 750;
        weight = 7;
        attribute_bonus = {
            :strength => 6,
            :dexterity => -2
        };

        attack = 14;
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
        return $.Rez.Drawables.gold_greatsword;
    }

    function deepcopy() as Item {
        var greatsword = new GoldGreatsword();
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

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
