import Toybox.Lang;

class DemonStaff extends Staff {

    function initialize() {
        Staff.initialize();
        id = 77;
        name = "Demon Staff";
        description = "A powerful demon staff. If the player has mana available, uses it to perform more powerful attacks.";
        slot = RIGHT_HAND;
        value = 2000;
        weight = 1;
        attribute_bonus = {
            :intelligence => 10
        };

        attack = 6;
        range = 1;
        range_type = LINEAR;
        attack_type = INTELLIGENCE;

        mana_loss = 40;
    }

    function activateStaff() as Void {
        Staff.activateStaff();
        attack = 40;
        range = 3;
    }

    function deactivateStaff() as Void {
        Staff.deactivateStaff();
        attack = 6;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        Staff.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        Staff.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.demon_staff;
    }

    function deepcopy() as Item {
        var staff = new DemonStaff();
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
