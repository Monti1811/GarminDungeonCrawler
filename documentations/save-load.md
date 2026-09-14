# Save/Load System

Serialization, compendium, and save slot management.

## Overview

The save system uses Garmin's `Storage` API for persistent data. Each game session is fully serializable, including player state, dungeon layout, room contents, and discovered content.

## Save Data Architecture

### Game State

`Game.save()` serializes:
- Player (full state)
- Dungeon (grid, connections, style)
- Session data (depth, turns, time_played, difficulty)
- Room metadata map

### Player State

`Player.save()` serializes:
- Health, mana, level, experience, gold
- All 7 attributes
- Equipped items (by ID and slot)
- Inventory items (by ID and quantity)
- Position (x, y)

### Dungeon State

`Dungeon.save()` serializes:
- Grid size
- Room grid (position -> storage key mapping)
- Connections dictionary
- Dungeon style
- Current room position

### Room State

`Room.save()` serializes:
- Map tiles (2D array of tile types)
- Enemies (list of enemy states)
- Items on ground (list of item states)
- NPCs (list of NPC states)
- Connections, size, shape

## Storage Keys

| Key Pattern | Content |
|-------------|---------|
| `"player"` | Player state dictionary |
| `"dungeon"` | Dungeon state dictionary |
| `"room_X_Y"` | Room state dictionary |
| `"compendium"` | Discovered enemies/items |
| `"settings"` | Game settings |
| `"save_X"` | Save slot metadata |

## Save Slots

Multiple save slots supported:
- Each slot stores metadata (player name, level, timestamp, depth)
- Save slot picker sorts by highest level
- `SaveCompare` comparator for sorting

## Autosave

Configurable autosave behavior:
- **Every N turns** -- saves after each turn count threshold
- **On timer** -- saves at regular intervals
- **On exit** -- saves when leaving game (if enabled)

Autosave triggered in `Turn.doTurn()` after processing enemy turns.

## Compendium

Global registry of discovered content:

### Discovered Enemies
- Tracks enemy types encountered
- Records kills, damage dealt, damage taken
- Visible in Compendium menu

### Discovered Items
- Tracks item types found
- Records first discovery timestamp
- Visible in Compendium menu

### Implementation

`SaveData` module manages compendium:
- `discoverEnemy(id)` -- marks enemy as discovered
- `discoverItem(id)` -- marks item as discovered
- `getDiscoveredEnemies()` -- returns list of discovered enemy IDs
- `getDiscoveredItems()` -- returns list of discovered item IDs

## Save/Load Flow

### Saving

```
Player action -> Turn.doTurn() -> autosave check
  -> Game.save()
    -> Player.save() -> Dictionary
    -> Dungeon.save() -> Dictionary
    -> Room.save() -> Dictionary (per room)
    -> Storage.setValue(key, data)
```

### Loading

```
Main menu -> Load Game -> save slot picker
  -> Game.load()
    -> Storage.getValue(key) -> Dictionary
    -> Player.onLoad(data)
    -> Dungeon.onLoad(data)
    -> Room.onLoad(data) (per room)
    -> Game state restored
```

## Memory Considerations

- Room data saved individually to avoid large single allocations
- `freeMemory()` called after saving rooms
- Compendium data kept minimal (IDs only, no full objects)
- Save slots use lightweight metadata for quick listing
