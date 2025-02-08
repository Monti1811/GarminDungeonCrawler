import Toybox.Lang;

class BloodAxe extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 80;
        name = "Blood Axe";
        description = "A powerful blood axe";
        value = 5000;
        weight = 2;
        slot = RIGHT_HAND;
        attribute_bonus = {
            :strength => 16,
            :dexterity => 2,
            :luck => 2
        };

        attack = 40;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.blood_axe;
    }

    function deepcopy() as Item {
        var axe = new BloodAxe();
        // ...existing code...
        axe.attack = attack;
        axe.range = range;
        return axe;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
