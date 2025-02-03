import Toybox.Lang;

class BronzeDagger extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 12;
        name = "Bronze Dagger";
        description = "A simple bronze dagger";
        slot = EITHER_HAND;
        value = 20;
        weight = 1;
        attribute_bonus = {
            :dexterity => 4,
            :luck => 4
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
        return $.Rez.Drawables.bronze_dagger;
    }

    function deepcopy() as Item {
        var dagger = new BronzeDagger();
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
}
