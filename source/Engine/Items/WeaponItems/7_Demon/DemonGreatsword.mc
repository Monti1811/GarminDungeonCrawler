import Toybox.Lang;

class DemonGreatsword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 73;
        name = "Demon Greatsword";
        description = "A powerful demon greatsword";
        slot = RIGHT_HAND;
        value = 3000;
        weight = 7;
        attribute_bonus = {
            :strength => 10,
            :dexterity => -2
        };

        attack = 24;
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
        return $.Rez.Drawables.demon_greatsword;
    }

    function deepcopy() as Item {
        var greatsword = new DemonGreatsword();
        // ...existing code...
        greatsword.attack = attack;
        greatsword.range = range;
        return greatsword;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
