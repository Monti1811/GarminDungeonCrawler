import Toybox.Lang;

class BronzeStaff extends Staff {

    function initialize() {
        Staff.initialize();
        id = 17;
        name = "Bronze Staff";
        description = "A simple bronze staff. If the player has mana available, uses it to perform more powerful attacks.";
        slot = RIGHT_HAND;
        value = 20;
        weight = 2;
        attribute_bonus = {
            :intelligence => 4
        };

        attack = 4;
        range = 1;
        range_type = LINEAR;
        attack_type = INTELLIGENCE;

        mana_loss = 20;
    }

    function activateStaff() as Void {
        Staff.activateStaff();
        attack = 22;
        range = 3;
    }

    function deactivateStaff() as Void {
        Staff.deactivateStaff();
        attack = 4;
        range = 1;
    }


    function getSprite() as ResourceId {
        return $.Rez.Drawables.bronze_staff;
    }

    function deepcopy() as Item {
        var staff = new SteelStaff();
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

}
