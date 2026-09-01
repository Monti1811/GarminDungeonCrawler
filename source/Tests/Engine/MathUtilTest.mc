import Toybox.Test;
import Toybox.Lang;

// --- floor ---

(:test)
function floorReturnsValueBelowMax(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.floor(5, 10), 5);
    return true;
}

(:test)
function floorReturnsMaxWhenValueExceeds(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.floor(15, 10), 10);
    return true;
}

(:test)
function floorReturnsMaxWhenEqual(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.floor(10, 10), 10);
    return true;
}

// --- ceil ---

(:test)
function ceilReturnsValueAboveMin(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.ceil(15, 10), 15);
    return true;
}

(:test)
function ceilReturnsMinWhenValueBelow(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.ceil(5, 10), 10);
    return true;
}

(:test)
function ceilReturnsMinWhenEqual(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.ceil(10, 10), 10);
    return true;
}

// --- max ---

(:test)
function maxReturnsFirstIfGreater(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.max(10, 5), 10);
    return true;
}

(:test)
function maxReturnsSecondIfGreater(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.max(3, 7), 7);
    return true;
}

(:test)
function maxReturnsEqualIfEqual(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.max(5, 5), 5);
    return true;
}

// --- min ---

(:test)
function minReturnsFirstIfSmaller(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.min(3, 8), 3);
    return true;
}

(:test)
function minReturnsSecondIfSmaller(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.min(9, 4), 4);
    return true;
}

(:test)
function minReturnsEqualIfEqual(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.min(5, 5), 5);
    return true;
}

// --- clamp ---

(:test)
function clampReturnsValueInRange(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.clamp(5, 0, 10), 5);
    return true;
}

(:test)
function clampReturnsMinIfBelow(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.clamp(-5, 0, 10), 0);
    return true;
}

(:test)
function clampReturnsMaxIfAbove(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.clamp(15, 0, 10), 10);
    return true;
}

(:test)
function clampReturnsMinWhenEqual(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.clamp(0, 0, 10), 0);
    return true;
}

(:test)
function clampReturnsMaxWhenEqual(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.clamp(10, 0, 10), 10);
    return true;
}

// --- abs ---

(:test)
function absReturnsPositiveForNegative(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.abs(-5), 5);
    return true;
}

(:test)
function absReturnsSameForPositive(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.abs(5), 5);
    return true;
}

(:test)
function absReturnsZeroForZero(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.abs(0), 0);
    return true;
}

// --- isInArea ---

(:test)
function isInAreaReturnsTrueInside(logger as Test.Logger) as Boolean {
    Test.assertMessage(MathUtil.isInArea(5, 5, 0, 10, 0, 10), "point inside area");
    return true;
}

(:test)
function isInAreaReturnsFalseOutside(logger as Test.Logger) as Boolean {
    Test.assertMessage(!MathUtil.isInArea(15, 5, 0, 10, 0, 10), "point outside x");
    return true;
}

(:test)
function isInAreaReturnsFalseOutsideY(logger as Test.Logger) as Boolean {
    Test.assertMessage(!MathUtil.isInArea(5, 15, 0, 10, 0, 10), "point outside y");
    return true;
}

(:test)
function isInAreaReturnsTrueOnBoundary(logger as Test.Logger) as Boolean {
    Test.assertMessage(MathUtil.isInArea(0, 0, 0, 10, 0, 10), "on boundary");
    return true;
}

// --- IndexToPos2D / Pos2DToIndex ---

(:test)
function indexToPos2DReturnsCorrectCoords(logger as Test.Logger) as Boolean {
    var pos = MathUtil.IndexToPos2D(7, 5);
    Test.assertEqual(pos[0], 2);
    Test.assertEqual(pos[1], 1);
    return true;
}

(:test)
function indexToPos2DZero(logger as Test.Logger) as Boolean {
    var pos = MathUtil.IndexToPos2D(0, 5);
    Test.assertEqual(pos[0], 0);
    Test.assertEqual(pos[1], 0);
    return true;
}

(:test)
function pos2DToIndexReturnsCorrectIndex(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.Pos2DToIndex([2, 1], 5), 7);
    return true;
}

(:test)
function pos2DToIndexZero(logger as Test.Logger) as Boolean {
    Test.assertEqual(MathUtil.Pos2DToIndex([0, 0], 5), 0);
    return true;
}

