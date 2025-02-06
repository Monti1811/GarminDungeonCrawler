import Toybox.Lang;

class GoldDagger extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 62;
        name = "Gold Dagger";
        description = "A powerful gold dagger";
        slot = EITHER_HAND;
        value = 400;
        weight = 0.5;
        attribute_bonus = {
            :dexterity => 4,
            :luck => 4
        };

        attack = 12;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.gold_dagger;
    }

    function deepcopy() as Item {
        var dagger = new GoldDagger();
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
