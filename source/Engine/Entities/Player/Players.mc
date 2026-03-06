import Toybox.Lang;

module Players {

    var player_ids as Array<Number> = [0, 1, 2, 3, 4, 999];

    function createPlayerFromId(id as Number, name as String?) as Player {
        switch (id) {
            case 0:
                if (name == null) { name = "Warrior"; }
                return new Warrior(name);
            case 1:
                if (name == null) { name = "Mage"; }
                return new Mage(name);
            case 2:
                if (name == null) { name = "Archer"; }
                return new Archer(name);
            case 3:
                if (name == null) { name = "Nameless"; }
                return new Nameless(name);
            case 4:
                if (name == null) { name = "Paladin"; }
                return new Paladin(name);
            case 999:
                if (name == null) { name = "God"; }
                return new God(name);
            default:
                if (name == null) { name = "Warrior"; }
                return new Warrior(name);
        }
    }

    function createRandomPlayer(name as String) as Player {
        var rand = MathUtil.random(0, player_ids.size() - 1);
        return createPlayerFromId(player_ids[rand], name);
    }

    function createAllPossibleCharacters() as Array<Player> {
        var all_players = [] as Array<Player>;
        for (var i = 0; i < player_ids.size(); i++) {
            all_players.add(createPlayerFromId(player_ids[i], null));
        }
        return all_players;
    }
}
