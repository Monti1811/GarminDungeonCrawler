import Toybox.Lang;

class GrassDagger extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 42;
        name = "Grass Dagger";
        description = "A thorn-carved blade pulsing with primal green energy.";
        slot = EITHER_HAND;
        value = 80;
        weight = 1;
        attribute_bonus = {
			:dexterity => 3,
            :charisma => 2,
            :luck => 5
        };

        attack = 6;
        attack_type = DEXTERITY;
    }

    function onEquipItem(player as Player, slot as ItemSlot) as Void {
        WeaponItem.onEquipItem(player, slot);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.grass_dagger;
    }

    function deepcopy() as Item {
        var dagger = new GrassDagger();
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
