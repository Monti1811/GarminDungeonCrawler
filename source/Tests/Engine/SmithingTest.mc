import Toybox.Lang;
import Toybox.Test;

(:test)
function smithingNewItemHasLevelZero(logger as Test.Logger) as Boolean {
    var sword = Items.createItemFromId(8) as EquippableItem;
    Test.assert(sword.upgrade_level == 0);
    Test.assert(sword.canUpgrade());
    Test.assert(sword.getName().equals("Steel Sword"));
    Test.assert(sword.getValue() == 10);
    return true;
}

(:test)
function smithingUpgradeStopsAtMaxLevel(logger as Test.Logger) as Boolean {
    var sword = Items.createItemFromId(8) as EquippableItem;
    sword.upgrade_level = $.Constants.UPGRADE_MAX_LEVEL - 1;
    Test.assert(sword.canUpgrade());
    sword.upgrade_level = $.Constants.UPGRADE_MAX_LEVEL;
    Test.assert(!sword.canUpgrade());
    return true;
}

(:test)
function smithingNameShowsUpgradeSuffix(logger as Test.Logger) as Boolean {
    var sword = Items.createItemFromId(8) as EquippableItem;
    sword.upgrade_level = 3;
    Test.assert(sword.getName().equals("Steel Sword +3"));
    return true;
}

(:test)
function smithingValueScalesWithUpgradeLevel(logger as Test.Logger) as Boolean {
    var sword = Items.createItemFromId(8) as EquippableItem;
    Test.assert(sword.getValue() == 10);
    sword.upgrade_level = 4;
    Test.assert(sword.getValue() == 20);
    return true;
}

(:test)
function smithingBaseAttackScalesWithUpgradeLevel(logger as Test.Logger) as Boolean {
    var sword = Items.createItemFromId(8) as WeaponItem;
    var base0 = sword.getBaseAttack();
    Test.assert(base0 == 9);
    var prev = base0;
    for (var level = 1; level <= $.Constants.UPGRADE_MAX_LEVEL; level++) {
        (sword as EquippableItem).upgrade_level = level;
        var cur = sword.getBaseAttack();
        Test.assert(cur >= prev);
        prev = cur;
    }
    Test.assert(prev > base0);
    return true;
}

(:test)
function smithingBaseDefenseScalesWithUpgradeLevel(logger as Test.Logger) as Boolean {
    var armor = Items.createItemFromId(1011) as ArmorItem;
    Test.assert(armor.getBaseDefense() == 4);
    (armor as EquippableItem).upgrade_level = $.Constants.UPGRADE_MAX_LEVEL;
    Test.assert(armor.getBaseDefense() == 6);
    return true;
}

(:test)
function smithingSaveLoadKeepsUpgradeLevel(logger as Test.Logger) as Boolean {
    var sword = Items.createItemFromId(8) as WeaponItem;
    (sword as EquippableItem).upgrade_level = 3;
    sword.attack = 99;
    var data = sword.save();
    var loaded = Item.load(data);
    Test.assert(loaded != null);
    Test.assert(loaded instanceof SteelSword);
    Test.assert((loaded as EquippableItem).upgrade_level == 3);
    Test.assert((loaded as WeaponItem).attack == 99);
    Test.assert(loaded.getName().equals("Steel Sword +3"));
    return true;
}

(:test)
function smithingDeepcopyKeepsUpgradeLevel(logger as Test.Logger) as Boolean {
    var sword = Items.createItemFromId(8) as WeaponItem;
    sword.upgrade_level = 3;
    sword.attack = 99;
    var sword_copy = sword.deepcopy() as WeaponItem;
    Test.assert(sword_copy.upgrade_level == 3);
    Test.assert(sword_copy.attack == 99);
    var armor = Items.createItemFromId(1011) as EquippableItem;
    armor.upgrade_level = 2;
    var armor_copy = armor.deepcopy() as EquippableItem;
    Test.assert(armor_copy.upgrade_level == 2);
    var bow = Items.createItemFromId(11) as EquippableItem;
    bow.upgrade_level = 5;
    var bow_copy = bow.deepcopy() as EquippableItem;
    Test.assert(bow_copy.upgrade_level == 5);
    return true;
}

