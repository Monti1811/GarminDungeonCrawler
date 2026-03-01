# Dungeon Crawler - AI Coding Agent Instructions

## Project Overview
This is a **Garmin Connect IQ watch app** - a turn-based roguelike dungeon crawler for Garmin watches (Venu 2S), written in **Monkey C**. The game features procedurally generated dungeons, combat, inventory management, and persistent save/load functionality.

## Core Architecture

### App Entry & Navigation Flow
- **Entry point**: `DungeonCrawlerApp.mc` → `getInitialView()` returns main menu by default
- **Navigation pattern**: View/Delegate pairs using `WatchUi.switchToView()` or `WatchUi.pushView()`
- All UI screens follow the pattern: `DC[ScreenName]View` + `DC[ScreenName]Delegate`
- Views extend `WatchUi.View` (or `WatchUi.ViewLoop`), Delegates extend `WatchUi.BehaviorDelegate` (or `Menu2InputDelegate`, `ConfirmationDelegate`)

### Game State Management (Module Pattern)
The codebase uses **global singleton modules** (not classes) for shared state:
- **`$.Game`**: Central game state (depth, player, dungeon, map, turns, time tracking)
- **`$.EntityManager`**: GUID-based entity registry for save/load (all entities register on creation)
- **`$.Items`** / **`$.Enemies`**: Item/enemy factories with player-specific ID generation
- **`$.SaveData`**: Persistent storage wrapper using Garmin's `Storage` API
  - **Compendium tracking**: `discovered_enemies`, `discovered_items` dictionaries for discovered content
- **`$.Settings`**: App settings persistence
- **`$.Quests`**: Quest tracking and progress
- **`$.StepGate`**: Real-world step counter integration for turn gating
- **`$.SimUtil`**, **`$.MathUtil`**, **`$.Pathfinder`**, **`$.Log`**, **`$.ElementUtil`**: Utility modules

Access global modules via `$.ModuleName.function()`. The `$` is a Monkey C global namespace accessor.

### Type System Patterns
```monkey-c
typedef Point2D as [Numeric, Numeric];  // Used throughout for positions
```
Common types: `Point2D`, `ResourceId` (for Rez assets), `PropertyKeyType`/`PropertyValueType` (for Storage API).

### Entity System
- **Base class**: `Entity` (has `guid`, `energy`, save/load methods)
- **Hierarchy**: `Entity` → `Player`, `Enemy`, `NPC`, `Item` subclasses
- All entities **must call `register()`** to be added to `EntityManager` (assigns GUID for persistence)
- Items/Enemies use factory pattern: `Items.init(player_id)` / `Enemies.init(player_id)` create unique instances per save
- **Player Classes**: Moved to `source/Engine/Entities/Player/Classes/` - Warrior, Mage, Archer, Paladin, God, Nameless
  - Each class has unique stats, starting equipment, and leveling progression
  - Paladin: Tank class with high constitution and wisdom, starts with shield
- **Compendium System**: Automatically tracks discovered enemies/items when encountered
  - Enemies tracked on death via `$.SaveData.discovered_enemies[id]`
  - Items tracked on pickup/interaction via `$.SaveData.discovered_items[id]`

### Map & Dungeon Structure
- **Dungeon**: Grid of rooms (`Array<Array<String?>>`), rooms identified by name strings like `"room_2_3"`
- **Room persistence**: Each room saved individually to `Storage` by name, loaded on-demand
- **Room**: Contains `Map`, `_items`, `_enemies`, `_npcs` dictionaries keyed by `Point2D`
- **Map**: 2D array of `Tile` objects, tiles have `type` (enum: `WALL`, `PASSABLE`, `STAIRS`) and `content` (Entity?)
  - Sparse storage: Only non-empty tiles stored in `_tiles` array, `null` for empty/wall tiles
  - Sentinel pattern: `_null_tile` returned for out-of-bounds/missing tiles (treated as walls)
  - Key methods: `getTile(x, y)`, `setContent(pos, entity)`, `isPosFree(pos)`, `isInBound(pos)`
  - Content layer: Each tile can hold one entity reference (player, enemy, item, NPC)
- **Tile**: Minimal data structure with `type`, `x`, `y`, `content`, `player` flag
  - Types: `EMPTY`, `WALL`, `PASSABLE`, `STAIRS`
  - Content is transient - not saved (entities saved separately by Room)
- **Map data**: Stored in `$.Game.map` as 5-element tuples: `[room_name, connections, size, visited, flags]`
  - Flags: Array of `Point2D?` for special locations (stairs, merchant, boss, quest giver)

