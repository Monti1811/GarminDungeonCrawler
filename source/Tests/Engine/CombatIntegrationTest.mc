import Toybox.Test;
import Toybox.Lang;

// ============================================================
// Combat Integration Tests
// Tests full combat scenarios: attack, damage, death, cooldowns
// ============================================================

(:test)
module CombatTestHelpers {

    function createTestEnemy(dmg as Number, arm as Number, hp as Number, cooldown as Number) as Enemy {
        var e = new Enemy();
        e.damage = dmg;
        e.armor = arm;
        e.current_health = hp;
        e.maxHealth = hp;
        e.attack_cooldown = cooldown;
        e.curr_attack_cooldown = 0;
        e.name = "TestEnemy";
        return e;
    }

    function createTestPlayer(hp as Number, con as Number, str as Number) as Player {
        var p = new Player();
        p.current_health = hp;
        p.maxHealth = hp;
        p.setAttribute(:constitution, con);
        p.setAttribute(:strength, str);
        p.setAttribute(:dexterity, 0);
        p.setAttribute(:intelligence, 0);
        p.setAttribute(:wisdom, 0);
        p.setAttribute(:charisma, 0);
        p.setAttribute(:luck, 0);
        p.name = "TestPlayer";
        return p;
    }

    function createTestWeapon(atk as Number, cd as Number) as WeaponItem {
        var w = new WeaponItem();
        w.attack = atk;
        w.cooldown = cd;
        w.current_cooldown = 0;
        w.element = ELEMENT_NONE;
        w.name = "TestSword";
        return w;
    }

    function createTestArmor(def as Number) as ArmorItem {
        var a = new ArmorItem();
        a.defense = def;
        a.element = ELEMENT_NONE;
        a.name = "TestArmor";
        return a;
    }
}

// ============================================================
// 1. Enemy takes damage and dies
// ============================================================

(:test)
function enemyDiesWhenHealthReachesZero(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 30, 2);

    var dead = enemy.takeDamage(30, null);

    Test.assertMessage(dead, "Enemy should be dead after 30 damage on 30 HP");
    Test.assertEqual(enemy.current_health, 0);
    return true;
}

(:test)
function enemySurvivesLethalDamageBelowZero(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 30, 2);

    var dead = enemy.takeDamage(50, null);

    Test.assertMessage(dead, "Enemy should be dead when overkilled");
    Test.assertEqual(enemy.current_health, 0);
    return true;
}

(:test)
function enemySurvivesPartialDamage(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 5, 100, 2);

    var dead = enemy.takeDamage(10, null);

    Test.assertMessage(!dead, "Enemy should survive 10 damage with 100 HP");
    Test.assertMessage(enemy.current_health < 100, "Enemy health should decrease");
    return true;
}

// ============================================================
// 2. Full combat round: player attacks enemy, enemy attacks player
// ============================================================

(:test)
function playerAttackReducesEnemyHealth(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    var enemy = CombatTestHelpers.createTestEnemy(5, 0, 100, 2);

    var damage = MathUtil.ceil(player.getAttack(enemy) - enemy.getDefense(player), 1);
    var dead = enemy.takeDamage(damage, player);

    Test.assertMessage(!dead, "Enemy should survive first hit");
    Test.assertMessage(enemy.current_health < 100, "Enemy health should decrease");
    return true;
}

(:test)
function enemyAttackReducesPlayerHealth(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    var enemy = CombatTestHelpers.createTestEnemy(15, 0, 100, 2);

    var damage = MathUtil.ceil(enemy.getAttack(player) - player.getDefense(enemy), 1);
    var dead = player.takeDamage(damage, enemy);

    Test.assertMessage(!dead, "Player should survive 15 damage with 100 HP");
    Test.assertMessage(player.current_health < 100, "Player health should decrease");
    return true;
}

(:test)
function armorReducesDamage(logger as Test.Logger) as Boolean {
    var player1 = CombatTestHelpers.createTestPlayer(100, 0, 0);
    var player2 = CombatTestHelpers.createTestPlayer(100, 10, 0);
    var enemy = CombatTestHelpers.createTestEnemy(20, 0, 100, 2);

    var dmgNoArmor = MathUtil.ceil(enemy.getAttack(player1) - player1.getDefense(enemy), 1);
    var dmgWithArmor = MathUtil.ceil(enemy.getAttack(player2) - player2.getDefense(enemy), 1);

    Test.assertMessage(dmgWithArmor < dmgNoArmor, "Armor should reduce incoming damage");
    return true;
}

