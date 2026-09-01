import Toybox.Lang;
import Toybox.Test;

(:test)
function saveCompareDescending(logger as Test.Logger) as Boolean {
    var cmp = new SaveCompare();
    Test.assertEqual(cmp.compare("10", "5"), -1);
    Test.assertEqual(cmp.compare("5", "10"), 1);
    Test.assertEqual(cmp.compare("5", "5"), 0);
    return true;
}

(:test)
function saveCompareLargeNumbers(logger as Test.Logger) as Boolean {
    var cmp = new SaveCompare();
    Test.assertEqual(cmp.compare("100", "50"), -1);
    Test.assertEqual(cmp.compare("50", "100"), 1);
    return true;
}

(:test)
function saveCompareSameValues(logger as Test.Logger) as Boolean {
    var cmp = new SaveCompare();
    Test.assertEqual(cmp.compare("42", "42"), 0);
    return true;
}

(:test)
function valueCompareDescending(logger as Test.Logger) as Boolean {
    var cmp = new ValueCompare(false);
    var item1 = new SteelSword();
    item1.value = 100;
    var item2 = new SteelSword();
    item2.value = 50;
    Test.assertEqual(cmp.compare(item1, item2), -1);
    Test.assertEqual(cmp.compare(item2, item1), 1);
    return true;
}

(:test)
function valueCompareAscending(logger as Test.Logger) as Boolean {
    var cmp = new ValueCompare(true);
    var item1 = new SteelSword();
    item1.value = 100;
    var item2 = new SteelSword();
    item2.value = 50;
    Test.assertEqual(cmp.compare(item1, item2), 1);
    Test.assertEqual(cmp.compare(item2, item1), -1);
    return true;
}

(:test)
function valueCompareEqual(logger as Test.Logger) as Boolean {
    var cmp = new ValueCompare(false);
    var item1 = new SteelSword();
    item1.value = 50;
    var item2 = new SteelSword();
    item2.value = 50;
    Test.assertEqual(cmp.compare(item1, item2), 0);
    return true;
}

(:test)
function nameCompareAscending(logger as Test.Logger) as Boolean {
    var cmp = new NameCompare(true);
    var item1 = new SteelSword();
    item1.name = "Apple";
    var item2 = new SteelSword();
    item2.name = "Banana";
    var result = cmp.compare(item1, item2);
    Test.assert(result < 0);
    return true;
}

(:test)
function nameCompareDescending(logger as Test.Logger) as Boolean {
    var cmp = new NameCompare(false);
    var item1 = new SteelSword();
    item1.name = "Apple";
    var item2 = new SteelSword();
    item2.name = "Banana";
    var result = cmp.compare(item1, item2);
    Test.assert(result > 0);
    return true;
}

(:test)
function nameCompareEqual(logger as Test.Logger) as Boolean {
    var cmp = new NameCompare(true);
    var item1 = new SteelSword();
    item1.name = "Sword";
    var item2 = new SteelSword();
    item2.name = "Sword";
    Test.assertEqual(cmp.compare(item1, item2), 0);
    return true;
}

(:test)
function weightCompareDescending(logger as Test.Logger) as Boolean {
    var cmp = new WeightCompare(false);
    var item1 = new SteelSword();
    item1.weight = 10;
    var item2 = new SteelSword();
    item2.weight = 5;
    Test.assertEqual(cmp.compare(item1, item2), -1);
    Test.assertEqual(cmp.compare(item2, item1), 1);
    return true;
}

(:test)
function weightCompareAscending(logger as Test.Logger) as Boolean {
    var cmp = new WeightCompare(true);
    var item1 = new SteelSword();
    item1.weight = 10;
    var item2 = new SteelSword();
    item2.weight = 5;
    Test.assertEqual(cmp.compare(item1, item2), 1);
    Test.assertEqual(cmp.compare(item2, item1), -1);
    return true;
}

(:test)
function weightCompareEqual(logger as Test.Logger) as Boolean {
    var cmp = new WeightCompare(true);
    var item1 = new SteelSword();
    item1.weight = 7;
    var item2 = new SteelSword();
    item2.weight = 7;
    Test.assertEqual(cmp.compare(item1, item2), 0);
    return true;
}

(:test)
function numberCompareAscending(logger as Test.Logger) as Boolean {
    var cmp = new NumberCompare();
    Test.assertEqual(cmp.compare(1, 5), -1);
    Test.assertEqual(cmp.compare(5, 1), 1);
    Test.assertEqual(cmp.compare(3, 3), 0);
    return true;
}

(:test)
function numberCompareNegativeNumbers(logger as Test.Logger) as Boolean {
    var cmp = new NumberCompare();
    Test.assertEqual(cmp.compare(-5, -1), -1);
    Test.assertEqual(cmp.compare(-1, -5), 1);
    Test.assertEqual(cmp.compare(0, 0), 0);
    return true;
}

(:test)
function numberCompareZero(logger as Test.Logger) as Boolean {
    var cmp = new NumberCompare();
    Test.assertEqual(cmp.compare(0, 1), -1);
    Test.assertEqual(cmp.compare(1, 0), 1);
    return true;
}