### Resource Management (Rez System)
- **Drawables**: `$.Rez.Drawables.LauncherIcon`, sprites, UI hints (defined in `resources/drawables/drawables.xml`)
- **Fonts**: `$.Rez.Fonts.small`, `Rez.Fonts.test` (defined in `resources/fonts/fonts.xml`)
- **Strings**: `$.Rez.Strings.AppName` (defined in `resources/strings/strings.xml`)
- Load resources: `WatchUi.loadResource($.Rez.Fonts.small)` or `new WatchUi.Bitmap({:rezId=>$.Rez.Drawables.Player})`
- Python helpers in `helpers/`: `split_images.py` (slice spritesheets), `create_font.py` (bitmap font generation)

### Save/Load Architecture
**Critical**: Save data is **nested and distributed**:
1. Game state stored in `SaveData` module, persisted to `Storage.setValue(chosen_save, data)`
2. Each **room saved individually** to Storage by key (e.g., `"room_2_3"`)
3. Player, EntityManager, Quests, Game all implement `save()` → `Dictionary` and `load(data)`
4. **Entity GUID system**: Entities persist via GUID, `EntityManager` maintains global `guid → entity` map
5. **Autosave**: Configurable via `Settings` (per-turn or timer-based in `DCGameView.mc`)
6. **Save on exit**: Optional setting, triggered in `DCGameDelegate.onBack()`

### Turn Execution Flow
**Critical**: The `Turn` class (`Engine/Maps/Turn.mc`) orchestrates ALL game logic each turn:

1. **Pre-checks** (`doTurn(direction)`):
   - Clear damage text from previous turn
   - Check `StepGate.consumeTurn()` - abort if insufficient steps
   - Calculate new position from direction (UP/DOWN/LEFT/RIGHT)

2. **Room transition checks**:
   - `checkIfNextRoom()`: If out of bounds, try `dungeon.getRoomInDirection()`
   - On room change: Load new room, reposition player at opposite edge, mark visited

3. **Movement validation**:
   - Check `map.isInBound(new_pos)`
   - Check tile type: `STAIRS` → trigger `goToNextDungeon()`, NPC → trigger interaction
   - Only `PASSABLE` tiles allow movement

4. **Player action resolution** (`resolvePlayerActions()`):
   - Energy check: Requires ≥100 energy, consumes 100 per turn
   - **Combat priority**: Check `MapUtil.getEnemyInRange()` based on weapon range/type
   - If enemy in range → `Battle.attackEnemy()`, handle death/loot, skip movement
   - If no combat → `interactWithItem()` (pickup/open chest), then `movePlayer()`

5. **Enemy action resolution** (`resolveEnemyActions()`):
   - Filter enemies by energy (≥100 required)
   - Sort by distance to player (closest acts first)
   - **Max 10 iterations** to prevent infinite loops
   - Per enemy: Try `doAction()` (special behavior), `attackNearbyPlayer()`, or `findNextMove()`
   - Movement: Use pathfinding, attack if adjacent to player, consume 100 energy

6. **Post-turn cleanup**:
   - `_player.onTurnDone()` / `room.onTurnDone()` - regenerate energy
   - Autosave if enabled
   - `WatchUi.requestUpdate()` to redraw screen
   - Schedule damage text removal (1 second timer)

**Key insight**: Combat happens BEFORE movement - player/enemies attack if in range, only moving if no valid target.

### Combat System
- **Battle module** (`Engine/Battles/Battle.mc`): `attackEnemy()`, `attackPlayer()` functions
- Damage = `attacker.getAttack() - defender.getDefense()` (clamped to min 1)
- Deaths trigger XP gain, loot drops, quest tracking
- Damage text displayed via `DCGameView.addDamageText(damage, pos)`
- **Elemental System** (`Engine/Util/ElementUtil.mc`):
  - Elements: FIRE, ICE, NONE (defined in `ItemEnums.mc`)
  - Weapons/Armor/Ammunition can have elemental properties
  - Elemental effects: FIRE = 30% damage over 3 turns, ICE = slow effect
  - Armor provides 25% resistance against matching element
  - `getWeaponElement()`, `getArmorElement()`, `getAmmunitionElement()` for element detection

### StepGate (Unique Feature)
**Real-world step counter integration**: Players must walk X steps to take a turn in-game
- `StepGate.consumeTurn()` checks if enough steps accumulated via `ActivityMonitor.getInfo().steps`
- Configurable in Settings: `steps_per_turn` (0 = disabled)
- Handles rollover (new day), banking steps, user notifications

### Inventory & Equipment System
- **Auto-equip ammunition**: Picking up ammunition of same type auto-stacks to equipped slot
  - `isSameAmmunition()` checks if picked-up ammo matches equipped ammo
  - Ammunition items (arrows, bolts) stack in AMMUNITION slot
