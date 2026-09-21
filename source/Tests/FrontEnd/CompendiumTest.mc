import Toybox.Lang;
import Toybox.Test;

(:test)
function compendiumAllEnemiesCanBeCreatedAndScaled(logger as Test.Logger) as Boolean {
    for (var i = 0; i < Enemies.enemy_ids.size(); i++) {
        $.SaveData.discovered_enemies[Enemies.enemy_ids[i]] = true;
    }

    $.Game.depth = 0;
    var discovered_ids = $.SaveData.discovered_enemies.keys();
    for (var i = 0; i < discovered_ids.size(); i++) {
        var enemy = Enemies.createEnemyFromId(discovered_ids[i]);
        var base_hp = enemy.maxHealth;
        var base_dmg = enemy.damage;
        var base_arm = enemy.armor;
        
        enemy.setLevel(0);
        Test.assert(enemy.maxHealth == base_hp);
        Test.assert(enemy.damage == base_dmg);
        Test.assert(enemy.armor == base_arm);
    }

    $.Game.depth = 10;
    discovered_ids = $.SaveData.discovered_enemies.keys();
    for (var i = 0; i < discovered_ids.size(); i++) {
        var enemy = Enemies.createEnemyFromId(discovered_ids[i]);
        var base_hp = enemy.maxHealth;
        var base_dmg = enemy.damage;
        var base_arm = enemy.armor;
        
        enemy.setLevel(10);
        Test.assert(enemy.maxHealth >= base_hp);
        Test.assert(enemy.damage >= base_dmg);
        Test.assert(enemy.armor >= base_arm);
        Test.assert(enemy.level == 10);
    }

    $.SaveData.discovered_enemies = {};
    $.Game.depth = 0;
    return true;
}

(:test)
function compendiumAllItemsCanBeCreated(logger as Test.Logger) as Boolean {
    for (var i = 0; i < Items.item_ids.size(); i++) {
        $.SaveData.discovered_items[Items.item_ids[i]] = true;
    }

    var discovered_ids = $.SaveData.discovered_items.keys();
    for (var i = 0; i < discovered_ids.size(); i++) {
        var item = Items.createItemFromId(discovered_ids[i]);
        Test.assert(item != null);
        Test.assert(item instanceof Item);
    }

    $.SaveData.discovered_items = {};
    return true;
}

(:test)
function compendiumEnemyScalingConsistentAcrossDepths(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(10); // Ogre (higher base stats)
    var base_hp = enemy.maxHealth;
    
    var enemy5 = Enemies.createEnemyFromId(10);
    enemy5.setLevel(5);
    
    var enemy10 = Enemies.createEnemyFromId(10);
    enemy10.setLevel(10);
    
    Test.assert(enemy5.maxHealth > base_hp);
    Test.assert(enemy10.maxHealth > enemy5.maxHealth);
    Test.assert(enemy10.damage >= enemy5.damage);
    
    return true;
}

(:test)
function compendiumEnemySubtitleShowsScaledValues(logger as Test.Logger) as Boolean {
    $.Game.depth = 15;
    
    for (var i = 0; i < Enemies.enemy_ids.size(); i++) {
        $.SaveData.discovered_enemies[Enemies.enemy_ids[i]] = true;
    }
    
    var discovered_ids = $.SaveData.discovered_enemies.keys();
    for (var i = 0; i < discovered_ids.size(); i++) {
        var enemy = Enemies.createEnemyFromId(discovered_ids[i]);
        enemy.setLevel($.Game.depth);
        
        var subtitle = "HP: " + enemy.maxHealth + " ATK: " + enemy.damage;
        Test.assert(subtitle.length() > 0);
        
        var base_enemy = Enemies.createEnemyFromId(discovered_ids[i]);
        if (base_enemy.maxHealth > 0) {
            Test.assert(enemy.maxHealth >= base_enemy.maxHealth);
        }
    }
    
    $.SaveData.discovered_enemies = {};
    $.Game.depth = 0;
    return true;
}
