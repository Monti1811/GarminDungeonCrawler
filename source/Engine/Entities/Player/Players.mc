import Toybox.Lang;

module Players {

    var players as Dictionary<Number, Symbol> = {
        0 => :createWarrior,
        1 => :createMage,
        2 => :createArcher,

        999 => :createGod,
    };


    function createWarrior(name as String) as Player {
        return new Warrior(name);
    }

    function createMage(name as String) as Player {
        return new Mage(name);
    }

    function createArcher(name as String) as Player {
        return new Archer(name);
    }

    function createGod(name as String) as Player {
        return new God(name);
    }


    function createPlayerFromId(id as Number, name as String) as Player {
        var method = new Lang.Method(self, players[id]);
        return method.invoke(name) as Player;
    }

    function createRandomPlayer(name as String) as Player {
        var player_keys = players.keys();
        var rand = MathUtil.random(0, player_keys.size() - 1);
        var method = new Lang.Method(self, players[player_keys[rand]]);
        return method.invoke(name) as Player;
    }
}