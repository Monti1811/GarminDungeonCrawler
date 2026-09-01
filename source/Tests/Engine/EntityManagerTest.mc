import Toybox.Lang;
import Toybox.Test;

(:test)
function entityManagerInitResetsState(logger as Test.Logger) as Boolean {
    EntityManager.init();
    Test.assertEqual(EntityManager.entity_num, 0);
    Test.assertEqual(EntityManager.entities.size(), 0);
    return true;
}

(:test)
function entityManagerAddEntityAssignsGuid(logger as Test.Logger) as Boolean {
    EntityManager.init();
    var enemy = new Enemy();
    EntityManager.addEntity(enemy);
    Test.assertEqual(enemy.guid, 0);
    Test.assertEqual(EntityManager.entity_num, 1);
    return true;
}

(:test)
function entityManagerAddMultipleEntities(logger as Test.Logger) as Boolean {
    EntityManager.init();
    var e1 = new Enemy();
    var e2 = new Enemy();
    EntityManager.addEntity(e1);
    EntityManager.addEntity(e2);
    Test.assertEqual(e1.guid, 0);
    Test.assertEqual(e2.guid, 1);
    Test.assertEqual(EntityManager.entity_num, 2);
    return true;
}

(:test)
function entityManagerGetEntityById(logger as Test.Logger) as Boolean {
    EntityManager.init();
    var enemy = new Enemy();
    EntityManager.addEntity(enemy);
    var found = EntityManager.getEntityById(0);
    Test.assert(found != null);
    Test.assertEqual(found, enemy);
    return true;
}

(:test)
function entityManagerGetEntityByInvalidId(logger as Test.Logger) as Boolean {
    EntityManager.init();
    var found = EntityManager.getEntityById(999);
    Test.assert(found == null);
    return true;
}

(:test)
function entityManagerRemoveEntity(logger as Test.Logger) as Boolean {
    EntityManager.init();
    var enemy = new Enemy();
    EntityManager.addEntity(enemy);
    EntityManager.removeEntity(enemy);
    var found = EntityManager.getEntityById(0);
    Test.assert(found == null);
    return true;
}

(:test)
function entityManagerRemoveNonexistentDoesNotCrash(logger as Test.Logger) as Boolean {
    EntityManager.init();
    var enemy = new Enemy();
    EntityManager.removeEntity(enemy);
    return true;
}

(:test)
function entityManagerSaveAndLoad(logger as Test.Logger) as Boolean {
    EntityManager.init();
    EntityManager.addEntity(new Enemy());
    EntityManager.addEntity(new Enemy());
    var saveData = EntityManager.save();
    Test.assertEqual(saveData["entity_num"], 2);

    EntityManager.init();
    Test.assertEqual(EntityManager.entity_num, 0);
    EntityManager.load(saveData);
    Test.assertEqual(EntityManager.entity_num, 2);
    return true;
}

(:test)
function entityManagerGuidIncrementsAcrossInits(logger as Test.Logger) as Boolean {
    EntityManager.init();
    var e1 = new Enemy();
    EntityManager.addEntity(e1);
    Test.assertEqual(e1.guid, 0);

    EntityManager.init();
    var e2 = new Enemy();
    EntityManager.addEntity(e2);
    Test.assertEqual(e2.guid, 0);
    return true;
}
