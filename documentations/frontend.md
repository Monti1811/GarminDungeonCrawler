# Frontend

UI layer: views, delegates, menus, and controls.

## View Architecture

Garmin Connect IQ uses a View/Delegate pattern:
- **View** -- renders graphics to screen
- **Delegate** -- handles user input (tap, swipe, button)

Views are managed by `DungeonCrawlerApp` which provides factory methods:
- `showRoom()` -- main gameplay
- `showMainMenu()` -- title screen
- `showItemInfo()` -- item details
- `showPlayerDetails()` -- player status
- `showIntro()` -- story screen
- `showNewDungeon()` -- dungeon transition

## Main Gameplay (`Game/`)

### DCGameView

The primary gameplay screen. Uses layered rendering:

| Layer | Content |
|-------|---------|
| Background | Room tiles via `RoomDrawable` |
| Foreground | Player, enemy, item, NPC sprites |
| Overlay | Damage numbers, health bars, mini-map |

**Optimizations:**
- Dirty-flag system redraws only when state changes
- Sprite caching to avoid repeated drawable lookups
- Mini-map hint shows explored areas

### DCGameDelegate

Input handling for the gameplay screen.

**Touch zones:**
Screen divided into 4 triangular quadrants:
- Top triangle = move up
- Bottom triangle = move down
- Left triangle = move left
- Right triangle = move right

**Key input:**
- `KEY_ENTER` -- opens game menu

## Main Menu (`MainMenu/`)

### DCMainMenuView

Title screen with two buttons:
- **New Game** -- starts character creation flow
- **Load Game** -- shows save slot picker

### DCMainMenuDelegate

Handles menu selection:
- New Game -> character selection -> character details -> game creation
- Load Game -> save slot picker (shows player icons, highest level first)
- Settings menu access

## Character Creation (`CharacterCreation/`)

### Flow

1. `DCCharacterCreationDelegate` -- Menu2 list of available classes
2. `DCCharacterCreationDetailsDelegate` -- ViewLoop with 3 pages:
   - Overview (name, description, sprite)
   - Attributes (7 stats with point allocation)
   - Equipment (starting gear display)

### Attribute Allocation

Players can distribute bonus attribute points across 7 stats. Each attribute has min/max bounds (0-500).

## Loading Screens

### CreateGameLoading (`CreateGameLoading/`)

Timer-based multi-phase loading for new games:

| Phase | Action | Progress |
|-------|--------|----------|
| 0 | Initialize game | 0% |
| 1 | Create dungeon | ~5% |
| 2 | Create rooms (one at a time) | 5-90% |
| 3 | Finalize | 100% |

Each room goes through sub-phases:
- Shape creation
- Content population
- Wall cleanup
- Save to storage

### NewDungeonLoading (`NewDungeonLoading/`)

Same pattern for dungeon transitions. Additional phases for preparing next dungeon.

## Game Menu (`GameMenu/`)

Root menu accessible via menu button during gameplay.

### Sub-menus

| Menu | Description |
|------|-------------|
| Inventory | Item list with sorting (name, value, weight) |
| Player Details | Stats, attributes, equipment (3-page ViewLoop) |
| Compendium | Discovered enemies with stats |
| Map | Dungeon overview map |
| Quest | Active quest display |
| Settings | Game settings |
| Debug | Debug tools (enemy/item spawning, stat editing) |

### Item Info (`GameMenu/ItemInfo/`)

3-page ViewLoop for item details:
1. **Overview** -- name, type, icon
2. **Description** -- flavor text, effects
3. **Values** -- attack/defense/weight/value

### Player Details (`GameMenu/PlayerDetails/`)

3-page ViewLoop:
1. **Overview** -- name, level, HP, XP, gold
2. **Attributes** -- 7 stats with allocation UI
3. **Equipment** -- all slots with equipped items

### Compendium (`GameMenu/Compendium/`)

Enemy lore system:
- Discovered enemies appear here
- 2-page ViewLoop: overview + stats
- Tracks kills, damage dealt/taken

### Debug Menu (`GameMenu/DebugMenu/`)

Development tools:
- Spawn specific enemies/items
- Edit player stats directly
- Custom number picker for values

## Shop (`Shop/`)

Merchant trading interface.

### DCShopDelegate

Full buy/sell/talk interface:
- **Buy** -- merchant's inventory with gold costs
- **Sell** -- player's inventory with sell values
- **Talk** -- NPC dialog

Supports amount picking for bulk transactions.

## Quest (`Quest/`)

Quest interface.

### DCQuestDelegate

Quest management:
- **Request** -- 3 quest choices per depth
- **Progress** -- track completion
- **Claim** -- collect rewards
- **Talk** -- NPC dialog

7 quest types:
1. Kill enemies
2. Deal damage
3. Take damage
4. Run for minutes (fitness)
5. Walk stairs (fitness)
6. Bike distance (fitness)
7. Walk steps (fitness)

## Map View (`Map/`)

Dungeon overview map.

### DCMapView

Scrollable dungeon grid:
- Rooms shown as colored rectangles
- Connections shown as lines
- Flags (stairs/merchant/sage) shown as icons
- Depth counter displayed

### DCMapDrawable

Renders the dungeon grid:
- Room shapes (rectangle, L, T, plus, rounded)
- Connection lines between rooms
- Icon caching for flag bitmaps

## Settings (`Settings/`)

### Menus

| Menu | Settings |
|------|----------|
| Root | Access to all settings |
| Rooms | Room count, min/max size |
| Save | Autosave frequency, save-on-exit |

### Persistent Settings

Stored via `Settings` module:
- `rooms_amount` -- number of rooms per dungeon
- `min_room_size` / `max_room_size` -- room dimension bounds
- `save_on_exit` -- auto-save when leaving
- `autosave` -- save every N turns or on timer
- `steps_per_turn` -- walk-to-play step requirement

## Step-to-Play (`StepGate/`)

Optional mechanic gating turn actions behind real-world steps.

- Uses Garmin `ActivityMonitor` sensor
- Configurable steps per turn
- Mock sensor support for testing

## Controls Summary

| Input | Action |
|-------|--------|
| Tap upper quadrant | Move up |
| Tap lower quadrant | Move down |
| Tap left quadrant | Move left |
| Tap right quadrant | Move right |
| Menu button | Open game menu |
| Back button | Exit game (with save prompt) |
| Swipe in map | Pan dungeon view |
| Tap in shop | Buy/sell items |
