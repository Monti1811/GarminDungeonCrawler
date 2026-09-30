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
function treasureChestSpriteVariants(logger as Test.Logger) as Boolean {
    var chest = new TreasureChest();
    Test.assert(chest.getSprite() == $.Rez.Drawables.chest_closed);
    Test.assert(!chest.isGolden());

    chest._opened = true;
    Test.assert(chest.getSprite() == $.Rez.Drawables.chest_open_full);

    chest._item_taken = true;
    Test.assert(chest.getSprite() == $.Rez.Drawables.chest_open_empty);

    var golden = new TreasureChest();
    golden.setGolden(true);
    Test.assert(golden.isGolden());
    Test.assert(golden.getSprite() == $.Rez.Drawables.chest_golden_closed);

    golden._opened = true;
    Test.assert(golden.getSprite() == $.Rez.Drawables.chest_golden_open_full);

    golden._item_taken = true;
    Test.assert(golden.getSprite() == $.Rez.Drawables.chest_golden_open_empty);
    return true;
}

(:test)
function treasureChestGoldenSurvivesSaveLoad(logger as Test.Logger) as Boolean {
    var chest = new TreasureChest();
    chest.setGolden(true);
    chest._opened = true;

    var loaded = Item.load(chest.save());
    Test.assert(loaded instanceof TreasureChest);
    var restored = loaded as TreasureChest;
    Test.assert(restored.isGolden());
    Test.assert(restored.getSprite() == $.Rez.Drawables.chest_golden_open_full);
    return true;
}

(:test)
function treasureChestSpriteRefTracksState(logger as Test.Logger) as Boolean {
    var chest = new TreasureChest();
    var closed_ref = chest.getSpriteRef();
    Test.assert(chest._cached_sprite_id == $.Rez.Drawables.chest_closed);

    chest._opened = true;
    var open_ref = chest.getSpriteRef();
    Test.assert(chest._cached_sprite_id == $.Rez.Drawables.chest_open_full);
    Test.assert(open_ref != closed_ref);

    chest._item_taken = true;
    var empty_ref = chest.getSpriteRef();
    Test.assert(chest._cached_sprite_id == $.Rez.Drawables.chest_open_empty);
    Test.assert(empty_ref != open_ref);

    var golden = new TreasureChest();
    golden.setGolden(true);
    golden._opened = true;
    golden.getSpriteRef();
    Test.assert(golden._cached_sprite_id == $.Rez.Drawables.chest_golden_open_full);
    return true;
}

(:test)
function treasureChestRandomLootIsFilled(logger as Test.Logger) as Boolean {
    var old_depth = $.Game.depth;
    var old_weights = $.Items.weights;
    var old_total_weight = $.Items.total_weight;
    $.Game.depth = 10;
    $.Items.init(0);

    for (var i = 0; i < 20; i++) {
        var chest = $.Items.createTreasureChestWithRandomLoot();
        Test.assert(chest.hasContents());
        var expected = chest.isGolden() ? $.Rez.Drawables.chest_golden_closed : $.Rez.Drawables.chest_closed;
        Test.assert(chest.getSprite() == expected);
    }

    $.Items.weights = old_weights;
    $.Items.total_weight = old_total_weight;
    $.Game.depth = old_depth;
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
