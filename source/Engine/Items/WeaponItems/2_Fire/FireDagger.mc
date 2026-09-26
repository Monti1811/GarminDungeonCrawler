
import Toybox.Lang;

class FireDagger extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 22;
        name = "Fire Dagger";
        description = "A small blade that burns to the touch, cauterizing as it cuts.";
        slot = EITHER_HAND;
        value = 80;
        weight = 1;
        attribute_bonus = {
            :dexterity => 3,
            :luck => 3,
            :strength => 2
        };

        attack = 18;
        attack_type = DEXTERITY;
        element = ELEMENT_FIRE;
    }

    function onEquipItem(player as Player, slot as ItemSlot) as Void {
        WeaponItem.onEquipItem(player, slot);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.fire_dagger;
    }

    function deepcopy() as Item {
        var dagger = new FireDagger();
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