- **Equipment slots**: HEAD, CHEST, BACK, LEGS, FEET, LEFT_HAND, RIGHT_HAND, ACCESSORY, AMMUNITION
- Bows/Staffs require matching ammunition (arrows/bolts) in AMMUNITION slot

### Compendium & Debug Systems
**Compendium** (`FrontEnd/GameMenu/Compendium/`):
- In-game encyclopedia tracking discovered enemies and items
- Access via Game Menu → Compendium
- Shows enemy stats (HP, ATK), item properties
- Uses `DCCompendiumDelegate` with ViewLoop for detailed views
- Persistence via `SaveData.discovered_enemies/items`

**Debug Menu** (`FrontEnd/GameMenu/DebugMenu/`) - **Annotated with `(:debug)`**:
- Enable in builds with debug flag
- Access via Game Menu → Debug (when enabled)
- Features:
  - Spawn enemies: Select any enemy type to spawn in current room
  - Spawn items: Add any item to inventory
  - Player stats: Modify attributes, level, gold, health
- Uses `DCDebugNumberPicker` for numeric input
- **Important**: Debug features only compile when `:debug` annotation is active

## Development Workflow

### Build & Run
- **VS Code Extension**: Use "Monkey C" extension commands from palette:
  - "Monkey C: Edit Application" - Edit manifest.xml
  - "Monkey C: Set Products by Product Category" - Add target devices
  - "Monkey C: Build for Device" - Compile
- **Manifest**: `manifest.xml` defines app metadata, `monkey.jungle` references it
- **Target devices**: Currently supports venu2, venu2s, venu2plus, venu3, venu3s, venu441mm, venu445mm
- Add more devices via product categories in manifest

### Code Conventions
- **Naming**: Classes = `PascalCase`, functions = `camelCase`, private vars = `_snake_case`
- **Imports**: Always import Toybox modules explicitly (`import Toybox.WatchUi;`)
- **Null safety**: Use type hints with `?` for nullable (`var x as Player?`)
- **Dictionary access**: Cast retrieved values (`var value = dict["key"] as Number`)
- **Module functions**: Always qualify with module name: `$.MathUtil.random()`, `$.Game.getPlayer()`
- **Random probability**: Use `MathUtil.isRandomPercent(chance)` for percentage-based randomness
  - Returns true `chance`% of the time (e.g., `isRandomPercent(50)` = 50% chance)
  - Used extensively for spawn rates, loot drops, special events

### Common Patterns
1. **View initialization**: Pass dependencies in constructor, call `View.initialize()` first
2. **Delegate actions**: Override `onTap()`, `onMenu()`, `onBack()`, `onSelect()` (Menu2)
3. **Switching views**: `WatchUi.switchToView(view, delegate, transition)` replaces entire stack
4. **Pushing views**: `WatchUi.pushView(view, delegate, transition)` adds to stack (back button pops)
5. **Progress bars**: Use `WatchUi.ProgressBar` with delegate callbacks for async dungeon generation
6. **ViewLoop**: For swipeable multi-page views (e.g., player details), use `WatchUi.ViewLoop` + factory

### Multi-Device UI Patterns
**Critical**: Use dynamic screen sizing for device compatibility:

1. **Screen dimensions** (`Engine/Util/Constants.mc`):
   - `Constants.SCREEN_WIDTH` = `System.getDeviceSettings().screenWidth`
   - `Constants.SCREEN_HEIGHT` = `System.getDeviceSettings().screenHeight`
   - Never hardcode pixel values - calculate relative to screen size

2. **Positioning patterns**:
   ```monkey-c
   // Relative positioning (preferred)
## Debugging Gotchas
- **GUID collisions**: Entities not registered? Check `register()` called in constructor
- **Room not saving**: Verify `Storage.setValue(room_name, room.save())` called after modifications
- **View not updating**: Call `WatchUi.requestUpdate()` after state changes
- **Module state lost**: Modules persist across views - explicitly `init()` when needed
- **Steps not working**: Check `StepGate.init()` called, Settings loaded, ActivityMonitor permission in manifest
- **UI elements misaligned**: Hardcoded coordinates break on different devices - use `Constants.SCREEN_WIDTH/HEIGHT`
- **Tile rendering issues**: Room generation assumes 16x16 tiles, calculate screen tiles via `MapUtil.getNumTilesForScreensize()`
   ```

3. **Tile-based rendering**:
   - `tile_width` and `tile_height` stored in `DungeonCrawlerApp` (default 16x16)
   - Screen tiles: `Math.ceil(SCREEN_WIDTH/tile_width).toNumber()`
   - Room generation centers content: `middle_of_screen = [floor(screen_size_x/2), floor(screen_size_y/2)]`