// ============================================================
// 3. Attack cooldown system
// ============================================================

(:test)
function enemyCannotAttackDuringCooldown(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 3);
    var map = new Map(5, 5, true);

    enemy.curr_attack_cooldown = 2;
    var canAttack = !enemy.canAttackPlayer(map, [0, 1]);

    Test.assertMessage(canAttack, "Enemy should not attack during cooldown");
    return true;
}

(:test)
function enemyCooldownDecrementsOnTurnDone(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 3);
    enemy.curr_attack_cooldown = 2;

    enemy.onTurnDone();

    Test.assertEqual(enemy.curr_attack_cooldown, 1);
    return true;
}

(:test)
function enemyCooldownReachesZero(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.curr_attack_cooldown = 1;

    enemy.onTurnDone();

    Test.assertEqual(enemy.curr_attack_cooldown, 0);
    return true;
}

(:test)
function enemyCanAttackAfterCooldownExpires(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    var map = new Map(5, 5, true);
    enemy.curr_attack_cooldown = 1;
    enemy.pos = [2, 2];

    enemy.onTurnDone();

    var canAttack = enemy.canAttackPlayer(map, [2, 3]);
    Test.assertMessage(canAttack, "Enemy should be able to attack after cooldown expires");
    return true;
}

(:test)
function weaponCooldownPreventsSecondAttack(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    var weapon = CombatTestHelpers.createTestWeapon(20, 2);
    player.equipItem(weapon, RIGHT_HAND, false);
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    var firstAttack = player.canAttack(enemy);
    Test.assertMessage(firstAttack, "Player should attack first time");

    weapon.onDamageDone(20, enemy);

    var secondAttack = player.canAttack(enemy);
    Test.assertMessage(!secondAttack, "Player should not attack during weapon cooldown");
    return true;
}

(:test)
function weaponCooldownDecrementsOnTurnDone(logger as Test.Logger) as Boolean {
    var weapon = CombatTestHelpers.createTestWeapon(20, 2);
    weapon.current_cooldown = 2;

    weapon.onTurnDone();

    Test.assertEqual(weapon.current_cooldown, 1);
    return true;
}

(:test)
function weaponCooldownReachesZeroAfterTurns(logger as Test.Logger) as Boolean {
    var weapon = CombatTestHelpers.createTestWeapon(20, 3);
    weapon.current_cooldown = 3;

    weapon.onTurnDone();
    weapon.onTurnDone();
    weapon.onTurnDone();

    Test.assertEqual(weapon.current_cooldown, 0);
    return true;
}

// ============================================================
// 4. Multi-round combat simulation
// ============================================================

(:test)
function multiRoundCombatPlayerWins(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 5, 10);
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 30, 2);

    var rounds = 0;
    var playerDead = false;
    var enemyDead = false;

    while (!playerDead && !enemyDead && rounds < 50) {
        var atk = player.getAttack(enemy);
        var dmg = MathUtil.ceil(atk - enemy.getDefense(player), 1);
        enemyDead = enemy.takeDamage(dmg, null);

        if (!enemyDead) {
            var eDmg = MathUtil.ceil(enemy.getAttack(player) - player.getDefense(enemy), 1);
            playerDead = player.takeDamage(eDmg, null);
        }

        enemy.onTurnDone();
        rounds++;
    }

    Test.assertMessage(enemyDead || playerDead, "Combat should end within 50 rounds");
    return true;
}

(:test)
function multiRoundCombatEnemyWins(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(20, 0, 0);
    var enemy = CombatTestHelpers.createTestEnemy(25, 5, 200, 1);

    var rounds = 0;
    var playerDead = false;

    while (!playerDead && rounds < 50) {
        var atk = player.getAttack(enemy);
        var dmg = MathUtil.ceil(atk - enemy.getDefense(player), 1);
        enemy.takeDamage(dmg, null);

        var eDmg = MathUtil.ceil(enemy.getAttack(player) - player.getDefense(enemy), 1);
        playerDead = player.takeDamage(eDmg, null);

        enemy.onTurnDone();
        rounds++;
    }

    Test.assertMessage(playerDead, "Player should die against strong enemy");
    return true;
}

// ============================================================
// 5. Energy system integration
// ============================================================

(:test)
function energyRestoredAfterTurnDone(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    player.energy = 0;
    player.energy_per_turn = 100;

    player.onTurnDone();

    Test.assertEqual(player.energy, 100);
    return true;
}

