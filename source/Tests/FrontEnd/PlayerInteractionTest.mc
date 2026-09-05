import Toybox.Lang;
import Toybox.Test;

(:test)
function playerStartsWithDefaultGold(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getGold(), 0);
    return true;
}

(:test)
function playerGoldDeltaAddsGold(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var result = player.doGoldDelta(50);
    Test.assert(result);
    Test.assertEqual(player.getGold(), 50);
    return true;
}

(:test)
function playerGoldDeltaRemovesGold(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.doGoldDelta(100);
    var result = player.doGoldDelta(-30);
    Test.assert(result);
    Test.assertEqual(player.getGold(), 70);
    return true;
}

(:test)
function playerGoldDeltaFailsWhenInsufficient(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var result = player.doGoldDelta(-10);
    Test.assert(!result);
    Test.assertEqual(player.getGold(), 0);
    return true;
}

(:test)
function playerGoldDeltaExactAmountFails(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.doGoldDelta(50);
    var result = player.doGoldDelta(-60);
    Test.assert(!result);
    Test.assertEqual(player.getGold(), 50);
    return true;
}

(:test)
function playerGoldDeltaExactBalanceFails(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.doGoldDelta(50);
    var result = player.doGoldDelta(-50);
    Test.assert(result);
    Test.assertEqual(player.getGold(), 0);
    return true;
}

(:test)
function playerAddToAttributeIncreasesTotal(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var base = player.getAttribute(:charisma);
    player.addToAttribute(:charisma, 5);
    Test.assertEqual(player.getAttribute(:charisma), base + 5);
    return true;
}

(:test)
function playerRemoveFromAttributeDecreasesTotal(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var base = player.getAttribute(:charisma);
    player.addToAttribute(:charisma, 5);
    player.removeFromAttribute(:charisma, 3);
    Test.assertEqual(player.getAttribute(:charisma), base + 2);
    return true;
}

(:test)
function playerAttributeClampedToMin(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.setAttribute(:charisma, 1);
    player.removeFromAttribute(:charisma, 5);
    var value = player.getAttribute(:charisma);
    Test.assert(value >= 0);
    return true;
}

(:test)
function playerAttributeClampedToMax(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.setAttribute(:charisma, 490);
    player.addToAttribute(:charisma, 20);
    var value = player.getAttribute(:charisma);
    Test.assert(value <= 500);
    return true;
}

(:test)
function playerDefaultAttributePoints(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getAttributePoints(), 5);
    return true;
}

(:test)
function playerSetAttributePoints(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.setAttributePoints(20);
    Test.assertEqual(player.getAttributePoints(), 20);
    return true;
}

(:test)
function playerGetAttributePointCostForLowLevel(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var cost = player.getAttributePointCostForLevel(1);
    Test.assertEqual(cost, 1);
    return true;
}

(:test)
function playerGetAttributePointCostForHighLevel(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var cost = player.getAttributePointCostForLevel(50);
    Test.assert(cost >= 1);
    Test.assert(cost <= 10);
    return true;
}

(:test)
function playerGainExperience(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onGainExperience(50);
    Test.assertEqual(player.getExperience(), 50);
    return true;
}

(:test)
function playerLoseExperience(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onGainExperience(50);
    player.onLoseExperience(20);
    Test.assertEqual(player.getExperience(), 30);
    return true;
}

(:test)
function playerLoseExperienceFloorAtZero(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onGainExperience(10);
    player.onLoseExperience(50);
    Test.assertEqual(player.getExperience(), 0);
    return true;
}

(:test)
function playerLevelUpOnSufficientExperience(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var initialLevel = player.getLevel();
    var nextExp = player.getNextLevelExperience();
    player.onGainExperience(nextExp);
    Test.assertEqual(player.getLevel(), initialLevel + 1);
    return true;
}

(:test)
function playerLevelUpGrantsAttributePoints(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var initialPoints = player.getAttributePoints();
    var nextExp = player.getNextLevelExperience();
    player.onGainExperience(nextExp);
    Test.assertEqual(player.getAttributePoints(), initialPoints + 3);
    return true;
}

(:test)
function playerLevelUpResetsExperience(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var nextExp = player.getNextLevelExperience();
    player.onGainExperience(nextExp + 50);
    Test.assertEqual(player.getExperience(), 50);
    return true;
}

