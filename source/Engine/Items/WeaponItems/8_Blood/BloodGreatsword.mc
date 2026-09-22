import Toybox.Lang;

class BloodGreatsword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 83;
        name = "Blood Greatsword";
        description = "A massive blade dripping with the essence of the fallen.";
        slot = RIGHT_HAND;
        value = 7500;
        weight = 7;
        attribute_bonus = {
            :strength => 12,
            :dexterity => 8
        };

        attack = 92;
        range = 2;
        weapon_type = TWOHAND;
        cooldown = 1;
    }

    function onEquipItem(player as Player, slot as ItemSlot) as Void {
        WeaponItem.onEquipItem(player, slot);
        player.unequipItem(LEFT_HAND);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.blood_greatsword;
    }

    function deepcopy() as Item {
        var greatsword = new BloodGreatsword();
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
