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

(:test)
function itemFactoryCreatesAllMaterials(logger as Test.Logger) as Boolean {
    for (var id = 4000; id <= 4008; id++) {
        var item = Items.createItemFromId(id);
        Test.assert(item != null);
        Test.assert((item as Item).type == MATERIAL);
    }
    return true;
}

(:test)
function materialUtilMapsWeaponAndArmorTiers(logger as Test.Logger) as Boolean {
    var steel_sword = Items.createItemFromId(8) as Item;
    var bronze_sword = Items.createItemFromId(18) as Item;
    var blood_sword = Items.createItemFromId(88) as Item;
    var crossbow = Items.createItemFromId(300) as Item;
    var hell_crossbow = Items.createItemFromId(302) as Item;
    var steel_helmet = Items.createItemFromId(1000) as Item;
    var blood_helmet = Items.createItemFromId(1080) as Item;
    var silver_shield = Items.createItemFromId(1202) as Item;
    var arrow = Items.createItemFromId(200) as Item;
    var life_amulet = Items.createItemFromId(1300) as Item;
    Test.assert(MaterialUtil.getMaterialForItem(steel_sword) == 4000);
    Test.assert(MaterialUtil.getMaterialForItem(bronze_sword) == 4001);
    Test.assert(MaterialUtil.getMaterialForItem(blood_sword) == 4008);
    Test.assert(MaterialUtil.getMaterialForItem(crossbow) == 4000);
    Test.assert(MaterialUtil.getMaterialForItem(hell_crossbow) == 4007);
    Test.assert(MaterialUtil.getMaterialForItem(steel_helmet) == 4000);
    Test.assert(MaterialUtil.getMaterialForItem(blood_helmet) == 4008);
    Test.assert(MaterialUtil.getMaterialForItem(silver_shield) == 4006);
    Test.assert(MaterialUtil.getMaterialForItem(arrow) == -1);
    Test.assert(MaterialUtil.getMaterialForItem(life_amulet) == -1);
    return true;
}