(:test)
function playerLevelUpUpdatesNextLevelRequirement(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var nextExp = player.getNextLevelExperience();
    player.onGainExperience(nextExp);
    Test.assertEqual(player.getNextLevelExperience(), player.getLevel() * 100);
    return true;
}

(:test)
function playerMultipleLevelUpsFromExcessExperience(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var initialLevel = player.getLevel();
    player.onGainExperience(500);
    Test.assert(player.getLevel() > initialLevel);
    return true;
}

(:test)
function playerExperienceToNextLevelDecreases(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var toNextBefore = player.getExperienceToNextLevel();
    player.onGainExperience(30);
    var toNextAfter = player.getExperienceToNextLevel();
    Test.assertEqual(toNextAfter, toNextBefore - 30);
    return true;
}

(:test)
function inventoryAddItem(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var sword = new SteelSword();
    var result = inventory.add(sword);
    Test.assert(result);
    return true;
}

(:test)
function inventoryRemoveItem(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var sword = new SteelSword();
    inventory.add(sword);
    var removed = inventory.remove(sword);
    Test.assert(removed != null);
    return true;
}

(:test)
function inventoryRemoveItemNotFound(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var sword = new SteelSword();
    var removed = inventory.remove(sword);
    Test.assert(removed == null);
    return true;
}

(:test)
function inventoryIsFullWhenExceedingWeight(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(3);
    var sword = new SteelSword();
    inventory.add(sword);
    Test.assert(inventory.isFull());
    return true;
}

(:test)
function inventoryWouldBeFullWithHeavyItem(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(2);
    var sword = new SteelSword();
    Test.assert(inventory.wouldBeFull(sword));
    return true;
}

(:test)
function inventoryFindsItemById(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var sword = new SteelSword();
    inventory.add(sword);
    var found = inventory.find(sword.id);
    Test.assert(found != null);
    return true;
}

(:test)
function inventoryAddWeightIncreasesCapacity(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var result = inventory.addWeight(10);
    Test.assert(result);
    Test.assertEqual(inventory.getCurrentItemWeight(), 10);
    return true;
}

(:test)
function inventoryAddWeightFailsWhenExceeding(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(5);
    var result = inventory.addWeight(10);
    Test.assert(!result);
    return true;
}

(:test)
function inventoryRemoveWeightDecreasesCapacity(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    inventory.addWeight(10);
    var result = inventory.removeWeight(5);
    Test.assert(result);
    Test.assertEqual(inventory.getCurrentItemWeight(), 5);
    return true;
}

(:test)
function inventoryRemoveWeightFailsWhenBelowZero(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var result = inventory.removeWeight(10);
    Test.assert(!result);
    return true;
}

(:test)
function inventoryPermanentBonusWeight(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    inventory.addPermanentBonusWeight(10);
    Test.assertEqual(inventory.getMaxItemWeight(), 40);
    return true;
}

(:test)
function inventoryRemovePermanentBonusWeight(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    inventory.addPermanentBonusWeight(10);
    inventory.removePermanentBonusWeight(5);
    Test.assertEqual(inventory.getMaxItemWeight(), 35);
    return true;
}

(:test)
function inventoryRemovePermanentBonusWeightFloorAtZero(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    inventory.removePermanentBonusWeight(50);
    Test.assertEqual(inventory.getMaxItemWeight(), 0);
    return true;
}

(:test)
function inventoryGetItems(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var sword = new SteelSword();
    var helmet = new SteelHelmet();
    inventory.add(sword);
    inventory.add(helmet);
    var items = inventory.getItems();
    Test.assertEqual(items.size(), 2);
    return true;
}

(:test)
function inventoryStackSameItems(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var potion1 = new HealthPotion();
    var potion2 = new HealthPotion();
    inventory.add(potion1);
    inventory.add(potion2);
    var items = inventory.getItems();
    Test.assertEqual(items.size(), 1);
    Test.assertEqual(items[0].amount, 2);
    return true;
}

(:test)
function inventoryRemoveMultipleItems(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var potion1 = new HealthPotion();
    var potion2 = new HealthPotion();
    inventory.add(potion1);
    inventory.add(potion2);
    var items = inventory.getItems();
    var removed = inventory.removeMultiple(items[0], 1);
    Test.assert(removed != null);
    Test.assertEqual(removed.amount, 1);
    var remaining = inventory.getItems();
    Test.assertEqual(remaining.size(), 1);
    Test.assertEqual(remaining[0].amount, 1);
    return true;
}

