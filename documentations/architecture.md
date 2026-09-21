# Architecture

System overview of the DungeonCrawler codebase.

## Project Structure

```
source/
  DungeonCrawlerApp.mc     -- App entry point, view factory
  Main.mc                  -- Central orchestrator (game lifecycle)
  Engine/                  -- Game logic (backend)
    Game.mc                -- Global game state module
    Maps/                  -- Dungeon, Room, Map, Tile, Turn, RoomDrawable
    Entities/              -- Player, Enemy, NPC, Entity base class
    Battles/               -- Combat formula
    Items/                 -- Item hierarchy and factory
    Util/                  -- Math, pathfinding, constants, save data, quests
  FrontEnd/                -- UI layer (views and delegates)
    Game/                  -- Main gameplay view
    MainMenu/              -- Title screen
    CharacterCreation/     -- Hero setup
    GameMenu/              -- In-game menus (inventory, player, compendium, debug)
    Shop/                  -- Merchant trading
    Quest/                 -- Quest interface
    Map/                   -- Dungeon overview map
    Settings/              -- Settings menus
    CreateGameLoading/     -- New game loading screen
    NewDungeonLoading/     -- Next dungeon loading screen
    Intro/                 -- Story screen
    GameOver/              -- Death screen
  Tests/                   -- Unit tests
resources/                 -- Drawables, fonts, layouts, strings
tools/                     -- Balance scripts, MCP server
helpers/                   -- Font/sprite utilities, release script
```

## Layered Architecture

```
┌─────────────────────────────────────────┐
│              FrontEnd (UI)              │
│  Views, Delegates, Menus, Input         │
├─────────────────────────────────────────┤
│              Main.mc                    │
│  Orchestrator: game lifecycle,          │
│  room creation pipeline                 │
├─────────────────────────────────────────┤
│              Engine (Logic)             │
│  Game, Maps, Entities, Items, Combat    │
├─────────────────────────────────────────┤
│              Util                       │
│  Math, Pathfinder, Constants, SaveData  │
└─────────────────────────────────────────┘
```

## Data Flow

### Player Action (Movement)
```
User tap -> DCGameDelegate (FrontEnd)
  -> Turn.doTurn(direction) (Engine/Maps)
    -> validate movement (MapUtil)
    -> check for stairs/NPC/enemies (Room)
      -> if enemy: Battle.attackEnemy() / Battle.attackPlayer()
      -> if NPC: open shop/quest menu
      -> if stairs: trigger dungeon transition
    -> Enemy.doTurn() for each enemy (AI + Pathfinder)
    -> DCGameView.update() (FrontEnd)
      -> RoomDrawable.draw() (Engine/Maps)
```

### Room Creation Pipeline
```
DCCreateGameProgressDelegate (timer-based phases):
  Phase 0a: Main.createRoomShapeForDungeon()
    -> Map.createRoomShape() + Map.addIslands()
  Phase 0b: Main.createRoomContentForDungeon()
    -> createRandomEnemies() + createRandomItems() + addConnection()
  Phase 1:  Main.cleanupRoomForDungeon()
    -> Map.addWallsAroundPassable()
  Phase 2:  Main.saveRoomForDungeon()
    -> Room.save() -> Storage -> Game.addRoomToMap()
```

## Module System

Monkey C modules are used as namespaces for factory/registry patterns:
- `Players` -- player class factory (IDs 0-4, 999)
- `Enemies` -- enemy factory (IDs 0-37) with weighted spawn tables
- `Items` -- item factory (150+ IDs) with weighted category tables
- `Battle` -- combat formula (attackEnemy/attackPlayer)
- `Game` -- global state container (player, dungeon, depth, turns)
- `Constants` -- screen dimensions, attribute weights, scaling constants
- `MathUtil` -- random numbers, weighted random, clamp, Point2D
- `MapUtil` -- movement validation, BFS flood-fill, position pools
- `Log` -- in-memory message log (max 100 entries)
- `Quests` -- quest generation, tracking, fitness sensor integration

## Class Hierarchy

### Entities
```
Entity (base)
  ├── Player
  │     ├── Warrior
  │     ├── Mage
  │     ├── Archer
  │     ├── Nameless
  │     ├── Paladin
  │     └── God (debug)
  ├── Enemy
  │     ├── Frog, Bat, Goblin, Imp, Orc, Skeleton, Zombie...
  │     ├── ElementalAir/Earth/Fire/Gold/Goo/Plant/Water (Small + Normal)
  │     ├── DarkKnight, Necromancer, Chort, Bies...
  │     └── Demon, Ogre, Tentackle (bosses)
  └── NPC
        ├── Merchant
        └── QuestGiver
```

### Items
```
Item (base)
  ├── EquippableItem
  │     ├── WeaponItem (attack, range, cooldown, element)
  │     └── ArmorItem (defense, defense_type, element)
  ├── ConsumableItem (health/mana potions)
  ├── KeyItem (opens treasure chests)
  ├── Gold (currency pickup)
  └── TreasureChest (wraps loot, requires key)
```

## Memory Management

Garmin watches have severe memory constraints. The codebase uses several strategies:

- **`freeMemory()`** -- called on rooms, entities, and sprites when no longer needed
- **On-demand loading** -- rooms loaded from Storage when entered, freed after rendering
- **Sprite cache invalidation** -- `freeSpriteCache()` called on room transitions
- **Flat arrays** -- position pools use flat `Array<Number>` instead of nested `Array<Array<Number>>`
- **Integer point encoding** -- positions encoded as `x * 1000 + y` to avoid array allocations

## Watchdog

The Garmin watchdog is call-count based, not time-based. There is a maximum number of function calls per tick. If exceeded, the watch resets.

**Key constraints:**
- Each `onTimer()` tick must stay within limits
- Loops, array allocations, and deep call stacks consume budget quickly
- The watchdog counter resets when control returns to the user (e.g., `Ui.requestUpdate()`)

**Optimizations used:**
- Room creation split into timer-based phases (one room per tick)
- Enemy AI processes one enemy per timer tick (50ms delay)
- Position pools pre-computed and cached
- Pathfinding capped at 200 iterations
- Array allocations minimized (flat arrays, inline offsets)
