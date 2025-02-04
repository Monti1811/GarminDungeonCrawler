import Toybox.Lang;

class WaterDagger extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 52;
        name = "Water Dagger";
        description = "A powerful water dagger";
        slot = EITHER_HAND;
        value = 80;
        weight = 1;
        attribute_bonus = {
            :dexterity => 3,
            :luck => 3,
            :intelligence => 2
        };

        attack = 10;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.water_dagger;
    }

    function deepcopy() as Item {
        var dagger = new WaterDagger();
        dagger.name = name;
        dagger.description = description;
        dagger.value = value;
        dagger.amount = amount;
        dagger.attribute_bonus = attribute_bonus;
        dagger.pos = pos;
        dagger.equipped = equipped;
        dagger.in_inventory = in_inventory;
        dagger.attack = attack;
        dagger.range = range;
        return dagger;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
