import Toybox.Lang;

class BloodStaff extends Staff {

    function initialize() {
        Staff.initialize();
        id = 87;
        name = "Blood Staff";
        description = "A powerful blood staff. If the player has mana available, uses it to perform more powerful attacks.";
        slot = RIGHT_HAND;
        value = 5000;
        weight = 1;
        attribute_bonus = {
            :intelligence => 20
        };

        attack = 12;
        range = 1;
        range_type = LINEAR;
        attack_type = INTELLIGENCE;

        mana_loss = 50;
    }

    function activateStaff() as Void {
        Staff.activateStaff();
        attack = 80;
        range = 3;
    }

    function deactivateStaff() as Void {
        Staff.deactivateStaff();
        attack = 12;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        Staff.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        Staff.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.blood_staff;
    }

    function deepcopy() as Item {
        var staff = new BloodStaff();
        // ...existing code...
        staff.attack = attack;
        staff.range = range;
        staff.range_type = range_type;
        staff.active = active;
        staff.current_cooldown = current_cooldown;
        return staff;
    }

    function onLoad(save_data as Dictionary) as Void {
        Staff.onLoad(save_data);
    }

    // ...existing code...
}
