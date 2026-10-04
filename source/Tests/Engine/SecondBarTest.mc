import Toybox.Lang;
import Toybox.Test;

(:test)
function secondBarBarbarianRageGainDecayAndClamp(logger as Test.Logger) as Boolean {
    var barb = Players.createPlayerFromId(5, "Barb") as Barbarian;
    Test.assertEqual(barb.second_bar, :rage);
    Test.assertEqual(barb.getMaxSecondBar(), 100);
    Test.assertEqual(barb.getCurrentSecondBar(), 0);

    // Rage for every point of damage dealt
    barb.onDamageDone(12, null);
    Test.assertEqual(barb.getCurrentSecondBar(), 12);

    // Rage for every point of damage taken
    barb.takeDamage(8, null);
    Test.assertEqual(barb.getCurrentSecondBar(), 20);

    // Round with a hit -> no decay
    barb.onTurnDone();
    Test.assertEqual(barb.getCurrentSecondBar(), 20);

    // Round without a hit -> decay -3
    barb.onTurnDone();
    Test.assertEqual(barb.getCurrentSecondBar(), 17);

    // Clamp to 0..max
    barb.doSecondBarDelta(500);
    Test.assertEqual(barb.getCurrentSecondBar(), 100);
    barb.doSecondBarDelta(-500);
    Test.assertEqual(barb.getCurrentSecondBar(), 0);
    return true;
}

(:test)
function secondBarBarbarianRageAttackBonusAndLifesteal(logger as Test.Logger) as Boolean {
    var barb = Players.createPlayerFromId(5, "Barb") as Barbarian;
    Game.setPlayer(barb);
    barb.current_second_bar = 0;
    var base_attack = barb.getAttack(null);
    barb.current_second_bar = 50;
    var mid_attack = barb.getAttack(null);
    barb.current_second_bar = 100;
    var max_attack = barb.getAttack(null);
    Test.assert(mid_attack > base_attack);
    Test.assert(max_attack > mid_attack);

    // Lifesteal at full rage: 10% of the damage done
    barb.takeDamage(10, null);
    var health_before = barb.getHealth();
    barb.current_second_bar = 100;
    barb.onDamageDone(20, null);
    Test.assertEqual(barb.getHealth(), health_before + 2);

    // A round with a hit keeps a full bar -> the +25% bonus is reachable
    barb.current_second_bar = 0;
    barb.onDamageDone(30, null);
    barb.current_second_bar = 100;
    barb.onTurnDone();
    Test.assertEqual(barb.getCurrentSecondBar(), 100);
    var bonus_attack = barb.getAttack(null);
    barb.current_second_bar = 97;
    var no_bonus_attack = barb.getAttack(null);
    Test.assert(bonus_attack > no_bonus_attack);

    // Round without a hit -> decay kicks in again
    barb.onTurnDone();
    Test.assertEqual(barb.getCurrentSecondBar(), 94);
    Game.setPlayer(null);
    return true;
}

(:test)
function secondBarTricksterEnergyCritAndRegen(logger as Test.Logger) as Boolean {
    var trickster = Players.createPlayerFromId(6, "Trickster") as Trickster;
    Game.setPlayer(trickster);
    Test.assertEqual(trickster.second_bar, :energy);
    Test.assertEqual(trickster.getMaxSecondBar(), 100);
    Test.assertEqual(trickster.getCurrentSecondBar(), 100);

    // Full energy doubles the next hit
    trickster.current_second_bar = 100;
    var crit_attack = trickster.getAttack(null);
    trickster.current_second_bar = 99;
    var normal_attack = trickster.getAttack(null);
    Test.assertEqual(crit_attack, normal_attack * 2);

    // The crit consumes energy
    trickster.current_second_bar = 100;
    trickster.onDamageDone(10, null);
    Test.assertEqual(trickster.getCurrentSecondBar(), 75);

    // Energy regenerates every turn, clamped to the max
    trickster.onTurnDone();
    Test.assertEqual(trickster.getCurrentSecondBar(), 80);
    trickster.onTurnDone();
    Test.assertEqual(trickster.getCurrentSecondBar(), 85);
    trickster.current_second_bar = 98;
    trickster.onTurnDone();
    Test.assertEqual(trickster.getCurrentSecondBar(), 100);
    Game.setPlayer(null);
    return true;
}

(:test)
function secondBarDragonoidHeatBurstAndOverheat(logger as Test.Logger) as Boolean {
    var dragonoid = Players.createPlayerFromId(7, "Dragonoid") as Dragonoid;
    Game.setPlayer(dragonoid);
    Test.assertEqual(dragonoid.second_bar, :heat);
    Test.assertEqual(dragonoid.getMaxSecondBar(), 100);
    Test.assertEqual(dragonoid.getCurrentSecondBar(), 0);

    // +25 heat for every hit dealt (outgrows the -5 decay)
    dragonoid.onDamageDone(10, null);
    Test.assertEqual(dragonoid.getCurrentSecondBar(), 25);

    // Heat decays every turn, clamped to 0
    dragonoid.onTurnDone();
    Test.assertEqual(dragonoid.getCurrentSecondBar(), 20);

    // Climbs despite the decay: net +20 per exchange -> full after 5 hits
    var reached_full = false;
    for (var i = 0; i < 8; i++) {
        dragonoid.onDamageDone(10, null);
        if (dragonoid.getCurrentSecondBar() >= 100) {
            reached_full = true;
            break;
        }
        dragonoid.onTurnDone();
    }
    Test.assert(reached_full);
    Test.assert(!dragonoid.overheated);
    // End the exchange so the weapon cooldown is ready again
    dragonoid.onTurnDone();

    // Full heat -> fire burst, then one turn of overheat
    dragonoid.current_second_bar = 100;
    var burst_attack = dragonoid.getAttack(null);
    Test.assert(burst_attack > 0);
    dragonoid.onDamageDone(15, null);
    Test.assertEqual(dragonoid.getCurrentSecondBar(), 0);
    Test.assert(dragonoid.overheated);
    Test.assert(dragonoid.getAttack(null) < burst_attack);
    Test.assertEqual(dragonoid.getCurrentSecondBar(), 0);

    // Overheat lasts one more turn
    dragonoid.onTurnDone();
    Test.assert(dragonoid.overheated);
    dragonoid.onTurnDone();
    Test.assert(!dragonoid.overheated);
    Game.setPlayer(null);
    return true;
}

