# Dungeon Styles

Overview of all 13 dungeon styles currently implemented in the game.

Each style defines three color layers: **wall** (dark), **floor** (medium), and **stairs/accent** (bright). The style is randomly selected when a dungeon is created.

## Style Probabilities

| Style | Weight | Chance |
|-------|--------|--------|
| Normal | 50 | 47.6% |
| Fire | 5 | 4.8% |
| Ice | 5 | 4.8% |
| Poison | 5 | 4.8% |
| Shadow | 5 | 4.8% |
| Nature | 5 | 4.8% |
| Lava | 5 | 4.8% |
| Sand | 5 | 4.8% |
| Dark | 5 | 4.8% |
| Crystal | 5 | 4.8% |
| Blood | 5 | 4.8% |
| Water | 5 | 4.8% |

Boss style is not included in the random pool (forced for boss dungeons).

## Implemented Styles

### Normal
**The classic dungeon look.** Gray stone walls on black background. Clean, readable, the baseline all other styles deviate from.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Gray | `0x444444` |
| Floor | Dim gray | `0x666666` |
| Stairs | Yellow | `0xFFFF00` |
| Background | Black | `0x000000` |

---

### Fire
**Burned corridors and smoldering stone.** Deep crimson walls, dark red background. Floor tiles glow orange like cooling embers. Stairs burn bright orange-red.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Dark red | `0x8B0000` |
| Floor | Ember orange | `0xCC6600` |
| Stairs | Orange-red | `0xFF4500` |
| Background | Near-black red | `0x7e0306` |

---

### Ice
**Frozen caverns with crystalline walls.** Cyan walls on pure black. Floor tiles shimmer bright cyan-white. Stairs glow deep sky blue. High contrast, very readable.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Cyan | `0x00CED1` |
| Floor | Bright cyan | `0x66FFFF` |
| Stairs | Deep sky blue | `0x00BFFF` |
| Background | Black | `0x000000` |

---

### Boss
**The boss arena.** Purple walls on black, pink accent stairs. Distinct and menacing, signals danger.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Purple | `0x800080` |
| Floor | Muted pink | `0xCC66CC` |
| Stairs | Hot pink | `0xFF69B4` |
| Background | Black | `0x000000` |

---

### Poison
**Toxic swamps and corrupted ruins.** Dark green walls, bright lime-green floor. Stairs pop with yellow-green. The green-on-black feels sickly and dangerous.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Dark green | `0x006400` |
| Floor | Lime green | `0x9ACD32` |
| Stairs | Yellow-green | `0xADFF2F` |
| Background | Black | `0x000000` |

---

### Shadow
**Twilight corridors and forgotten passages.** Very dark gray walls on near-black background, medium violet floor. Low contrast, moody. Stairs glow soft plum.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Dark gray | `0x3A3A3A` |
| Floor | Medium slate blue | `0x7B68EE` |
| Stairs | Plum | `0xDDA0DD` |
| Background | Near-black | `0x1A1A1A` |

---

### Nature
**Overgrown ruins and forest dungeons.** Very dark green walls and background. Floor tiles are a muted olive green. Stairs gleam gold, like sunlight filtering through canopy.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Dark forest | `0x2E5A2E` |
| Floor | Olive green | `0x4A8B4A` |
| Stairs | Gold | `0xFFD700` |
| Background | Deep forest | `0x0D1F0D` |

---

### Lava
**Molten rock and volcanic chambers.** Darkest red walls on near-black. Floor tiles glow like fresh lava. Stairs blaze bright yellow, the hottest point.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Darkest red | `0x5A1A00` |
| Floor | Lava orange | `0xCC4400` |
| Stairs | Bright yellow | `0xFFFF00` |
| Background | Near-black red | `0x1A0000` |

---

### Sand
**Desert temples and buried ruins.** Muted brown walls on dark brown background. Floor tiles are warm tan. Stairs shine gold, like buried treasure.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Muted brown | `0x6B5B3A` |
| Floor | Warm tan | `0xD2B48C` |
| Stairs | Gold | `0xFFD700` |
| Background | Dark brown | `0x2A2010` |

---

### Dark
**The abyss.** Nearly invisible walls on pitch black. Floor tiles are barely visible dark gray. Stairs are pure white -- the only light in the darkness. Extreme low contrast, atmospheric.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Near-black | `0x1A1A1A` |
| Floor | Dark gray | `0x333333` |
| Stairs | White | `0xFFFFFF` |
| Background | Pitch black | `0x0A0A0A` |

---

### Crystal
**Underground crystal caverns.** Teal walls on dark blue-black. Floor tiles shimmer light cyan. Stairs glow bright cyan. Cool tones, magical feel.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Teal | `0x2A5A6A` |
| Floor | Light cyan | `0x88CCDD` |
| Stairs | Bright cyan | `0x00FFFF` |
| Background | Dark blue-black | `0x0D1F2A` |

---

### Blood
**Crimson halls and slaughterhouse chambers.** Deep blood-red walls on near-black. Floor tiles are dark red. Stairs glow bright red. Intense, visceral.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Blood red | `0x5A0000` |
| Floor | Dark red | `0x8B0000` |
| Stairs | Bright red | `0xFF1A1A` |
| Background | Near-black red | `0x1A0000` |

---

### Water
**Sunken corridors and flooded chambers.** Deep blue walls on near-black. Floor tiles are medium blue. Stairs glow cyan like bioluminescence. Calm but eerie.

| Element | Color | Hex |
|---------|-------|-----|
| Wall | Deep blue | `0x002A5A` |
| Floor | Medium blue | `0x4488CC` |
| Stairs | Cyan | `0x00FFFF` |
| Background | Near-black blue | `0x000D1F` |

---

## Tile Characters

Each style maps tile types to specific characters in the dungeon bitmap font:

| Style | Floor Char | Empty Char |
|-------|-----------|------------|
| Normal | 70 | 36 |
| Fire | 71 | 36 |
| Ice | 72 | 35 |
| Boss | 73 | 36 |
| Poison | 74 | 36 |
| Shadow | 75 | 36 |
| Nature | 76 | 36 |
| Lava | 77 | 36 |
| Sand | 78 | 36 |
| Dark | 79 | 36 |
| Crystal | 80 | 36 |
| Blood | 81 | 36 |
| Water | 82 | 36 |

Wall variants (chars 42-62) use the wall color from the style's palette.

## Adding a New Style

1. Add enum entry in `Dungeon.mc` (`DungeonStyle`)
2. Add translation dictionary in `Map.mc` (`getDungeonStyleTranslation`)
3. Add colors in `RoomDrawable.mc` (`getMapColors`, `getCharColor`)
4. Add weight in `Dungeon.mc` (dungeon generation)
5. Generate a new floor tile character in the bitmap font (char 83+)