(:test)
function indexPosRoundTrip(logger as Test.Logger) as Boolean {
    var width = 8;
    for (var i = 0; i < 40; i++) {
        var pos = MathUtil.IndexToPos2D(i, width);
        var idx = MathUtil.Pos2DToIndex(pos, width);
        Test.assertEqual(idx, i);
    }
    return true;
}

// --- isPointAdjacent ---

(:test)
function isPointAdjacentReturnsTrueForNeighbor(logger as Test.Logger) as Boolean {
    Test.assertMessage(MathUtil.isPointAdjacent([5, 5], [6, 5]), "direct neighbor");
    return true;
}

(:test)
function isPointAdjacentReturnsTrueForDiagonal(logger as Test.Logger) as Boolean {
    Test.assertMessage(MathUtil.isPointAdjacent([5, 5], [6, 6]), "diagonal neighbor");
    return true;
}

(:test)
function isPointAdjacentReturnsFalseForFar(logger as Test.Logger) as Boolean {
    Test.assertMessage(!MathUtil.isPointAdjacent([0, 0], [3, 3]), "far apart");
    return true;
}

(:test)
function isPointAdjacentReturnsTrueForSame(logger as Test.Logger) as Boolean {
    Test.assertMessage(MathUtil.isPointAdjacent([5, 5], [5, 5]), "same point");
    return true;
}

// --- isPointDirectAdjacent ---

(:test)
function isPointDirectAdjacentReturnsTrueForHorizontal(logger as Test.Logger) as Boolean {
    Test.assertMessage(MathUtil.isPointDirectAdjacent([5, 5], [6, 5]), "horizontal");
    return true;
}

(:test)
function isPointDirectAdjacentReturnsTrueForVertical(logger as Test.Logger) as Boolean {
    Test.assertMessage(MathUtil.isPointDirectAdjacent([5, 5], [5, 6]), "vertical");
    return true;
}

(:test)
function isPointDirectAdjacentReturnsFalseForDiagonal(logger as Test.Logger) as Boolean {
    Test.assertMessage(!MathUtil.isPointDirectAdjacent([5, 5], [6, 6]), "diagonal");
    return true;
}

(:test)
function isPointDirectAdjacentReturnsFalseForSame(logger as Test.Logger) as Boolean {
    Test.assertMessage(!MathUtil.isPointDirectAdjacent([5, 5], [5, 5]), "same point");
    return true;
}

(:test)
function isPointDirectAdjacentReturnsFalseForFar(logger as Test.Logger) as Boolean {
    Test.assertMessage(!MathUtil.isPointDirectAdjacent([0, 0], [2, 0]), "two apart");
    return true;
}

// --- weighted_random ---

(:test)
function weightedRandomReturnsKeyInRange(logger as Test.Logger) as Boolean {
    var weights = {1 => 50, 2 => 50};
    for (var i = 0; i < 50; i++) {
        var result = MathUtil.weighted_random(weights) as Number;
        Test.assertMessage(result == 1 || result == 2, "result should be 1 or 2");
    }
    return true;
}

(:test)
function weightedRandomRespectsWeights(logger as Test.Logger) as Boolean {
    var weights = {1 => 100, 2 => 0};
    var result = MathUtil.weighted_random(weights) as Number;
    Test.assertEqual(result, 1);
    return true;
}

// --- random ---

(:test)
function randomReturnsValueInRange(logger as Test.Logger) as Boolean {
    for (var i = 0; i < 100; i++) {
        var result = MathUtil.random(5, 10);
        Test.assertMessage(result >= 5 && result <= 10, "result " + result + " out of range");
    }
    return true;
}

(:test)
function randomReturnsSameWhenMinMaxEqual(logger as Test.Logger) as Boolean {
    var result = MathUtil.random(7, 7);
    Test.assertEqual(result, 7);
    return true;
}

// --- areaTriangle ---

(:test)
function areaTriangleReturnsCorrectArea(logger as Test.Logger) as Boolean {
    // Right triangle with legs 3 and 4, area = 6
    var area = MathUtil.areaTriangle(0, 0, 3, 0, 0, 4);
    Test.assertMessage(area >= 5.9 && area <= 6.1, "expected area ~6, got " + area);
    return true;
}
