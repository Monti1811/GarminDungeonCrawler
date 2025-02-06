import Toybox.Lang;

class GoldStaff extends Staff {

    function initialize() {
        Staff.initialize();
        id = 67;
        name = "Gold Staff";
        description = "A powerful gold staff. If the player has mana available, uses it to perform more powerful attacks.";
        slot = RIGHT_HAND;
        value = 500;
        weight = 1;
        attribute_bonus = {
            :intelligence => 8
        };

        attack = 5;
        range = 1;
        range_type = LINEAR;
        attack_type = INTELLIGENCE;

        mana_loss = 20;
    }

    function activateStaff() as Void {
        Staff.activateStaff();
        attack = 30;
        range = 3;
    }

    function deactivateStaff() as Void {
        Staff.deactivateStaff();
        attack = 5;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        Staff.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        Staff.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.gold_staff;
    }

    function deepcopy() as Item {
        var staff = new GoldStaff();
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

    // ...existing code...
}
