# Testing

Test framework, running tests, and test organization.

## Test Framework

Custom unit testing framework built for Monkey C. Tests run in the Connect IQ simulator via `monkeydo` with the `-t` flag.

## Running Tests

### All Tests

```bash
& "F:\Code\Garmin\DungeonCrawler\run_tests.ps1"
```

### Single Test

```bash
& "F:\Code\Garmin\DungeonCrawler\run_tests.ps1" "testFunctionName"
```

### What the Script Does

1. Compiles with `-t` (test mode)
2. Starts simulator with `venu2s` device
3. Runs `monkeydo` with `/t` flag
4. Reports results (passed/failed/errors)
5. Cleans up simulator

### Manual Testing

```bash
# Compile
& "java.exe" "-Xms1g" "-Dfile.encoding=UTF-8" "-jar" "...\monkeybrains.jar" "-o" "bin\DungeonCrawler.prg" "-f" "monkey.jungle" "-y" "f:\Code\Garmin\developer_key" "-d" "venu2s" "-w" "-t"

# Start simulator
Start-Process "...\simulator.exe" -ArgumentList "-d", "venu2s"

# Run tests
& "...\monkeydo.bat" "bin\DungeonCrawler.prg" "venu2s" "/t" "testFunctionName"
```

## Test Organization

### Engine Tests (`Tests/Engine/`)

| Test | Description |
|------|-------------|
| CombatIntegrationTest | End-to-end combat scenarios |
| ElementUtilTest | Elemental damage/resistance |
| EnemyFactoryTest | Enemy creation from IDs |
| EntityManagerTest | Entity registry |
| GameModuleTest | Game state management |
| IslandNeighborTest | Interior wall island analysis |
| ItemFactoryTest | Item creation from IDs |
| ListenerTest | Event system |
| LogTest | Message log |
| MapUtilTest | Map utility functions |
| MathUtilTest | Math utilities |
| PathfinderTest | A* pathfinding |
| PlayerFactoryTest | Player class creation |
| QuestTest | Quest system |
| RoomCreationProfileTest | Room generation profiles |
| RoomCreationStressTest | Room generation stress tests |
| RoomIntegrationTest | Room creation end-to-end |
| SimUtilTest | Simulation utilities |
| TileTest | Tile operations |
| TunnelTest | Tunnel generation |
| WallVariantTest | Wall variant calculation |

### Frontend Tests (`Tests/FrontEnd/`)

| Test | Description |
|------|-------------|
| CompareTest | Sorting comparators |
| PlayerInteractionTest | Player-item-enemy interactions |
| SettingsTest | Settings persistence |
| StepGateTest | Walk-to-play gating |

## Mock Framework

Custom mock system in `Tests/Mock.mc`:

```mc
var mock = new MockInstance();
mock.when(:methodName).thenReturn(expectedValue);
mock.recordCall(:methodName);
var count = mock.getCallCount(:methodName);
mock.resetAll();
```

## Writing Tests

Test functions must be:
1. Public functions in `source/Tests/`
2. Return `Boolean` (true = pass, false = fail)
3. Accept a `Test.Logger` parameter
4. Follow naming convention: `testFunctionName(logger) as Boolean`

Example:

```mc
function myTest(logger as Test.Logger) as Boolean {
    // Setup
    var map = Map.createRandomMap(10, 10, 0, 9, 0, 9);
    
    // Act
    Map.addWallsAroundPassable(map);
    
    // Assert
    if (map.getTile(0, 0).type != WALL) {
        logger.debug("FAIL: Expected WALL at (0,0)");
        return false;
    }
    
    logger.debug("PASS");
    return true;
}
```

## Test Categories

### Integration Tests
- Room creation pipeline (shape -> content -> cleanup -> save)
- Combat flows (attack -> damage -> death -> XP)
- Save/load round-trips

### Stress Tests
- Room creation with many iterations
- Memory pressure scenarios
- Watchdog budget validation

### Unit Tests
- Individual function behavior
- Factory creation from IDs
- Math utility functions
- Pathfinding correctness
