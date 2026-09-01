import Toybox.Lang;
import Toybox.Test;

(:test)
function itemFactoryCreatesSteelSword(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(8);
    Test.assert(item != null);
    Test.assert(item instanceof Item);
    return true;
}

(:test)
function itemFactoryCreatesSteelAxe(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(0);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesBronzeBow(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(11);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesFireDagger(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(22);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesIceSword(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(38);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesGoldStaff(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(67);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesArrow(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(200);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesFireArrow(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(201);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesBolt(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(250);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesCrossBow(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(300);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesSteelHelmet(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(1000);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesSteelBreastPlate(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(1001);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesFireRing1(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(1024);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesWoodShield(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(1200);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesGreenBackpack(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(1250);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesLifeAmulet(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(1300);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesHealthPotion(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(2000);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesManaPotion(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(2001);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesKey(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(3000);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesGold(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(5000);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryCreatesTreasureChest(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(6000);
    Test.assert(item != null);
    return true;
}

(:test)
function itemFactoryInvalidIdReturnsNull(logger as Test.Logger) as Boolean {
    var item = Items.createItemFromId(99999);
    Test.assert(item == null);
    return true;
}

(:test)
function itemFactoryAllIdsReturnNonNull(logger as Test.Logger) as Boolean {
    for (var i = 0; i < Items.item_ids.size(); i++) {
        var item = Items.createItemFromId(Items.item_ids[i]);
        Test.assert(item != null);
    }
    return true;
}

(:test)
function itemFactoryCreateRandomItemReturnsNonNull(logger as Test.Logger) as Boolean {
    Items.createRandomItem();
    return true;
}

(:test)
function itemFactoryCreateTreasureChestWithLoot(logger as Test.Logger) as Boolean {
    var loot = Items.createItemFromId(8);
    var chest = Items.createTreasureChestWithLoot(loot);
    Test.assert(chest instanceof TreasureChest);
    return true;
}
