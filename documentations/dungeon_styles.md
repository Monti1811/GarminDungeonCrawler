# Dungeon Styles

Übersicht aller Dungeon-Styles mit Tile-Empfehlungen aus `font/tile_*.png`.

## Bestehende Styles

| Style | Farbe | Beschreibung |
|-------|-------|--------------|
| `DUNGEONSTYLE_NORMAL` | Grau | Standard-Dungeon |
| `DUNGEONSTYLE_FIRE` | Rot | Feuer-Temperatur |
| `DUNGEONSTYLE_ICE` | Cyan | Eis-Kristalle |
| `DUNGEONSTYLE_BOSS` | Lila | Boss-Kampf |

## Style-Empfehlungen

### DUNGEONSTYLE_POISON (Grün)
**Theme:** Sumpf, Gift, verfallene Ruinen

| Typ | Tiles | Begründung |
|-----|-------|------------|
| Boden | `tile_40` (Wavy) | Wellige Sumpf-Textur |
| Wand | `tile_180` (Broken) | Verfallene, zerbrochene Struktur |
| Deko | `tile_50` (Dots) | Gift-Tropfen |

**Farben:** Boden `0x2E8B57`, Wand `0x006400`, Akzent `0x9ACD32`

---

### DUNGEONSTYLE_SHADOW (Dunkel-Lila)
**Theme:** Schatten, Dunkelheit, geheimnisvolle Kammern

| Typ | Tiles | Begründung |
|-----|-------|------------|
| Boden | `tile_170` (Sparse dots) | Dunkler Raum mit wenigen Lichtpunkten |
| Wand | `tile_145` (Maze) | Labyrinthische Schatten-Struktur |
| Deko | `tile_23` (Corner dots) | Geheimnisvolle Ecken |

**Farben:** Boden `0x2F1F4F`, Wand `0x1A0A30`, Akzent `0x8B00FF`

---

### DUNGEONSTYLE_NATURE (Grün/Braun)
**Theme:** Wald, Höhle, natürliche Formationen

| Typ | Tiles | Begründung |
|-----|-------|------------|
| Boden | `tile_165` (Stone/cobble) | Natürlicher Stein |
| Wand | `tile_125` (Brick) | Geordnete Stein-Struktur |
| Deko | `tile_55` (4x diagonal checker) | Kristalline Ablagerungen |

**Farben:** Boden `0x8B4513`, Wand `0x228B22`, Akzent `0x90EE90`

---

### DUNGEONSTYLE_SAND (Gelb/Braun)
**Theme:** Wüste, Tempel, vergrabene Schätze

| Typ | Tiles | Begründung |
|-----|-------|------------|
| Boden | `tile_195` (Organic/snow) | Sandkörner-Textur |
| Wand | `tile_5` (Brick) | Klassische Backstein-Tempel-Wand |
| Deko | `tile_140` (Diagonal dots) | Sandsturm-Effekt |

**Farben:** Boden `0xF4A460`, Wand `0xD2691E`, Akzent `0xFFD700`

---

### DUNGEONSTYLE_WATER (Blau)
**Theme:** Unterwasser, Aqueduct, versunkene Städte

| Typ | Tiles | Begründung |
|-----|-------|------------|
| Boden | `tile_36-39` (Wavy variants) | Wasser-Wellen-Muster |
| Wand | `tile_60` (Interlocking L) | Wasserdichte Struktur |
| Deko | `tile_100` (Circles) | Wasserblasen |

**Farben:** Boden `0x1E90FF`, Wand `0x000080`, Akzent `0x00FFFF`

---

### DUNGEONSTYLE_LIGHTNING (Gelb/Weiß)
**Theme:** Sturm, Fabrik, Energie-Anlagen

| Typ | Tiles | Begründung |
|-----|-------|------------|
| Boden | `tile_21` (Grid) | Technisches Grid |
| Wand | `tile_65` (Cross+circles) | Energie-Kreuzungen |
| Deko | `tile_18` (Diamond cross) | Blitz-Symbole |

**Farben:** Boden `0xB8860B`, Wand `0x4A4A4A`, Akzent `0xFFFF00`

---

### DUNGEONSTYLE_UNDEAD (Grau)
**Theme:** Friedhof, Katakombe,-grab

