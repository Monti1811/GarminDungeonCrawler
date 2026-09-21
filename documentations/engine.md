# Engine

Core game logic in `source/Engine/`.

## Game Module (`Game.mc`)

The `Game` module is the single source of truth for the current session. It holds:

| Field | Type | Description |
|-------|------|-------------|
| `player` | `Player` | Current hero |
| `dungeon` | `Dungeon` | Current dungeon grid |
| `depth` | `Number` | Current dungeon depth (starts at 1) |
| `turns` | `Number` | Total turns played |
| `time_played` | `Number` | Elapsed time in seconds |
| `difficulty` | `Number` | Current difficulty level |
| `game_mode` | `Number` | Game mode flag |
| `map` | `Array<Array<Dictionary>>` | 2D grid of room metadata |

Room metadata in `map` includes: room name, connections, size, visited flag, and flags for stairs/merchant/boss/quest-giver.

**Key methods:**
- `init()` -- resets all state, seeds RNG
- `getCurrentRoom()` / `setCurrentRoom()` -- room navigation
- `save()` / `load()` -- full session serialization
- `clearSession()` -- frees all memory

## Maps

### Dungeon (`Dungeon.mc`)

A grid of rooms connected by tunnels. Manages room storage and navigation.

- **Grid size** -- randomized per dungeon (varies by depth)
- **Room storage** -- rooms saved to `Storage` keyed by position string (e.g., "0_1")
- **Connections** -- dictionary mapping room names to directional connections
- **Style** -- one of 13 `DungeonStyle` values, randomly chosen at creation
- **Special rooms** -- stairs, merchant, quest-giver placed after room generation

**Dungeon style probabilities:**
- 50% Normal
- 5% each: Poison, Shadow, Nature, Lava, Sand, Dark, Crystal, Blood, Water

### Room (`Room.mc`)

A single room instance containing the tile map, enemies, items, and NPCs.

**State:**
- `_map` -- the `Map` tile grid
- `_enemies` -- array of `Enemy` objects
- `_items` -- array of `Item` objects on the ground
- `_npcs` -- array of `NPC` objects (merchant, quest-giver)
- `_connections` -- which directions have tunnel openings
- `_size` / `_shape` -- room dimensions and shape enum

**MapElement enum:** N_P (nothing/passable), WLE/WRI/WTO/WBO (walls), WTL/WTR/WBL/WBR (wall corners), PAS (passable).

**Key methods:**
- `getMapData()` -- returns dictionary for view initialization
- `addConnection(direction)` -- creates tunnel openings in walls
- `save()` / `load()` -- full serialization
- `freeMemory()` -- releases all entity/sprite references

### Map (`Map.mc`)

The core tile-based grid. 1132 lines -- the largest file in the codebase.

**Internal state:**
- `_width` / `_height` -- grid dimensions
- `_tiles` -- 2D array of `Tile` objects
- `_map_string` -- cached string representation for rendering

**Room shape generation:**
- `createRoomShape()` -- static factory that creates PASSABLE interior based on `RoomShape` enum
- Supported shapes: Rectangle, L-Shape, T-Shape, Plus, Rounded
- After shape creation, `addIslands()` adds interior wall blocks for tactical cover
- `addWallsAroundPassable()` converts EMPTY tiles adjacent to PASSABLE into WALLs

**Wall variant system:**
- `getWallVariant(x, y)` -- computes visual variant based on 8-neighbor analysis
- 21 wall variants (horizontal, vertical, corners, T-pieces, cross)
- Variants computed at render time, not stored

**Tunnel system:**
- `addTunnel()` -- carves passages between connected rooms
- Supports straight, L-shaped, and zigzag tunnel shapes

**Other methods:**
- `getMapString()` -- generates character-code string for bitmap font rendering
- `deepcopy()` -- full deep copy of map state
- `setTypeXY()` / `setType()` -- tile mutation

### Tile (`Tile.mc`)

Individual map cell.

| Field | Type | Description |
|-------|------|-------------|
| `type` | `TileType` | EMPTY, WALL, PASSABLE, STAIRS |
| `x` / `y` | `Number` | Grid position |
| `content` | `Object?` | Item, Enemy, or NPC on this tile |
| `player` | `Boolean` | Whether the player is on this tile |

**TileType enum:** EMPTY, WALL, PASSABLE, STAIRS

### RoomDrawable (`RoomDrawable.mc`)

A `WatchUi.Drawable` that renders the room to screen using the dungeon bitmap font.

- Renders tile-by-tile from the map string
- Each `DungeonStyle` has distinct foreground/background color pairs
- `getCharColor()` returns per-tile color based on dungeon style
- Caches flag bitmaps for stairs/merchant/quest-giver icons

### Turn (`Turn.mc`)

Manages the turn-based game loop. 378 lines.