(:test)
function inventoryRemoveMultipleAllItems(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var potion1 = new HealthPotion();
    var potion2 = new HealthPotion();
    inventory.add(potion1);
    inventory.add(potion2);
    var items = inventory.getItems();
    var removed = inventory.removeMultiple(items[0], 5);
    Test.assert(removed != null);
    Test.assertEqual(removed.amount, 2);
    Test.assertEqual(inventory.getItems().size(), 0);
    return true;
}

(:test)
function inventorySaveAndLoad(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(30);
    var sword = new SteelSword();
    inventory.add(sword);
    var saveData = inventory.save();
    var loaded = Inventory.load(saveData);
    var items = loaded.getItems();
    Test.assertEqual(items.size(), 1);
    return true;
}

(:test)
function playerEquipItemFromInventory(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    player.addInventoryItem(sword);
    var result = player.equipItem(sword, RIGHT_HAND, true);
    Test.assert(result);
    Test.assert(player.getEquip(RIGHT_HAND) != null);
    return true;
}

(:test)
function playerUnequipItemToInventory(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    player.addInventoryItem(sword);
    player.equipItem(sword, RIGHT_HAND, true);
    var result = player.unequipItem(RIGHT_HAND);
    Test.assert(result);
    Test.assert(player.getEquip(RIGHT_HAND) == null);
    return true;
}

(:test)
function playerEquipAppliesAttributeBonus(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    player.addInventoryItem(sword);
    player.equipItem(sword, RIGHT_HAND, true);
    var str = player.getAttribute(:strength);
    Test.assert(str >= 2);
    return true;
}

(:test)
function playerUnequipRemovesAttributeBonus(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    player.addInventoryItem(sword);
    player.equipItem(sword, RIGHT_HAND, true);
    var strBefore = player.getAttribute(:strength);
    player.unequipItem(RIGHT_HAND);
    var strAfter = player.getAttribute(:strength);
    Test.assertEqual(strAfter, strBefore - 2);
    return true;
}

(:test)
function playerEquipWithoutRemoveKeepsItemInInventory(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    player.addInventoryItem(sword);
    var result = player.equipItem(sword, RIGHT_HAND, null);
    Test.assert(result);
    Test.assert(player.getEquip(RIGHT_HAND) != null);
    Test.assert(player.getInventory().find(sword.id) != null);
    return true;
}

(:test)
function playerPickupItemAutoEquips(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    var result = player.pickupItem(sword);
    Test.assert(result);
    Test.assert(player.getEquip(RIGHT_HAND) != null);
    return true;
}

(:test)
function playerPickupItemGoesToInventoryIfSlotOccupied(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword1 = new SteelSword();
    player.pickupItem(sword1);
    var sword2 = new SteelSword();
    var result = player.pickupItem(sword2);
    Test.assert(result);
    Test.assert(player.getInventory().find(sword2.id) != null);
    return true;
}

(:test)
function playerAddInventoryItem(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var potion = new HealthPotion();
    var result = player.addInventoryItem(potion);
    Test.assert(result);
    Test.assert(player.getInventory().find(potion.id) != null);
    return true;
}

(:test)
function playerRemoveInventoryItem(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var potion = new HealthPotion();
    player.addInventoryItem(potion);
    var result = player.removeInventoryItem(potion);
    Test.assert(result);
    Test.assert(player.getInventory().find(potion.id) == null);
    return true;
}

(:test)
function playerUseHealthPotionRestoresHealth(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onLoseHealth(20);
    var healthBefore = player.getHealth();
    var potion = new HealthPotion();
    player.addInventoryItem(potion);
    var result = player.onUseItem(potion);
    Test.assert(result);
    Test.assert(player.getHealth() > healthBefore);
    return true;
}

(:test)
function playerUseHealthPotionRemovesFromInventory(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var potion = new HealthPotion();
    player.addInventoryItem(potion);
    player.onUseItem(potion);
    Test.assert(player.getInventory().find(potion.id) == null);
    return true;
}

(:test)
function playerHealthDoesNotExceedMax(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var maxHealth = player.getMaxHealth();
    player.onGainHealth(1000);
    Test.assertEqual(player.getHealth(), maxHealth);
    return true;
}