4. **System icons/hints** (automatically position per device):
   ```xml
   <!-- In drawables.xml -->
   <bitmap id="rightTop" personality="
       system_icon_light__hint_button_right_top
       system_loc__hint_button_right_top" />
   ```
   - Use `personality` attribute for device-specific icons
   - System hints auto-position: `rightTop`, `rightLow`, `actionMenu`

5. **Dynamic text sizing**:
   ```monkey-c
   var text_dimensions = dc.getTextDimensions(text, font);
   var box_width = text_dimensions[0] + padding * 2;
   ```
   - Always measure text before drawing boxes
   - Use `dc.getWidth()` / `dc.getHeight()` for drawable context size

6. **Tap zones** (calculate from button positions):
   ```monkey-c
   var button_pos = [(SCREEN_WIDTH/2), (SCREEN_HEIGHT * 75/360)];
   var text_dims = dc.getTextDimensions("New Game", font);
   var x1 = x - text_dims[0]/2 - padding;
   var x2 = x + text_dims[0]/2 + padding;
   ```

### Testing Considerations
- Test on actual device or Garmin simulator (Monkey C is not standard embedded C)
- Memory limits are strict (watch hardware), avoid large allocations
- Use `Toybox.System.println()` for debugging (logs to simulator console)

## Key Integration Points
- **Storage API**: `Storage.setValue(key, value)` / `Storage.getValue(key)` - persists across app restarts
- **ActivityMonitor**: `ActivityMonitor.getInfo()` provides steps, heart rate, etc.
- **Timers**: `Timer.Timer()` → `timer.start(callback, interval_ms, repeat)`
- **Graphics**: `dc.drawBitmap()`, `dc.drawText()` in `View.onUpdate(dc)` - manual rendering

## Debugging Gotchas
- **GUID collisions**: Entities not registered? Check `register()` called in constructor
- **Room not saving**: Verify `Storage.setValue(room_name, room.save())` called after modifications
- **View not updating**: Call `WatchUi.requestUpdate()` after state changes
- **Module state lost**: Modules persist across views - explicitly `init()` when needed
## When Adding Features
1. **New entity type**: Extend `Entity`, implement `save()`/`load()`, call `register()`, add to factory
2. **New screen**: Create View/Delegate pair, add entry point in `DungeonCrawlerApp.mc`
3. **New game mechanic**: Add to `Turn.doTurn()` or battle logic, ensure save/load support
4. **New resource**: Add to XML in `resources/`, reference via `$.Rez.*`
5. **New setting**: Add to `Settings` module, create UI in `source/FrontEnd/Settings/`
6. **New player class**: Extend `Player` in `Classes/`, set id, stats, starting equipment, add to `Players.mc` factory
7. **New enemy type**: Track in Compendium by adding `$.SaveData.discovered_enemies[id] = true` on death
8. **Elemental weapons**: Add element type in constructor, implement in `ElementUtil.getWeaponElement()`
9. **New UI element**: Use `Constants.SCREEN_WIDTH/HEIGHT` for positioning, never hardcode coordinates
10. **System icons**: Define with `personality` attribute in `drawables.xml` for device-specific auto-positioningrs.mc` factory
7. **New enemy type**: Track in Compendium by adding `$.SaveData.discovered_enemies[id] = true` on death
8. **Elemental weapons**: Add element type in constructor, implement in `ElementUtil.getWeaponElement()`

## Files to Start With
- **Architecture**: `source/Engine/Game.mc`, `source/DungeonCrawlerApp.mc`
- **Game loop**: `source/Engine/Maps/Turn.mc`, `source/FrontEnd/Game/DCGameDelegate.mc`
- **Entity examples**: `source/Engine/Entities/Player/Player.mc`, `source/Engine/Enemies/Enemy.mc`
- **Player classes**: `source/Engine/Entities/Player/Classes/` (Warrior, Mage, Archer, Paladin)
- **Utilities**: `source/Engine/Util/` (MathUtil, SimUtil, SaveData, Constants, ElementUtil)
- **Compendium**: `source/FrontEnd/GameMenu/Compendium/DCCompendiumDelegate.mc`
- **Debug tools**: `source/FrontEnd/GameMenu/DebugMenu/DCDebugMenuDelegate.mc`

## Recent Balancing Changes (Branch: balancing)
- **Turn energy reduced**: Players/enemies consume less energy per action for faster gameplay
- **Spawn rates adjusted**: Fewer enemies per room, increased merchant/quest giver spawn chance
- **Loot improvements**: Archers get more arrows from killed monsters, chest spawn rates increased
- **Auto-equip**: Same ammunition type auto-stacks when picked up
- **Bug fixes**: Necromancer duplication fix, enemy child spawning fixes, Zombie collision fixes
