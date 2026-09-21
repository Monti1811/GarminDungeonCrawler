import Toybox.Lang;
import Toybox.Test;

(:test)
function enemyFactoryCreatesFrog(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(0);
    Test.assert(enemy instanceof Frog);
    return true;
}

(:test)
function enemyFactoryCreatesBat(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(1);
    Test.assert(enemy instanceof Bat);
    return true;
}

(:test)
function enemyFactoryCreatesDemon(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(2);
    Test.assert(enemy instanceof Demon);
    return true;
}

(:test)
function enemyFactoryCreatesOrc(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(3);
    Test.assert(enemy instanceof Orc);
    return true;
}

(:test)
function enemyFactoryCreatesImp(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(4);
    Test.assert(enemy instanceof Imp);
    return true;
}

(:test)
function enemyFactoryCreatesSkeleton(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(5);
    Test.assert(enemy instanceof Skeleton);
    return true;
}

(:test)
function enemyFactoryCreatesNecromancer(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(6);
    Test.assert(enemy instanceof Necromancer);
    return true;
}

(:test)
function enemyFactoryCreatesZombieSmall(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(7);
    Test.assert(enemy instanceof ZombieSmall);
    return true;
}

(:test)
function enemyFactoryCreatesZombie(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(8);
    Test.assert(enemy instanceof Zombie);
    return true;
}

(:test)
function enemyFactoryCreatesWogol(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(9);
    Test.assert(enemy instanceof Wogol);
    return true;
}

(:test)
function enemyFactoryCreatesOgre(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(10);
    Test.assert(enemy instanceof Ogre);
    return true;
}

(:test)
function enemyFactoryCreatesDarkKnight(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(11);
    Test.assert(enemy instanceof DarkKnight);
    return true;
}

(:test)
function enemyFactoryCreatesElementalAirSmall(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(12);
    Test.assert(enemy instanceof ElementalAirSmall);
    return true;
}

(:test)
function enemyFactoryCreatesElementalEarthSmall(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(13);
    Test.assert(enemy instanceof ElementalEarthSmall);
    return true;
}

(:test)
function enemyFactoryCreatesElementalFireSmall(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(14);
    Test.assert(enemy instanceof ElementalFireSmall);
    return true;
}

(:test)
function enemyFactoryCreatesElementalGoldSmall(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(15);
    Test.assert(enemy instanceof ElementalGoldSmall);
    return true;
}

(:test)
function enemyFactoryCreatesElementalGooSmall(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(16);
    Test.assert(enemy instanceof ElementalGooSmall);
    return true;
}

(:test)
function enemyFactoryCreatesElementalWaterSmall(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(17);
    Test.assert(enemy instanceof ElementalWaterSmall);
    return true;
}

(:test)
function enemyFactoryCreatesElementalAir(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(18);
    Test.assert(enemy instanceof ElementalAir);
    return true;
}

(:test)
function enemyFactoryCreatesElementalEarth(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(19);
    Test.assert(enemy instanceof ElementalEarth);
    return true;
}

(:test)
function enemyFactoryCreatesElementalFire(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(20);
    Test.assert(enemy instanceof ElementalFire);
    return true;
}

(:test)
function enemyFactoryCreatesElementalGold(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(21);
    Test.assert(enemy instanceof ElementalGold);
    return true;
}

(:test)
function enemyFactoryCreatesElementalGoo(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(22);
    Test.assert(enemy instanceof ElementalGoo);
    return true;
}

(:test)
function enemyFactoryCreatesElementalPlant(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(23);
    Test.assert(enemy instanceof ElementalPlant);
    return true;
}

(:test)
function enemyFactoryCreatesElementalWater(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(24);
    Test.assert(enemy instanceof ElementalWater);
    return true;
}

(:test)
function enemyFactoryCreatesGoblin(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(25);
    Test.assert(enemy instanceof Goblin);
    return true;
}

(:test)
function enemyFactoryCreatesTentackle(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(26);
    Test.assert(enemy instanceof Tentackle);
    return true;
}

(:test)
function enemyFactoryCreatesDemonolog(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(27);
    Test.assert(enemy instanceof Demonolog);
    return true;
}

(:test)
function enemyFactoryCreatesChort(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(28);
    Test.assert(enemy instanceof Chort);
    return true;
}

(:test)
function enemyFactoryCreatesBies(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(29);
    Test.assert(enemy instanceof Bies);
    return true;
}

(:test)
function enemyFactoryCreatesElementalPlantSmall(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(30);
    Test.assert(enemy instanceof ElementalPlantSmall);
    return true;
}

(:test)
function enemyFactoryCreatesOrcArmored(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(31);
    Test.assert(enemy instanceof OrcArmored);
    return true;
}

(:test)
function enemyFactoryCreatesOrcMasked(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(32);
    Test.assert(enemy instanceof OrcMasked);
    return true;
}

(:test)
function enemyFactoryCreatesOrcShaman(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(33);
    Test.assert(enemy instanceof OrcShaman);
    return true;
}

(:test)
function enemyFactoryCreatesOrcVeteran(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(34);
    Test.assert(enemy instanceof OrcVeteran);
    return true;
}

(:test)
function enemyFactoryCreatesRokita(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(35);
    Test.assert(enemy instanceof Rokita);
    return true;
}

(:test)
function enemyFactoryCreatesShadowStalker(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(36);
    Test.assert(enemy instanceof ShadowStalker);
    return true;
}

(:test)
function enemyFactoryCreatesGloomLurker(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(37);
    Test.assert(enemy instanceof GloomLurker);
    return true;
}

(:test)
function enemyFactoryDefaultIdReturnsFrog(logger as Test.Logger) as Boolean {
    var enemy = Enemies.createEnemyFromId(999);
    Test.assert(enemy instanceof Frog);
    return true;
}

(:test)
function enemyFactoryAllIdsReturnNonNull(logger as Test.Logger) as Boolean {
    for (var i = 0; i < Enemies.enemy_ids.size(); i++) {
        Enemies.createEnemyFromId(Enemies.enemy_ids[i]);
    }
    return true;
}

(:test)
function enemyFactoryCreateRandomEnemyReturnsNonNull(logger as Test.Logger) as Boolean {
    Enemies.createRandomEnemy();
    return true;
}