**Turn flow (`doTurn(direction)`):**
1. Validate movement (bounds, wall collision)
2. Check target tile for stairs, NPCs, or enemies
3. If enemy adjacent: trigger combat via `Battle`
4. Move player to new position
5. Process enemy turns (AI queue, 50ms delay each)
6. Apply elemental effects (fire/ice damage over time)
7. Check autosave timer

**Enemy AI queue:** Enemies take turns sequentially, not simultaneously. Each enemy's `doTurn()` is called with a 50ms delay to prevent watchdog trips.

**Energy system:** Each entity has an energy pool. Actions cost energy; when depleted, the entity waits. Energy regenerates each turn.

## Combat (`Battle.mc`)

Module with two symmetric functions: `attackEnemy()` and `attackPlayer()`.

**Damage formula:**
```
baseDamage = attacker.getAttack(defender)
defense = defender.getDefense(attacker)
reduction = defense / (defense + baseDamage)    // capped at 90%
damage = ceil(round(baseDamage * (1 - reduction)), 1)
```

**On hit:**
- Floating damage text shown at defender position
- Combat log entry written
- If kill: attacker gains XP, quest kill tracked

**Attack calculation (Player):**
- Base weapon damage + attribute weight bonus
- Luck roll for critical hits (1.5x damage)
- Elemental damage added if weapon has element

**Defense calculation (Player):**
- Base armor defense + attribute weight bonus
- Elemental resistance reduces elemental damage

**Attack/Defense (Enemy):**
- Base damage/armor scaled by enemy level
- `ENEMY_DAMAGE_SCALE` and `ENEMY_HEALTH_SCALE` constants

## Entity System (`Entities/`)

### Entity (base class)

Base for all game entities (Player, Enemy, NPC).

| Field | Type | Description |
|-------|------|-------------|
| `id` | `Number` | Unique type identifier |
| `name` | `String` | Display name |
| `energy` / `energy_per_turn` | `Number` | Action economy |
| `guid` | `String` | Global unique identifier |
| `elemental_effects` | `Dictionary` | Active fire/ice effects |

**Elemental system:**
- `applyElementalEffect()` -- adds fire/ice damage over time
- `applyElementalTurnEffects()` -- processes damage each turn
- `getElementalResistance()` -- reduces elemental damage based on armor

### EntityManager

Global registry of all entities. Auto-assigns GUIDs, supports add/remove/lookup. Used for save/load and cross-referencing.

## Items (`Items/`)

### Item Hierarchy

```
Item
  ├── EquippableItem (attribute bonuses on equip/unequip)
  │     ├── WeaponItem (attack, range, cooldown, weapon_type, element)
  │     └── ArmorItem (defense, defense_type, element)
  ├── ConsumableItem (health/mana potions, removed on use)
  ├── KeyItem (opens treasure chests)
  ├── Gold (pickup adds gold)
  └── TreasureChest (requires key, wraps any loot item)
```

### Item ID Ranges

| Range | Category |
|-------|----------|
| 0-999 | Weapons |
| 1000-1999 | Armor |
| 2000-2999 | Consumables |
| 3000 | Key |
| 5000 | Gold |
| 6000 | Treasure Chest |

### Item Tiers

9 elemental tiers, each with weapons and armor:

| Tier | Name | Element |
|------|------|---------|
| 0 | Steel | None |
| 1 | Bronze | None |
| 2 | Fire | Fire |
| 3 | Ice | Ice |
| 4 | Grass | None |
| 5 | Water | None |
| 6 | Gold | None |
| 7 | Demon | None |
| 8 | Blood | None |

### Equipment Slots

`HEAD`, `CHEST`, `BACK`, `LEGS`, `FEET`, `LEFT_HAND`, `RIGHT_HAND`, `EITHER_HAND`, `ACCESSORY`, `AMMUNITION`, `NONE`

### Spawn System

Items selected via weighted random across 5 categories:
- Weapons, Armor, Consumables, High-Quality, Merchant

Weights are depth-dependent (`ItemSpecificValues`). Treasure chests have 10% base chance (40% for high-quality items).

## Utilities (`Util/`)

| Module | Purpose |
|--------|---------|
| `Constants` | Screen dimensions, attribute weights, equipment slot mappings |
| `MathUtil` | `Point2D`, random, weighted_random, clamp, triangle-in-area |
| `MapUtil` | Movement validation, BFS flood-fill, position pools |
| `Pathfinder` | A* pathfinding with Manhattan heuristic, 200-iteration cap |
| `ElementUtil` | Maps item IDs to element types, builds effect dictionaries |
| `EnemySpecificValues` | Depth-based enemy spawn weight tables |
| `ItemSpecificValues` | Depth-based item spawn weight tables |
| `SaveData` | Save/load via Garmin `Storage`, compendium tracking |
| `Log` | In-memory message log (max 100 entries) |
| `Listener` | Simple event system (add/remove/trigger by Symbol) |
| `Quests` | Quest generation, fitness tracking via Garmin sensors |
