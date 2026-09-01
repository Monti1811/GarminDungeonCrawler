import Toybox.Test;
import Toybox.Lang;

// --- toIntPoint2D / fromIntPoint2D ---

(:test)
function toIntPoint2DPacksCorrectly(logger as Test.Logger) as Boolean {
    // [3, 5] → (3 << 8) + 5 = 773
    Test.assertEqual(Pathfinder.toIntPoint2D([3, 5]), 773);
    return true;
}

(:test)
function toIntPoint2DZeroOrigin(logger as Test.Logger) as Boolean {
    Test.assertEqual(Pathfinder.toIntPoint2D([0, 0]), 0);
    return true;
}

(:test)
function fromIntPoint2DUnpacksCorrectly(logger as Test.Logger) as Boolean {
    var pos = Pathfinder.fromIntPoint2D(773);
    Test.assertEqual(pos[0], 3);
    Test.assertEqual(pos[1], 5);
    return true;
}

(:test)
function fromIntPoint2DZeroOrigin(logger as Test.Logger) as Boolean {
    var pos = Pathfinder.fromIntPoint2D(0);
    Test.assertEqual(pos[0], 0);
    Test.assertEqual(pos[1], 0);
    return true;
}

(:test)
function intPointRoundTrip(logger as Test.Logger) as Boolean {
    var testCases = [[0, 0], [1, 0], [0, 1], [5, 10], [255, 255], [100, 50]];
    for (var i = 0; i < testCases.size(); i++) {
        var original = testCases[i];
        var packed = Pathfinder.toIntPoint2D(original);
        var unpacked = Pathfinder.fromIntPoint2D(packed);
        Test.assertEqual(unpacked[0], original[0]);
        Test.assertEqual(unpacked[1], original[1]);
    }
    return true;
}

// --- manhattanHeuristic ---

(:test)
function manhattanHeuristicSamePointIsZero(logger as Test.Logger) as Boolean {
    var p = Pathfinder.toIntPoint2D([5, 5]);
    Test.assertEqual(Pathfinder.manhattanHeuristic(p, p), 0);
    return true;
}

(:test)
function manhattanHeuristicHorizontal(logger as Test.Logger) as Boolean {
    var a = Pathfinder.toIntPoint2D([2, 3]);
    var b = Pathfinder.toIntPoint2D([5, 3]);
    Test.assertEqual(Pathfinder.manhattanHeuristic(a, b), 3);
    return true;
}

(:test)
function manhattanHeuristicVertical(logger as Test.Logger) as Boolean {
    var a = Pathfinder.toIntPoint2D([1, 2]);
    var b = Pathfinder.toIntPoint2D([1, 7]);
    Test.assertEqual(Pathfinder.manhattanHeuristic(a, b), 5);
    return true;
}

(:test)
function manhattanHeuristicDiagonal(logger as Test.Logger) as Boolean {
    var a = Pathfinder.toIntPoint2D([0, 0]);
    var b = Pathfinder.toIntPoint2D([3, 4]);
    Test.assertEqual(Pathfinder.manhattanHeuristic(a, b), 7);
    return true;
}

(:test)
function manhattanHeuristicSymmetric(logger as Test.Logger) as Boolean {
    var a = Pathfinder.toIntPoint2D([1, 2]);
    var b = Pathfinder.toIntPoint2D([5, 8]);
    Test.assertEqual(Pathfinder.manhattanHeuristic(a, b), Pathfinder.manhattanHeuristic(b, a));
    return true;
}

// --- pq_enqueue / pq_dequeue ---

(:test)
function pqEnqueueSingleElement(logger as Test.Logger) as Boolean {
    var queue = [] as Array;
    Pathfinder.pq_enqueue(queue, 5, 42);
    Test.assertEqual(queue.size(), 1);
    Test.assertEqual(Pathfinder.pq_dequeue(queue), 42);
    return true;
}

(:test)
function pqEnqueueMaintainsPriorityOrder(logger as Test.Logger) as Boolean {
    var queue = [] as Array;
    Pathfinder.pq_enqueue(queue, 10, 1);
    Pathfinder.pq_enqueue(queue, 5, 2);
    Pathfinder.pq_enqueue(queue, 8, 3);

    // Should dequeue in priority order: 5, 8, 10
    Test.assertEqual(Pathfinder.pq_dequeue(queue), 2);
    queue.remove(queue[0]);
    Test.assertEqual(Pathfinder.pq_dequeue(queue), 3);
    queue.remove(queue[0]);
    Test.assertEqual(Pathfinder.pq_dequeue(queue), 1);
    return true;
}

(:test)
function pqEnqueueEqualPriorities(logger as Test.Logger) as Boolean {
    var queue = [] as Array;
    Pathfinder.pq_enqueue(queue, 5, 1);
    Pathfinder.pq_enqueue(queue, 5, 2);
    Pathfinder.pq_enqueue(queue, 5, 3);

    // All should have priority 5, order of insertion preserved
    Test.assertEqual(queue.size(), 3);
    Test.assertEqual((queue[0] as Array)[0], 5);
    Test.assertEqual((queue[1] as Array)[0], 5);
    Test.assertEqual((queue[2] as Array)[0], 5);
    return true;
}

(:test)
function pqEnqueueDescendingOrder(logger as Test.Logger) as Boolean {
    var queue = [] as Array;
    Pathfinder.pq_enqueue(queue, 30, 1);
    Pathfinder.pq_enqueue(queue, 20, 2);
    Pathfinder.pq_enqueue(queue, 10, 3);

    Test.assertEqual(Pathfinder.pq_dequeue(queue), 3);
    queue.remove(queue[0]);
    Test.assertEqual(Pathfinder.pq_dequeue(queue), 2);
    queue.remove(queue[0]);
    Test.assertEqual(Pathfinder.pq_dequeue(queue), 1);
    return true;
}
