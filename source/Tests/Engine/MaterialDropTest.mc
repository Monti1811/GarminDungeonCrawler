import Toybox.Lang;
import Toybox.Test;

(:test)
function materialDropDepth5OnlySteel(logger as Test.Logger) as Boolean {
    for (var i = 0; i < 300; i++) {
        Test.assert(MaterialUtil.pickMaterialForDepth(5) == 4000);
    }
    return true;
}

(:test)
function materialDropDepth25TierWeights(logger as Test.Logger) as Boolean {
    var steel = 0;
    var bronze = 0;
    var fire = 0;
    for (var i = 0; i < 2000; i++) {
        var mat = MaterialUtil.pickMaterialForDepth(25);
        Test.assert(mat >= 4000 && mat <= 4002);
        if (mat == 4000) {
            steel += 1;
        } else if (mat == 4001) {
            bronze += 1;
        } else {
            fire += 1;
        }
    }
    Test.assert(steel > 0);
    Test.assert(bronze > steel);
    Test.assert(fire > bronze);
    return true;
}

(:test)
function materialDropBelowDepth70HasNoSpecials(logger as Test.Logger) as Boolean {
    for (var i = 0; i < 1000; i++) {
        Test.assert(MaterialUtil.pickMaterialForDepth(69) <= 4006);
    }
    for (var i = 0; i < 1000; i++) {
        Test.assert(MaterialUtil.pickMaterialForDepth(15) <= 4001);
    }
    return true;
}

(:test)
function materialDropDepth70DemonChance(logger as Test.Logger) as Boolean {
    var samples = 3000;
    var demon = 0;
    for (var i = 0; i < samples; i++) {
        var mat = MaterialUtil.pickMaterialForDepth(70);
        Test.assert(mat >= 4000 && mat <= 4008);
        Test.assert(mat != 4008);
        if (mat == 4007) {
            demon += 1;
        }
    }
    var percent = demon * 100 / samples;
    Test.assert(percent >= 24 && percent <= 36);
    return true;
}

(:test)
function materialDropDepth85DemonAndBloodChances(logger as Test.Logger) as Boolean {
    var samples = 3000;
    var demon = 0;
    var blood = 0;
    for (var i = 0; i < samples; i++) {
        var mat = MaterialUtil.pickMaterialForDepth(85);
        if (mat == 4007) {
            demon += 1;
        } else if (mat == 4008) {
            blood += 1;
        }
    }
    var demon_percent = demon * 100 / samples;
    var blood_percent = blood * 100 / samples;
    Test.assert(demon_percent >= 28 && demon_percent <= 42);
    Test.assert(blood_percent >= 22 && blood_percent <= 38);
    return true;
}

(:test)
function materialDropDepth95MaxChances(logger as Test.Logger) as Boolean {
    var samples = 3000;
    var demon = 0;
    var blood = 0;
    for (var i = 0; i < samples; i++) {
        var mat = MaterialUtil.pickMaterialForDepth(95);
        if (mat == 4007) {
            demon += 1;
        } else if (mat == 4008) {
            blood += 1;
        }
    }
    var demon_percent = demon * 100 / samples;
    var blood_percent = blood * 100 / samples;
    Test.assert(demon_percent >= 33 && demon_percent <= 47);
    Test.assert(blood_percent >= 33 && blood_percent <= 47);
    Test.assert(demon_percent + blood_percent >= 70);
    return true;
}

(:test)
function enemyLootIncludesMaterialWithDropChance(logger as Test.Logger) as Boolean {
    Game.init(0);
    Game.depth = 5;
    var player = Players.createPlayerFromId(0, "Test");
    Game.setPlayer(player);
    var enemy = Enemies.createEnemyFromId(0);
    var samples = 500;
    var materials = 0;
    var golds = 0;
    for (var i = 0; i < samples; i++) {
        var drops = enemy.getLoot();
        for (var j = 0; j < drops.size(); j++) {
            var drop = drops[j];
            if (drop instanceof MaterialItem) {
                materials += 1;
                Test.assert(drop.id == 4000);
            } else {
                Test.assert(drop instanceof Gold || drop instanceof Arrow || drop instanceof Bolt);
                if (drop instanceof Gold) {
                    golds += 1;
                }
            }
        }
    }
    var percent = materials * 100 / samples;
    Test.assert(percent >= 22 && percent <= 38);
    Test.assert(golds > 0);
    Game.setPlayer(null);
    return true;
}