(:test)
function secondBarManaPotionOnlyForManaClasses(logger as Test.Logger) as Boolean {
    var mage = Players.createPlayerFromId(1, "Mage");
    var mage_potion = new ManaPotion();
    mage.inventory.add(mage_potion);
    var mage_items = mage.inventory.getItems().size();
    mage.current_second_bar = 10;
    var mage_mana = mage.getCurrentSecondBar();
    mage_potion.onUseItem(mage);
    Test.assertEqual(mage.getCurrentSecondBar(), mage_mana + 20);
    Test.assertEqual(mage.inventory.getItems().size(), mage_items - 1);

    var barb = Players.createPlayerFromId(5, "Barb");
    var barb_potion = new ManaPotion();
    barb.inventory.add(barb_potion);
    var barb_items = barb.inventory.getItems().size();
    barb_potion.onUseItem(barb);
    Test.assertEqual(barb.inventory.getItems().size(), barb_items);
    Test.assertEqual(barb.getCurrentSecondBar(), 0);
    return true;
}

(:test)
function secondBarSaveRoundtripNewClasses(logger as Test.Logger) as Boolean {
    var ids = [5, 6, 7];
    for (var i = 0; i < ids.size(); i++) {
        var player = Players.createPlayerFromId(ids[i], "Save");
        player.current_second_bar = 33;
        var save_data = player.save();
        Test.assertEqual(save_data["current_second_bar"], 33);
        var loaded = Players.createPlayerFromId(ids[i], "Load");
        loaded.onLoad(save_data);
        Test.assertEqual(loaded.getCurrentSecondBar(), 33);
        Test.assertEqual(loaded.getMaxSecondBar(), player.getMaxSecondBar());
    }
    return true;
}

(:test)
function secondBarLegacyManaSaveKeysStillLoad(logger as Test.Logger) as Boolean {
    var mage = Players.createPlayerFromId(1, "Mage");
    mage.current_second_bar = 11;
    mage.max_second_bar = 33;
    var save_data = mage.save();
    Test.assertEqual(save_data["current_second_bar"], 11);
    Test.assertEqual(save_data["max_second_bar"], 33);

    // Simulate an old save that only knows the mana keys
    save_data.remove("current_second_bar");
    save_data.remove("max_second_bar");
    save_data["current_mana"] = 7;
    save_data["maxMana"] = 42;
    var loaded = Players.createPlayerFromId(1, "Mage");
    loaded.onLoad(save_data);
    Test.assertEqual(loaded.getCurrentSecondBar(), 7);
    Test.assertEqual(loaded.getMaxSecondBar(), 42);
    return true;
}

(:test)
function secondBarPercentWorksForAllManaClasses(logger as Test.Logger) as Boolean {
    var nameless = Players.createPlayerFromId(3, "Nameless");
    var god = Players.createPlayerFromId(999, "God");
    Test.assert(nameless.getSecondBarPercent() >= 0.0);
    Test.assert(nameless.getSecondBarPercent() <= 1.0);
    Test.assert(god.getSecondBarPercent() >= 0.0);
    Test.assert(god.getSecondBarPercent() <= 1.0);
    return true;
}

(:test)
function secondBarClassNamesAndColors(logger as Test.Logger) as Boolean {
    var barb = Players.createPlayerFromId(5, "Barb");
    var trickster = Players.createPlayerFromId(6, "Trickster");
    var dragonoid = Players.createPlayerFromId(7, "Dragonoid");
    Test.assertEqual(barb.getSecondBarName(), "Rage");
    Test.assertEqual(trickster.getSecondBarName(), "Energy");
    Test.assertEqual(dragonoid.getSecondBarName(), "Heat");
    Test.assert(barb.hasSecondBarResource(:rage));
    Test.assert(trickster.hasSecondBarResource(:energy));
    Test.assert(dragonoid.hasSecondBarResource(:heat));
    Test.assert(!barb.hasSecondBarResource(:mana));
    Test.assert(!trickster.hasSecondBarResource(:mana));
    Test.assert(!dragonoid.hasSecondBarResource(:mana));
    return true;
}

(:test)
function abilityTextForEveryClass(logger as Test.Logger) as Boolean {
    var players = Players.createAllPossibleCharacters();
    for (var i = 0; i < players.size(); i++) {
        var player = players[i];
        Test.assert(player.getDescription().length() > 0);
        // Kurz-Text vorhanden und kurz genug fuer die Info-Seite
        Test.assert(player.getAbilityText().length() > 0);
        Test.assert(player.getAbilityText().length() < 300);
        if (player.second_bar != null) {
            // Der Text erklaert die zweite Bar und nennt sie beim Namen
            Test.assert(player.getAbilityText().find(player.getSecondBarName()) >= 0);
        } else {
            // Klassen ohne zweite Bar sagen das ausdruecklich
            Test.assert(player.getAbilityText().find("No second bar") >= 0);
        }
    }
    return true;
}
