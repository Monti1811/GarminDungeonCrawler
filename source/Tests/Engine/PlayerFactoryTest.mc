import Toybox.Lang;
import Toybox.Test;

(:test)
function playerFactoryCreatesWarrior(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "TestWarrior");
    Test.assert(player instanceof Warrior);
    Test.assertEqual(player.name, "TestWarrior");
    return true;
}

(:test)
function playerFactoryCreatesMage(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(1, "TestMage");
    Test.assert(player instanceof Mage);
    Test.assertEqual(player.name, "TestMage");
    return true;
}

(:test)
function playerFactoryCreatesArcher(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(2, "TestArcher");
    Test.assert(player instanceof Archer);
    Test.assertEqual(player.name, "TestArcher");
    return true;
}

(:test)
function playerFactoryCreatesNameless(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(3, "TestNameless");
    Test.assert(player instanceof Nameless);
    Test.assertEqual(player.name, "TestNameless");
    return true;
}

(:test)
function playerFactoryCreatesPaladin(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(4, "TestPaladin");
    Test.assert(player instanceof Paladin);
    Test.assertEqual(player.name, "TestPaladin");
    return true;
}

(:test)
function playerFactoryCreatesGod(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(999, "TestGod");
    Test.assert(player instanceof God);
    Test.assertEqual(player.name, "TestGod");
    return true;
}

(:test)
function playerFactoryDefaultIdCreatesWarrior(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(9999, "Test");
    Test.assert(player instanceof Warrior);
    return true;
}

(:test)
function playerFactoryNullNameUsesDefault(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, null);
    Test.assertEqual(player.name, "Warrior");
    return true;
}

(:test)
function playerFactoryMageNullName(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(1, null);
    Test.assertEqual(player.name, "Mage");
    return true;
}

(:test)
function playerFactoryArcherNullName(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(2, null);
    Test.assertEqual(player.name, "Archer");
    return true;
}

(:test)
function playerFactoryNamelessNullName(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(3, null);
    Test.assertEqual(player.name, "Nameless");
    return true;
}

(:test)
function playerFactoryPaladinNullName(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(4, null);
    Test.assertEqual(player.name, "Paladin");
    return true;
}

(:test)
function playerFactoryGodNullName(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(999, null);
    Test.assertEqual(player.name, "God");
    return true;
}

(:test)
function playerFactoryAllIdsReturnNonNull(logger as Test.Logger) as Boolean {
    for (var i = 0; i < Players.player_ids.size(); i++) {
       Players.createPlayerFromId(Players.player_ids[i], null);
    }
    return true;
}

(:test)
function playerFactoryAllPlayersHavePositiveHealth(logger as Test.Logger) as Boolean {
    for (var i = 0; i < Players.player_ids.size(); i++) {
        var player = Players.createPlayerFromId(Players.player_ids[i], null);
        Test.assert(player.maxHealth > 0);
        Test.assert(player.current_health > 0);
    }
    return true;
}

(:test)
function playerFactoryCreateAllPossibleCharacters(logger as Test.Logger) as Boolean {
    var all = Players.createAllPossibleCharacters();
    Test.assertEqual(all.size(), Players.player_ids.size());
    return true;
}
