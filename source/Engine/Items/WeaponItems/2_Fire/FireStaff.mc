
import Toybox.Lang;

class FireStaff extends Staff {

    function initialize() {
        Staff.initialize();
        id = 27;
        name = "Fire Staff";
        description = "A powerful fire staff. If the player has mana available, uses it to perform more powerful attacks.";
        slot = RIGHT_HAND;
        value = 100;
        weight = 2;
        attribute_bonus = {
            :intelligence => 4,
            :strength => 2
        };

        attack = 4;
        range = 1;
        range_type = LINEAR;
        attack_type = INTELLIGENCE;

        mana_loss = 20;
    }

    function activateStaff() as Void {
        Staff.activateStaff();
        attack = 26;
        range = 3;
    }

    function deactivateStaff() as Void {
        Staff.deactivateStaff();
        attack = 4;
        range = 1;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.fire_staff;
    }

    function deepcopy() as Item {
        var staff = new FireStaff();
        staff.name = name;
        staff.description = description;
        staff.value = value;
        staff.amount = amount;
        staff.attribute_bonus = attribute_bonus;
        staff.pos = pos;
        staff.equipped = equipped;
        staff.in_inventory = in_inventory;
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
}