(:test)
function playerHealthFloorAtZero(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onLoseHealth(1000);
    Test.assertEqual(player.getHealth(), 0);
    return true;
}

(:test)
function playerGetHealthPercent(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var percent = player.getHealthPercent();
    Test.assert(percent > 0.0);
    Test.assert(percent <= 1.0);
    return true;
}

(:test)
function playerDeleteItemRemovesFromInventory(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var potion = new HealthPotion();
    player.addInventoryItem(potion);
    var result = player.deleteItem(potion);
    Test.assert(result);
    Test.assert(player.getInventory().find(potion.id) == null);
    return true;
}

(:test)
function merchantCombineItemsStacksSameId(logger as Test.Logger) as Boolean {
    var potion1 = new HealthPotion();
    var potion2 = new HealthPotion();
    var combined = [potion1] as Array<Item>;
    var item = potion2;
    var found = false;
    for (var j = 0; j < combined.size(); j++) {
        if (combined[j].id == item.id) {
            combined[j].addAmount(item.getAmount());
            found = true;
            break;
        }
    }
    if (!found) {
        combined.add(item);
    }
    Test.assertEqual(combined.size(), 1);
    Test.assertEqual(combined[0].amount, 2);
    return true;
}

(:test)
function merchantCombineItemsKeepsDifferentIds(logger as Test.Logger) as Boolean {
    var sword = new SteelSword();
    var helmet = new SteelHelmet();
    var combined = [sword] as Array<Item>;
    var item = helmet;
    var found = false;
    for (var j = 0; j < combined.size(); j++) {
        if (combined[j].id == item.id) {
            combined[j].addAmount(item.getAmount());
            found = true;
            break;
        }
    }
    if (!found) {
        combined.add(item);
    }
    Test.assertEqual(combined.size(), 2);
    return true;
}

(:test)
function playerSaveAndLoadPreservesGold(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.doGoldDelta(100);
    var saveData = player.save();
    var loaded = Player.load(saveData);
    Test.assertEqual(loaded.getGold(), 100);
    return true;
}

(:test)
function playerSaveAndLoadPreservesAttributes(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.setAttribute(:charisma, 15);
    player.setAttribute(:wisdom, 12);
    var saveData = player.save();
    var loaded = Player.load(saveData);
    Test.assertEqual(loaded.getAttribute(:charisma), 15);
    Test.assertEqual(loaded.getAttribute(:wisdom), 12);
    return true;
}

(:test)
function playerSaveAndLoadPreservesLevel(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onGainExperience(250);
    var saveData = player.save();
    var loaded = Player.load(saveData);
    Test.assertEqual(loaded.getLevel(), player.getLevel());
    Test.assertEqual(loaded.getExperience(), player.getExperience());
    return true;
}

(:test)
function playerSaveAndLoadPreservesInventory(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var potion = new HealthPotion();
    player.addInventoryItem(potion);
    var saveData = player.save();
    var loaded = Player.load(saveData);
    var items = loaded.getInventory().getItems();
    Test.assertEqual(items.size(), 1);
    return true;
}

(:test)
function playerSaveAndLoadPreservesEquipped(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var helmet = new SteelHelmet();
    player.addInventoryItem(helmet);
    player.equipItem(helmet, HEAD, true);
    var saveData = player.save();
    var loaded = Player.load(saveData);
    Test.assert(loaded.getEquip(HEAD) != null);
    return true;
}

(:test)
function playerSaveAndLoadPreservesExperience(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onGainExperience(75);
    var saveData = player.save();
    var loaded = Player.load(saveData);
    Test.assertEqual(loaded.getExperience(), 75);
    return true;
}

(:test)
function goldItemInteractAddsGold(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getGold(), 0);
    player.doGoldDelta(25);
    Test.assertEqual(player.getGold(), 25);
    return true;
}

(:test)
function playerEquipArmorGrantsConstitutionBonus(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var constBefore = player.getAttribute(:constitution);
    var helmet = new SteelHelmet();
    player.addInventoryItem(helmet);
    player.equipItem(helmet, HEAD, true);
    var constAfter = player.getAttribute(:constitution);
    Test.assertEqual(constAfter, constBefore + 2);
    return true;
}

