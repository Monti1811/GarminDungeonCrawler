import Toybox.Lang;

class Mimic extends Enemy {

    private var _loot as Item? = null;

    function initialize() {
        Enemy.initialize();
        id = 38;
        name = "Mimic";
        description = "A treasure chest that grew teeth. It drops what it swallowed.";
        current_health = 80;
        maxHealth = 80;
        damage = 12;
        armor = 3;
        kill_experience = 30;
        energy_per_turn = 90;
    }

    function getSprite() as ResourceId {
        return $.Rez.Drawables.monster_mimic;
    }

    function findNextMove(map) as Point2D {
        return Enemy.followPlayerDirect(map);
    }

    function setLoot(item as Item?) as Void {
        _loot = item;
    }

    function getLoot() as Item? {
        var loot = _loot;
        if (loot != null) {
            _loot = null;
            return loot;
        }
        return Enemy.getLoot();
    }

    function save() as Dictionary {
        var data = Enemy.save();
        if (_loot != null) {
            data["loot"] = _loot.save();
        }
        return data;
    }

    function onLoad(save_data as Dictionary) as Void {
        Enemy.onLoad(save_data);
        if (save_data["loot"] != null) {
            _loot = Item.load(save_data["loot"] as Dictionary);
        }
    }
}
