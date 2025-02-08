import Toybox.Lang;

class DemonKatana extends WeaponItem {

    function initialize() {
        WeaponItem.initialize();
        id = 74;
        name = "Demon Katana";
        description = "A powerful demon katana";
        slot = RIGHT_HAND;
        value = 1000;
        weight = 4;
        attribute_bonus = {
            :strength => 8,
            :dexterity => 8
        };

        attack = 24;
        range = 1;
    }

    function onEquipItem(player as Player) as Void {
        WeaponItem.onEquipItem(player);
    }

    function onUnequipItem(player as Player) as Void {
        WeaponItem.onUnequipItem(player);
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.demon_katana;
    }

    function deepcopy() as Item {
        var katana = new DemonKatana();
        // ...existing code...
        katana.attack = attack;
        katana.range = range;
        return katana;
    }

    function onLoad(save_data as Dictionary) as Void {
        WeaponItem.onLoad(save_data);
    }

    // ...existing code...
}
