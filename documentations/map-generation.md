# Map Generation

Dungeon and room generation, wall variants, and visual styles.

## Dungeon Generation

### Grid Size

Dungeon grid dimensions are randomized per depth:
- Size increases with depth (more rooms to explore)
- Boss dungeons (every 25th depth, 50% chance) use different sizing

### Room Placement

Rooms are placed in a grid pattern. Each room has:
- Position in the grid (i, j)
- Connections to adjacent rooms (N/S/E/W)
- Special flags: stairs, merchant, quest-giver

### Connection Algorithm

`Dungeon.connectRoomsRandomly()` creates bidirectional connections between adjacent rooms. Every room must be reachable from every other room.

### Special Room Placement

After room generation:
- **Stairs** -- placed in a room far from the starting position
- **Merchant** -- placed in a random room
- **Quest Giver** -- placed in a random room

## Room Generation Pipeline

Each room goes through a 4-phase pipeline, processed one room per timer tick:

### Phase 0a: Shape Creation

`Main.createRoomShapeForDungeon()`:
1. Pick random `RoomShape` from enum
2. Calculate random dimensions within min/max bounds
3. Create `Map` with `Map.createRoomShape()`
4. Add interior islands with `Map.addIslands()`

### Phase 0b: Content Population

`Main.createRoomContentForDungeon()`:
1. Spawn enemies via weighted budget system
2. Spawn items via weighted random selection
3. Add tunnel connections to adjacent rooms

### Phase 1: Wall Cleanup

`Main.cleanupRoomForDungeon()`:
- `Map.addWallsAroundPassable()` converts EMPTY tiles adjacent to PASSABLE into WALLs
- Algorithm iterates over PASSABLE tiles and checks 8 neighbors

### Phase 2: Save

`Main.saveRoomForDungeon()`:
- Room serialized to dictionary
- Saved to Garmin `Storage`
- Room metadata registered in `Game.map`
- Room memory freed

## Room Shapes

`RoomShape` enum defines 5 room layouts:

### Rectangle
Simple rectangular room. Most common shape.

### L-Shape
Two overlapping rectangles forming an L. Created by:
- Horizontal bar (top half, full width)
- Vertical bar (right side, extending down)
- Overlap by 1 row for connectivity

### T-Shape
Wide top bar with narrow vertical stem. Created by:
- Top horizontal bar (full width, 1/3 height)
- Centered vertical stem (1/3 width, remaining height)

### Plus
Cross shape. Created by:
- Horizontal bar (full width, 1/3 height)
- Vertical bar (full height, 1/3 width)
- Overlap in center

### Rounded
Rectangle with rounded corners. Created by:
- Standard rectangle fill
- Corner tiles removed based on corner radius

## Interior Islands

`Map.addIslands()` places wall blocks inside rooms for tactical cover.

**Island count by room area:**
| Area | Max Islands |
|------|-------------|
| > 100 | 4 |
| > 64 | 3 |
| > 36 | 2 |
| > 20 | 1 |
| <= 20 | 0 |

Islands are placed randomly within the room interior, avoiding:
- Room edges (within 1 tile of walls)
- Existing PASSABLE tiles that would block paths
- Positions adjacent to other islands

## Wall Variant System

### How It Works

`Map.getWallVariant(x, y)` computes the visual variant of a WALL tile based on its 8 neighbors. This is done at render time, not stored.

### Neighbor Analysis

For each WALL tile, check which neighbors are PASSABLE:
- **Horizontal** -- PASSABLE to left and/or right
- **Vertical** -- PASSABLE above and/or below
- **Diagonal** -- PASSABLE in diagonal directions

### Wall Variants (21 types)

| Char | Variant | Description |
|------|---------|-------------|
| 42 | `wall_h_top` | Wall above, floor below |
| 43 | `wall_h_bottom` | Wall below, floor above |
| 44 | `wall_h_mid` | Wall middle, floor above+below |
| 45 | `wall_v_left` | Wall left, floor right |
| 46 | `wall_v_right` | Wall right, floor left |
| 47 | `wall_v_mid` | Wall middle, floor left+right |
| 50 | `outer_tl` | Outer corner top-left |
| 51 | `outer_tr` | Outer corner top-right |
| 52 | `outer_bl` | Outer corner bottom-left |
| 53 | `outer_br` | Outer corner bottom-right |
| 54 | `inner_tl` | Inner corner top-left |
| 55 | `inner_tr` | Inner corner top-right |
| 56 | `inner_bl` | Inner corner bottom-left |
| 57 | `inner_br` | Inner corner bottom-right |
| 58 | `t_top` | T-piece, open top |
| 59 | `t_bottom` | T-piece, open bottom |
| 60 | `t_left` | T-piece, open left |
| 61 | `t_right` | T-piece, open right |
| 62 | `cross` | Crossroads, all open |

### Bitmap Font Mapping

Wall variants map to character codes 42-62 in the dungeon bitmap font. The font is generated via BMFont from individual tile PNGs.

## Tunnel System

Tunnels connect adjacent rooms through walls.

### Tunnel Shapes

| Shape | Description |
|-------|-------------|
| `STRAIGHT` | Direct horizontal or vertical passage |
| `L_SHAPED` | L-shaped turn connecting two directions |
| `ZIGZAG` | Winding path for longer distances |

### Tunnel Placement

- Tunnels are carved through WALL tiles between connected rooms
- Openings created by `Room.addConnection()` in the wall tiles
- Tunnel paths computed by `Map.addTunnel()`

## Dungeon Styles

13 visual themes with unique color palettes. See [dungeon-styles.md](dungeon-styles.md) for full details.

### Color System

Each style defines:
- **Floor color** -- PASSABLE tile background
- **Wall color** -- WALL tile background
- **Accent color** -- highlights, items, UI elements

### Style Selection

Styles are randomly chosen at dungeon creation:
- 50% Normal (gray)
- 5% each: Fire, Ice, Poison, Shadow, Nature, Lava, Sand, Dark, Crystal, Blood, Water

### Implementation

Each style requires:
1. `DungeonStyle` enum entry in `Dungeon.mc`
2. Translation dictionary in `Map.mc` (`getDungeonStyleTranslation`)
3. Color definitions in `RoomDrawable.mc` (`getCharColor`)
4. Weight in `Dungeon.mc` (dungeon generation)

## Rendering

### RoomDrawable

`RoomDrawable` is a `WatchUi.Drawable` that renders the room tile-by-tile:

1. Get map string from `Map.getMapString()`
2. For each character in string:
   - Look up character code
   - Determine tile type (wall, floor, empty)
   - Get color from dungeon style
   - Draw character at grid position

### Dungeon Font

The dungeon tiles are rendered as a bitmap font:
- Characters 32-62 map to tile variants
- Font generated via BMFont from individual tile PNGs
- Two fonts: `small` (text) and `dungeon` (tiles)
