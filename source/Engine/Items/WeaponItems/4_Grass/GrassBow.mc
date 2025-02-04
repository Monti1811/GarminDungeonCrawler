import Toybox.Lang;

class GrassBow extends Bow {

    function initialize() {
        Bow.initialize();
        id = 41;
        name = "Grass Bow";
        description = "A powerful grass bow";
        slot = RIGHT_HAND;
        value = 100;
        weight = 2;
        attribute_bonus = {
			:dexterity => 3,
            :charisma => 2,
            :luck => 1
        };

        attack = 5;
        range = 3;
        range_type = LINEAR;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player) as Void {
        Bow.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        Bow.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.grass_bow;
    }

    function deepcopy() as Item {
        var bow = new GrassBow();
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

    // ...existing code...
}
