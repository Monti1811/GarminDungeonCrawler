import Toybox.Lang;

module Players {

    var players as Dictionary<Number, Symbol> = {
        0 => :createWarrior,
        1 => :createMage,
    };


    function createWarrior(name as String) as Player {
        return new Warrior(name);
    }

    function createMage(name as String) as Player {
        return new Mage(name);
    }


    function createPlayerFromId(id as Number, name as String) as Player {
        var method = new Method(self, players[id]);
        return method.invoke(name) as Player;
    }

    function createRandomPlayer(name as String) as Player {
        var player_keys = players.keys();
        var rand = MathUtil.random(0, player_keys.size() - 1);
        var method = new Method(self, players[player_keys[rand]]);
        return method.invoke(name) as Player;
    }
}