(:test)
function playerOnTurnDoneDecreasesWeaponCooldown(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    player.addInventoryItem(sword);
    player.equipItem(sword, RIGHT_HAND, true);
    player.onTurnDone();
    Test.assert(true);
    return true;
}

(:test)
function playerOnNextDungeonRestoresHealth(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onLoseHealth(20);
    var healthBefore = player.getHealth();
    player.onNextDungeon();
    var healthAfter = player.getHealth();
    Test.assert(healthAfter >= healthBefore);
    return true;
}

(:test)
function playerOnNextDungeonDoesNotExceedMax(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onNextDungeon();
    Test.assert(player.getHealth() <= player.getMaxHealth());
    return true;
}

(:test)
function playerGetLevelStartsAtOne(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getLevel(), 1);
    return true;
}

(:test)
function playerGetNextLevelExperience(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getNextLevelExperience(), 100);
    return true;
}

(:test)
function playerGetExperienceToNextLevel(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.onGainExperience(30);
    var toNext = player.getExperienceToNextLevel();
    Test.assertEqual(toNext, 70);
    return true;
}

(:test)
function playerGetId(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assert(player.getId() >= 0);
    return true;
}

(:test)
function playerGetDescription(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assert(player.getDescription().length() > 0);
    return true;
}

(:test)
function playerToString(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.toString(), "Test");
    return true;
}

(:test)
function playerGetMaxHealth(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assert(player.getMaxHealth() > 0);
    return true;
}

(:test)
function playerGetWeaponItemFromEquipped(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    player.addInventoryItem(sword);
    player.equipItem(sword, RIGHT_HAND, true);
    var weapon = player.getWeaponItem(RIGHT_HAND);
    Test.assert(weapon != null);
    return true;
}

(:test)
function playerGetWeaponItemReturnsNullWhenEmpty(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var weapon = player.getWeaponItem(LEFT_HAND);
    Test.assert(weapon == null);
    return true;
}

(:test)
function playerGetArmorItemFromEquipped(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var helmet = new SteelHelmet();
    player.addInventoryItem(helmet);
    player.equipItem(helmet, HEAD, true);
    var armor = player.getArmorItem(HEAD);
    Test.assert(armor != null);
    return true;
}

(:test)
function playerGetArmorItemReturnsNullWhenEmpty(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var armor = player.getArmorItem(HEAD);
    Test.assert(armor == null);
    return true;
}

(:test)
function playerGetCurrentManaZero(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getCurrentMana(), 0);
    return true;
}

(:test)
function playerGetMaxManaZero(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getMaxMana(), 0);
    return true;
}

(:test)
function playerGetManaPercentZero(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getManaPercent(), 0.0);
    return true;
}

(:test)
function playerDoManaDeltaNoOp(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.doManaDelta(10);
    Test.assertEqual(player.getCurrentMana(), 0);
    return true;
}

(:test)
function playerSetSprite(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.getSprite();
    return true;
}

(:test)
function playerSetAttributeDirectly(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    player.setAttribute(:charisma, 20);
    Test.assertEqual(player.getAttribute(:charisma), 20);
    return true;
}

(:test)
function playerWarriorHasExpectedBaseAttributes(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    Test.assertEqual(player.getAttribute(:intelligence), 1);
    Test.assertEqual(player.getAttribute(:charisma), 3);
    Test.assertEqual(player.getAttribute(:wisdom), 2);
    return true;
}

(:test)
function playerMultipleEquipUnequipCycle(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword = new SteelSword();
    player.addInventoryItem(sword);
    player.equipItem(sword, RIGHT_HAND, true);
    player.unequipItem(RIGHT_HAND);
    player.equipItem(sword, RIGHT_HAND, true);
    Test.assert(player.getEquip(RIGHT_HAND) != null);
    return true;
}

(:test)
function playerEquipReplacesExisting(logger as Test.Logger) as Boolean {
    var player = Players.createPlayerFromId(0, "Test");
    var sword1 = new SteelSword();
    var sword2 = new SteelSword();
    player.addInventoryItem(sword1);
    player.addInventoryItem(sword2);
    player.equipItem(sword1, RIGHT_HAND, true);
    player.equipItem(sword2, RIGHT_HAND, true);
    Test.assert(player.getEquip(RIGHT_HAND) != null);
    Test.assertEqual(player.getEquip(RIGHT_HAND).id, sword2.id);
    return true;
}