(:test)
function energyDoesNotExceedMax(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    player.energy = 80;
    player.energy_per_turn = 100;

    player.onTurnDone();

    Test.assertEqual(player.energy, 100);
    return true;
}

(:test)
function enemyEnergyRestoredAfterTurnDone(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.energy = 0;
    enemy.energy_per_turn = 100;

    enemy.onTurnDone();

    Test.assertEqual(enemy.energy, 100);
    return true;
}

(:test)
function turnCostsEnergy(logger as Test.Logger) as Boolean {
    var entity = new Entity();
    entity.energy = 100;

    entity.doTurnEnergyDelta(-100, 0, 100);

    Test.assertEqual(entity.energy, 0);
    return true;
}

(:test)
function energyClampedBetweenMinAndMax(logger as Test.Logger) as Boolean {
    var entity = new Entity();
    entity.energy = 50;

    entity.doTurnEnergyDelta(-100, 0, 100);

    Test.assertEqual(entity.energy, 0);

    entity.doTurnEnergyDelta(200, 0, 100);

    Test.assertEqual(entity.energy, 100);
    return true;
}

// ============================================================
// 6. Elemental effects - apply, tick, expiry
// ============================================================

(:test)
function fireEffectAppliedCorrectly(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    enemy.applyElementalEffect(ELEMENT_FIRE, 10, 3);

    var effect = enemy.getElementalEffect(ELEMENT_FIRE);
    Test.assertMessage(effect != null, "Fire effect should exist");
    if (effect != null) {
        Test.assertEqual(effect[:type], ELEMENT_FIRE);
        Test.assertEqual(effect[:power], 10);
        Test.assertEqual(effect[:turns], 3);
    }
    return true;
}

(:test)
function iceEffectAppliedCorrectly(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    enemy.applyElementalEffect(ELEMENT_ICE, 20, 2);

    var effect = enemy.getElementalEffect(ELEMENT_ICE);
    Test.assertMessage(effect != null, "Ice effect should exist");
    if (effect != null) {
        Test.assertEqual(effect[:type], ELEMENT_ICE);
        Test.assertEqual(effect[:power], 20);
        Test.assertEqual(effect[:turns], 2);
    }
    return true;
}

(:test)
function elementNoneDoesNotApply(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    enemy.applyElementalEffect(ELEMENT_NONE, 10, 3);

    Test.assertMessage(enemy.getElementalEffect(ELEMENT_NONE) == null, "ELEMENT_NONE should not apply");
    return true;
}

(:test)
function elementWithZeroPowerDoesNotApply(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    enemy.applyElementalEffect(ELEMENT_FIRE, 0, 3);

    Test.assertMessage(enemy.getElementalEffect(ELEMENT_FIRE) == null, "Zero power element should not apply");
    return true;
}

(:test)
function elementWithZeroDurationDoesNotApply(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    enemy.applyElementalEffect(ELEMENT_FIRE, 10, 0);

    Test.assertMessage(enemy.getElementalEffect(ELEMENT_FIRE) == null, "Zero duration element should not apply");
    return true;
}

(:test)
function multipleElementalEffectsStack(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    enemy.applyElementalEffect(ELEMENT_FIRE, 10, 3);
    enemy.applyElementalEffect(ELEMENT_ICE, 15, 2);

    Test.assertMessage(enemy.getElementalEffect(ELEMENT_FIRE) != null, "Fire effect should exist");
    Test.assertMessage(enemy.getElementalEffect(ELEMENT_ICE) != null, "Ice effect should exist");
    return true;
}

(:test)
function fireElementTickDealsPeriodicDamage(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    var hpBefore = enemy.current_health;

    enemy.applyElementalEffect(ELEMENT_FIRE, 10, 3);
    enemy.applyElementalTurnEffects();

    Test.assertMessage(enemy.current_health < hpBefore, "Fire should deal damage on turn");
    return true;
}

(:test)
function iceElementTickReducesEnergy(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.energy = 100;

    enemy.applyElementalEffect(ELEMENT_ICE, 20, 2);
    enemy.applyElementalTurnEffects();

    Test.assertMessage(enemy.energy < 100, "Ice should reduce energy on turn");
    return true;
}

(:test)
function elementalEffectExpiresAfterDuration(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    enemy.applyElementalEffect(ELEMENT_FIRE, 10, 2);
    Test.assertMessage(enemy.getElementalEffect(ELEMENT_FIRE) != null, "Fire effect should exist");

    enemy.applyElementalTurnEffects();
    Test.assertMessage(enemy.getElementalEffect(ELEMENT_FIRE) != null, "Fire effect should still exist (1 turn left)");

    enemy.applyElementalTurnEffects();
    Test.assertMessage(enemy.getElementalEffect(ELEMENT_FIRE) == null, "Fire effect should be gone");
    return true;
}