| Typ | Tiles | Begründung |
|-----|-------|------------|
| Boden | `tile_185` (Film strip) | Grab-Platten |
| Wand | `tile_190` (Brick) | Mauerwerk der Katakombe |
| Deko | `tile_245` (Corner) | Grab-Ecken |

**Farben:** Boden `0x696969`, Wand `0x2F2F2F`, Akzent `0xC0C0C0`

---

### DUNGEONSTYLE_CRYSTAL (Violett/Blau)
**Theme:** Kristallhöhle, magische Ablagerungen

| Typ | Tiles | Begründung |
|-----|-------|------------|
| Boden | `tile_115` (Diamond) | Kristall-Struktur |
| Wand | `tile_135` (Diamond pattern) | Kristalline Wände |
| Deko | `tile_75` (Diagonal brick) | Kristall-Zacken |

**Farben:** Boden `0x9370DB`, Wand `0x4B0082`, Akzent `0xE6E6FA`

---

## Tile-Übersicht

### Boden-Tiles (geeignet für Fade-Flächen)
| Tile | Muster | Passt zu |
|------|--------|----------|
| `tile_0-1` | Horizontal stripes | Normal, Industrie |
| `tile_5` | Brick | Normal, Feuer, Undead |
| `tile_12-16` | Diagonal lines | Eis, Kristall |
| `tile_36-39` | Wavy variants | Wasser, Poison |
| `tile_75` | Diagonal brick | Kristall, Nature |
| `tile_125` | Brick pattern | Normal, Sand |
| `tile_155` | Brick (light) | Sand, Nature |
| `tile_165` | Stone/cobble | Nature, Normal |
| `tile_185` | Film strip | Undead, Grab |
| `tile_195` | Organic/snow | Sand, Poison |

### Wand-Tiles (geeignet für Wände)
| Tile | Muster | Passt zu |
|------|--------|----------|
| `tile_4` | Vertical bars | Normal, Industrie |
| `tile_6-7` | Diagonal bars | Feuer, Lightning |
| `tile_60` | Interlocking L | Wasser, Kristall |
| `tile_65` | Cross+circles | Lightning, Kristall |
| `tile_145` | Maze-like | Shadow, Kristall |
| `tile_190` | Brick | Undead, Normal |

### Deko-Tiles (geeignet für Highlights)
| Tile | Muster | Passt zu |
|------|--------|----------|
| `tile_18` | Diamond cross | Lightning, Kristall |
| `tile_23` | Corner dots | Shadow, Geheimnis |
| `tile_50` | Four dots | Poison, Wasser |
| `tile_100` | Circles | Wasser, Blasen |
| `tile_115` | Diamond | Kristall, Nature |
| `tile_140` | Diagonal dots | Sand, Sandsturm |
| `tile_245` | Corner | Undead, Grab |

## Farb-Paletten

| Style | Boden | Wand | Akzent |
|-------|-------|------|--------|
| NORMAL | `0x808080` | `0x404040` | `0xC0C0C0` |
| FIRE | `0x8B0000` | `0x4A0000` | `0xFF4500` |
| ICE | `0x00CED1` | `0x004040` | `0x66FFFF` |
| BOSS | `0x800080` | `0x400040` | `0xCC66CC` |
| POISON | `0x2E8B57` | `0x006400` | `0x9ACD32` |
| SHADOW | `0x2F1F4F` | `0x1A0A30` | `0x8B00FF` |
| NATURE | `0x8B4513` | `0x228B22` | `0x90EE90` |
| SAND | `0xF4A460` | `0xD2691E` | `0xFFD700` |
| WATER | `0x1E90FF` | `0x000080` | `0x00FFFF` |
| LIGHTNING | `0xB8860B` | `0x4A4A4A` | `0xFFFF00` |
| UNDEAD | `0x696969` | `0x2F2F2F` | `0xC0C0C0` |
| CRYSTAL | `0x9370DB` | `0x4B0082` | `0xE6E6FA` |

## Implementierung

Jeder neue Style benötigt:
1. Enum-Eintrag in `Dungeon.mc` (`DungeonStyle`)
2. Translation-Dictionary in `Map.mc` (`getDungeonStyleTranslation`)
3. Farben in `RoomDrawable.mc` (`getCharColor`)
4. Gewichtung in `Dungeon.mc` (Dungeon-Generierung)
