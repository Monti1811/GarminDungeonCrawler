import Toybox.Lang;

class GrassSword extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 48;
        name = "Grass Sword";
        description = "A powerful grass sword";
        slot = RIGHT_HAND;
        value = 100;
        weight = 4;
        attribute_bonus = {
			:strength => 3,
            :charisma => 2,
            :constitution => 2,
            :luck => 1,
        };

        attack = 14;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function onUseItem(player as Player) as Void {
        WeaponItem.onUseItem(player);
    }

    function onPickupItem(player as Player) as Void {
        WeaponItem.onPickupItem(player);
    }

    function onDropItem(player as Player) as Void {
        WeaponItem.onDropItem(player);
    }

    function onSellItem(player as Player) as Void {
        WeaponItem.onSellItem(player);
    }

    function onBuyItem(player as Player) as Void {
        WeaponItem.onBuyItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.grass_sword;
    }

    function deepcopy() as Item {
        var sword = new GrassSword();
        sword.name = name;
        sword.description = description;
        sword.value = value;
        sword.amount = amount;
        sword.attribute_bonus = attribute_bonus;
        sword.pos = pos;
        sword.equipped = equipped;
        sword.in_inventory = in_inventory;
        sword.attack = attack;
        sword.range = range;
        return sword;
    }

    function toString() as String {
        return name;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
