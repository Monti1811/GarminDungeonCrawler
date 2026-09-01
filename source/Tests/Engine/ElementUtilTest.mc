import Toybox.Test;
import Toybox.Lang;

// --- getWeaponElement ---

(:test)
function getWeaponElementFireRange(logger as Test.Logger) as Boolean {
    for (var id = 20; id <= 28; id++) {
        Test.assertEqual(ElementUtil.getWeaponElement(id), ELEMENT_FIRE);
    }
    return true;
}

(:test)
function getWeaponElementIceRange(logger as Test.Logger) as Boolean {
    for (var id = 30; id <= 38; id++) {
        Test.assertEqual(ElementUtil.getWeaponElement(id), ELEMENT_ICE);
    }
    return true;
}

(:test)
function getWeaponElementNoneForOther(logger as Test.Logger) as Boolean {
    Test.assertEqual(ElementUtil.getWeaponElement(0), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getWeaponElement(10), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getWeaponElement(29), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getWeaponElement(39), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getWeaponElement(100), ELEMENT_NONE);
    return true;
}

// --- getAmmunitionElement ---

(:test)
function getAmmunitionElementFire(logger as Test.Logger) as Boolean {
    Test.assertEqual(ElementUtil.getAmmunitionElement(201), ELEMENT_FIRE);
    Test.assertEqual(ElementUtil.getAmmunitionElement(251), ELEMENT_FIRE);
    return true;
}

(:test)
function getAmmunitionElementIce(logger as Test.Logger) as Boolean {
    Test.assertEqual(ElementUtil.getAmmunitionElement(202), ELEMENT_ICE);
    Test.assertEqual(ElementUtil.getAmmunitionElement(252), ELEMENT_ICE);
    return true;
}

(:test)
function getAmmunitionElementNone(logger as Test.Logger) as Boolean {
    Test.assertEqual(ElementUtil.getAmmunitionElement(0), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getAmmunitionElement(200), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getAmmunitionElement(203), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getAmmunitionElement(300), ELEMENT_NONE);
    return true;
}

// --- getArmorElement ---

(:test)
function getArmorElementFireRange(logger as Test.Logger) as Boolean {
    for (var id = 1020; id <= 1025; id++) {
        Test.assertEqual(ElementUtil.getArmorElement(id), ELEMENT_FIRE);
    }
    return true;
}

(:test)
function getArmorElementIceRange(logger as Test.Logger) as Boolean {
    for (var id = 1030; id <= 1035; id++) {
        Test.assertEqual(ElementUtil.getArmorElement(id), ELEMENT_ICE);
    }
    return true;
}

(:test)
function getArmorElementNoneForOther(logger as Test.Logger) as Boolean {
    Test.assertEqual(ElementUtil.getArmorElement(0), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getArmorElement(1000), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getArmorElement(1026), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getArmorElement(1029), ELEMENT_NONE);
    Test.assertEqual(ElementUtil.getArmorElement(1036), ELEMENT_NONE);
    return true;
}

// --- getArmorResistance ---

(:test)
function getArmorResistanceReturnsResistanceForMatching(logger as Test.Logger) as Boolean {
    // Fire armor (1020) vs FIRE element
    Test.assertEqual(ElementUtil.getArmorResistance(1020, ELEMENT_FIRE), 0.25);
    // Ice armor (1030) vs ICE element
    Test.assertEqual(ElementUtil.getArmorResistance(1030, ELEMENT_ICE), 0.25);
    return true;
}

(:test)
function getArmorResistanceReturnsZeroForNonMatching(logger as Test.Logger) as Boolean {
    Test.assertEqual(ElementUtil.getArmorResistance(1020, ELEMENT_ICE), 0.0);
    Test.assertEqual(ElementUtil.getArmorResistance(1030, ELEMENT_FIRE), 0.0);
    Test.assertEqual(ElementUtil.getArmorResistance(1020, ELEMENT_NONE), 0.0);
    Test.assertEqual(ElementUtil.getArmorResistance(0, ELEMENT_FIRE), 0.0);
    return true;
}

// --- buildElementalEffect ---

(:test)
function buildElementalEffectFireHasPowerAndTurns(logger as Test.Logger) as Boolean {
    var effect = ElementUtil.buildElementalEffect(ELEMENT_FIRE, 10);
    Test.assertMessage(effect.hasKey(:power), "fire effect should have :power");
    Test.assertMessage(effect.hasKey(:turns), "fire effect should have :turns");
    Test.assertEqual(effect[:turns], 3);
    Test.assertMessage(effect[:power] as Number >= 1, "fire power >= 1");
    return true;
}

(:test)
function buildElementalEffectFirePowerScalesWithDamage(logger as Test.Logger) as Boolean {
    var small = ElementUtil.buildElementalEffect(ELEMENT_FIRE, 5);
    var large = ElementUtil.buildElementalEffect(ELEMENT_FIRE, 50);
    Test.assertMessage((small[:power] as Number) <= (large[:power] as Number), "fire power scales with damage");
    return true;
}

(:test)
function buildElementalEffectIceHasPowerAndTurns(logger as Test.Logger) as Boolean {
    var effect = ElementUtil.buildElementalEffect(ELEMENT_ICE, 10);
    Test.assertMessage(effect.hasKey(:power), "ice effect should have :power");
    Test.assertMessage(effect.hasKey(:turns), "ice effect should have :turns");
    Test.assertEqual(effect[:turns], 2);
    Test.assertMessage(effect[:power] as Number >= 10, "ice power >= 10");
    return true;
}

(:test)
function buildElementalEffectNoneIsEmpty(logger as Test.Logger) as Boolean {
    var effect = ElementUtil.buildElementalEffect(ELEMENT_NONE, 10);
    Test.assertEqual(effect.size(), 0);
    return true;
}