// ============================================================
// 7. Level scaling integration
// ============================================================

(:test)
function enemyLevelScalesStats(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 10, 100, 2);

    enemy.setLevel(3);

    Test.assertEqual(enemy.maxHealth, 300);
    Test.assertEqual(enemy.damage, 15);
    Test.assertEqual(enemy.armor, 15);
    return true;
}

(:test)
function enemyLevelScalingIncreasesKillExperience(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 10, 100, 2);
    enemy.kill_experience = 20;

    enemy.setLevel(5);

    Test.assertEqual(enemy.kill_experience, 100);
    return true;
}

// ============================================================
// 8. Teleport cooldown integration
// ============================================================

(:test)
function teleportCooldownPreventsUsage(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.teleport_move_cooldown = 2;

    var canUse = enemy.canUseTeleportMove();

    Test.assertMessage(!canUse, "Should not use teleport during cooldown");
    return true;
}

(:test)
function teleportCooldownDecrementsOnTurnDone(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.teleport_move_cooldown = 3;

    enemy.onTurnDone();

    Test.assertEqual(enemy.teleport_move_cooldown, 2);
    return true;
}

(:test)
function teleportCooldownAllowsUsageAfterExpiry(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.teleport_move_cooldown = 1;

    enemy.onTurnDone();

    Test.assertMessage(enemy.canUseTeleportMove(), "Should use teleport after cooldown");
    return true;
}

(:test)
function consumeTeleportMoveSetsCooldown(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.teleport_move_cooldown_max = 4;

    enemy.consumeTeleportMoveCooldown();

    Test.assertEqual(enemy.teleport_move_cooldown, 4);
    return true;
}

// ============================================================
// 9. Health percent calculation
// ============================================================

(:test)
function healthPercentAtFull(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);

    var pct = enemy.getHealthPercent();

    Test.assertMessage(pct > 0.99 && pct < 1.01, "Health percent at full should be ~1.0");
    return true;
}

(:test)
function healthPercentAtHalf(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.current_health = 50;

    var pct = enemy.getHealthPercent();

    Test.assertMessage(pct > 0.49 && pct < 0.51, "Health percent at half should be ~0.5");
    return true;
}

// ============================================================
// 10. Player experience and leveling
// ============================================================

(:test)
function playerGainsExperience(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    player.experience = 0;
    player.next_level_experience = 100;

    player.onGainExperience(50);

    Test.assertEqual(player.experience, 50);
    Test.assertEqual(player.level, 1);
    return true;
}

(:test)
function playerLevelsUpWhenExperienceReachesThreshold(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    player.experience = 0;
    player.next_level_experience = 100;
    player.level = 1;

    player.onGainExperience(100);

    Test.assertEqual(player.level, 2);
    Test.assertEqual(player.attribute_points, 8);
    return true;
}

(:test)
function playerLevelsUpMultipleTimes(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    player.experience = 0;
    player.next_level_experience = 50;
    player.level = 1;
    player.attribute_points = 5;

    player.onGainExperience(500);

    Test.assertMessage(player.level > 2, "Player should level up multiple times with 500 exp");
    return true;
}

// ============================================================
// 11. Player death
// ============================================================

(:test)
function playerDiesWhenHealthReachesZero(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(30, 0, 0);

    var dead = player.takeDamage(30, null);

    Test.assertMessage(dead, "Player should die at 0 HP");
    Test.assertEqual(player.current_health, 0);
    return true;
}

(:test)
function damageReceivedAccumulates(logger as Test.Logger) as Boolean {
    var player = CombatTestHelpers.createTestPlayer(100, 0, 0);
    player.damage_received = 0;

    player.takeDamage(10, null);
    player.takeDamage(20, null);

    Test.assertEqual(player.damage_received, 30);
    return true;
}

// ============================================================
// 12. Enemy attackAdjacentPlayer integration
// ============================================================

(:test)
function enemyCannotAttackNonAdjacentPlayer(logger as Test.Logger) as Boolean {
    var enemy = CombatTestHelpers.createTestEnemy(10, 0, 100, 2);
    enemy.pos = [2, 2];
    var map = new Map(5, 5, true);

    var attacked = enemy.attackNearbyPlayer(map, [0, 0]);

    Test.assertMessage(!attacked, "Enemy should not attack non-adjacent player");
    return true;
}