(:test)
function smithingInventorySeparatesUpgradeStacks(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(100);
    var sword_a = Items.createItemFromId(8) as EquippableItem;
    var sword_b = Items.createItemFromId(8) as EquippableItem;
    var sword_up = Items.createItemFromId(8) as EquippableItem;
    sword_up.upgrade_level = 3;
    Test.assert(inventory.add(sword_a));
    Test.assert(inventory.add(sword_b));
    Test.assert(inventory.add(sword_up));
    var items = inventory.getItems();
    Test.assert(items.size() == 2);
    var found_plain = false;
    var found_upgraded = false;
    for (var i = 0; i < items.size(); i++) {
        var entry = items[i] as EquippableItem;
        if (entry.upgrade_level == 0) {
            Test.assert(entry.amount == 2);
            found_plain = true;
        } else if (entry.upgrade_level == 3) {
            Test.assert(entry.amount == 1);
            found_upgraded = true;
        }
    }
    Test.assert(found_plain);
    Test.assert(found_upgraded);
    return true;
}

(:test)
function smithingInventoryDropKeepsUpgradeLevel(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(100);
    var sword = Items.createItemFromId(8) as EquippableItem;
    sword.upgrade_level = 3;
    Test.assert(inventory.add(sword));
    var dropped = inventory.remove(sword);
    Test.assert(dropped != null);
    Test.assert((dropped as EquippableItem).upgrade_level == 3);
    Test.assert((dropped as WeaponItem).attack == 13);
    return true;
}

(:test)
function smithingInventorySaveLoadKeepsUpgradeLevel(logger as Test.Logger) as Boolean {
    var inventory = new Inventory(100);
    var sword = Items.createItemFromId(8) as WeaponItem;
    (sword as EquippableItem).upgrade_level = 3;
    sword.attack = 99;
    Test.assert(inventory.add(sword));
    var data = inventory.save();
    var loaded = Inventory.load(data);
    var items = loaded.getItems();
    Test.assert(items.size() == 1);
    Test.assert((items[0] as EquippableItem).upgrade_level == 3);
    Test.assert((items[0] as WeaponItem).attack == 99);
    Test.assert(items[0].getName().equals("Steel Sword +3"));
    return true;
}

(:test)
function blacksmithAffordableFilterChecksGoldAndMaterials(logger as Test.Logger) as Boolean {
    Game.init(0);
    var player = Players.createPlayerFromId(0, "Test");
    Game.setPlayer(player);
    var delegate = new DCBlacksmithDelegate(new Blacksmith());

    var sword = Items.createItemFromId(8) as EquippableItem;
    Test.assert(player.addInventoryItem(sword));
    Test.assert(!delegate.canAffordUpgrade(sword));

    var mat = Items.createItemFromId(4000);
    mat.amount = 6;
    Test.assert(player.addInventoryItem(mat));
    Test.assert(!delegate.canAffordUpgrade(sword));

    player.gold = 100;
    Test.assert(delegate.canAffordUpgrade(sword));

    sword.upgrade_level = 1;
    Test.assert(delegate.canAffordUpgrade(sword));

    sword.upgrade_level = 5;
    Test.assert(!delegate.canAffordUpgrade(sword));

    Game.setPlayer(null);
    return true;
}

(:test)
function smithingCostTablesAreMonotonic(logger as Test.Logger) as Boolean {
    Test.assert($.Constants.UPGRADE_MAX_LEVEL == 5);
    Test.assert($.Constants.SMITH_COST_GOLD.size() == $.Constants.UPGRADE_MAX_LEVEL);
    Test.assert($.Constants.SMITH_COST_MATERIAL.size() == $.Constants.UPGRADE_MAX_LEVEL);
    for (var i = 1; i < $.Constants.SMITH_COST_GOLD.size(); i++) {
        Test.assert($.Constants.SMITH_COST_GOLD[i] > $.Constants.SMITH_COST_GOLD[i - 1]);
        Test.assert($.Constants.SMITH_COST_MATERIAL[i] > $.Constants.SMITH_COST_MATERIAL[i - 1]);
    }
    return true;
}

(:test)
function smithingMaterialNamesResolve(logger as Test.Logger) as Boolean {
    var steel_sword = Items.createItemFromId(8) as Item;
    var blood_sword = Items.createItemFromId(88) as Item;
    Test.assert(DCBlacksmithDelegate.getMaterialName(steel_sword).equals("Steel Ingot"));
    Test.assert(DCBlacksmithDelegate.getMaterialName(blood_sword).equals("Blood Essence"));
    return true;
}
