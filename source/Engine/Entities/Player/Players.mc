import Toybox.Lang;

module Players {

    var players as Dictionary<Number, Symbol> = {
        0 => :createWarrior,
        1 => :createMage,
        2 => :createArcher,
        3 => :createNameless,
        4 => :createPaladin,

        999 => :createGod,
    };


    function createWarrior(name as String?) as Player {
        if (name == null) {
            name = "Warrior";
        }
        return new Warrior(name);
    }

    function createMage(name as String?) as Player {
        if (name == null) {
            name = "Mage";
        }
        return new Mage(name);
    }

    function createArcher(name as String?) as Player {
        if (name == null) {
            name = "Archer";
        }
        return new Archer(name);
    }

    function createNameless(name as String?) as Player {
        if (name == null) {
            name = "Nameless";
        }
        return new Nameless(name);
    }

    function createPaladin(name as String?) as Player {
        if (name == null) {
            name = "Paladin";
        }
        return new Paladin(name);
    }

    function createGod(name as String?) as Player {
        if (name == null) {
            name = "God";
        }
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

    function createAllPossibleCharacters() as Array<Player> {
        var all_players = [] as Array<Player>;
        var player_keys = players.keys();
        for (var i = 0; i < player_keys.size(); i++) {
            var method = new Lang.Method(self, players[player_keys[i]]);
            all_players.add(method.invoke(null) as Player);
        }
        return all_players;
    }
}