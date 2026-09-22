import Toybox.Lang;

class BronzeBow extends Bow {

    function initialize() {
        Bow.initialize();
        id = 11;
        name = "Bronze Bow";
        description = "A simple bow with a bronze-reinforced riser.";
        slot = RIGHT_HAND;
        value = 25;
        weight = 2;
        attribute_bonus = {
            :dexterity => 3
        };

        attack = 4;
        range = 3;
        range_type = LINEAR;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player, slot as ItemSlot) as Void {
        Bow.onEquipItem(player, slot);
    }

    function onUnequipItem(player as Player) as Void {
        Bow.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.bronze_bow;
    }

    function deepcopy() as Item {
        var bow = new BronzeBow();
        bow.name = name;
        bow.description = description;
        bow.value = value;
        bow.amount = amount;
        bow.attribute_bonus = attribute_bonus;
        bow.pos = pos;
        bow.equipped = equipped;
        bow.in_inventory = in_inventory;
        bow.attack = attack;
        bow.range = range;
        return bow;
    }

    function onLoad(save_data as Dictionary) as Void {
        Bow.onLoad(save_data);
    }
}
