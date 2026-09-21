# Agents

## Build

```bash
& "java.exe" "-Xms1g" "-Dfile.encoding=UTF-8" "-Dapple.awt.UIElement=true" "-jar" "c:\Users\Timon\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin\monkeybrains.jar" "-o" "bin\DungeonCrawler.prg" "-f" "f:\Code\Garmin\DungeonCrawler\monkey.jungle" "-y" "f:\Code\Garmin\developer_key" "-d" "venu2s_sim" "-w"
```

Working directory: `F:/Code/Garmin/DungeonCrawler`

## Font Generation (Dungeon Tiles)

Die Dungeon-Tiles werden als Bitmap Font generiert. Prozess:

1. **Einzeln-Tiles** als PNG in `font/tiles/walls/` ablegen
2. **`font/dungeon_font.bmfc`** aktualisieren:
   - `chars=32-62` (31 chars total)
   - `icon=` Einträge für jedes Tile hinzufügen: `icon="datei.png",charID,0,0,0`
3. **BMFont ausführen** (WICHTIG: `.exe` nutzen, nicht `.com`):
   ```bash
   & "F:\Code\Garmin\bmfont64.exe" -c "F:\Code\Garmin\DungeonCrawler\font\dungeon_font.bmfc" -o "F:\Code\Garmin\DungeonCrawler\font\test2.fnt"
   ```
4. **Font-Dateien kopieren** (WICHTIG! Sonst wird er nicht genutzt):
   ```bash
   Copy-Item "font\test2.fnt" "resources\fonts\test2.fnt" -Force
   Copy-Item "font\test2_0.png" "resources\fonts\test2_0.png" -Force
   ```
5. Ausgabe: `font/test2.fnt` + `font/test2_0.png` (dann nach `resources/fonts/` kopieren)

**WICHTIG:** `test2_0.png` wird NICHT automatisch kopiert! Immer beide Dateien kopieren.

**Char-Zuordnung:**

- 32-41: Bestehende Tiles (EMPTY, WALL, PASSABLE, STAIRS etc.)
- 42-44: Horizontale Wände
  - 42=`wall_h_top` (Wand oben, Boden unten)
  - 43=`wall_h_bottom` (Wand unten, Boden oben)
  - 44=`wall_h_mid` (Wand mittig, Boden oben+unten)
- 45-47: Vertikale Wände
  - 45=`wall_v_left` (Wand links, Boden rechts)
  - 46=`wall_v_right` (Wand rechts, Boden links)
  - 47=`wall_v_mid` (Wand mittig, Boden links+rechts)
- 50-53: Außen-Ecken
  - 50=`outer_tl` (oben+links)
  - 51=`outer_tr` (oben+rechts)
  - 52=`outer_bl` (unten+links)
  - 53=`outer_br` (unten+rechts)
- 54-57: Innen-Ecken
  - 54=`inner_tl` (oben+links)
  - 55=`inner_tr` (oben+rechts)
  - 56=`inner_bl` (unten+links)
  - 57=`inner_br` (unten+rechts)
- 58-61: T-Stücke
  - 58=`t_top` (oben offen)
  - 59=`t_bottom` (unten offen)
  - 60=`t_left` (links offen)
  - 61=`t_right` (rechts offen)
- 62: Kreuzung (alle offen)

**Wand-Varianten werden zur Laufzeit berechnet** in `Map.getWallVariant(x,y)` basierend auf Nachbarschaft.

## Drawables

Nicht mehr referenzierte Bitmap-Einträge in `drawables.xml` werden **auskommentiert**, nicht gelöscht. So bleibt die Historie erhalten und Bitmaps können bei Bedarf wieder aktiviert werden.

```xml
<!-- <bitmap id="unusedBitmap" filename="items/unused.png" packingFormat="png" /> -->
```

Prüfung mit `monkeyc_analyze_drawable_usage` — 0 Unused-Einträge als Ziel.

Rechteckige Screen-Varianten werden in `resources-rectangle/drawables/drawables.xml` als Override definiert (gleiche ID, anderes Filename).

## Watchdog / Connect IQ Laufzeit-Beschränkungen

Der Garmin-Watchdog ist **aufruf-basiert**, nicht zeitbasiert. Es gibt eine bestimmte maximale Anzahl von Funktionsaufrufen pro Zeitspanne.

**Zeitspanne:** Zwischen zwei User-Aktionen (z.B. zwischen `onTimer()`-Ticks). Wenn `onTimer()` dem User Kontrolle zurückgibt (z.B. durch `Ui.requestUpdate()`), wird der Watchdog-Zähler zurückgesetzt.

**Wichtig:** Jeder einzelne `onTimer()`-Tick muss innerhalb der Aufruf-Limits bleiben. Wenn zu viele Funktionen in einem Tick aufgerufen werden (z.B. durch verschachtelte Loops oder Allokationen), löst der Watchdog einen Reset aus.

**Optimierungsstrategien:**

- Loops reduzieren (max-Tries reduzieren, Innere Loops vermeiden)
- Array-Allokationen vermeiden (direkte `setTypeXY()` statt `[x,y]` Arrays)
- Einmalige Berechnungen statt wiederholter Aufrufe (z.B. Gewichte live berechnen statt cached)
- Timer-Phasen aufteilen (z.B. Map-Generierung in Phase 0a, Gegner/Items in Phase 0b)

## Font Generation (Dungeon Tiles)

Die Dungeon-Tiles werden als Bitmap Font generiert. Prozess:

1. **Einzeln-Tiles** als PNG in `font/tiles/walls/` ablegen
2. **`font/dungeon_font.bmfc`** aktualisieren:
   - `chars=32-62` (31 chars total)
   - `icon=` Einträge für jedes Tile hinzufügen: `icon="datei.png",charID,0,0,0`
3. **BMFont ausführen** (WICHTIG: `.exe` nutzen, nicht `.com`):
   ```bash
   & "F:\Code\Garmin\bmfont64.exe" -c "F:\Code\Garmin\DungeonCrawler\font\dungeon_font.bmfc" -o "F:\Code\Garmin\DungeonCrawler\font\test2.fnt"
   ```
4. **Font-Dateien kopieren** (WICHTIG! Sonst wird er nicht genutzt):
   ```bash
   Copy-Item "font\test2.fnt" "resources\fonts\test2.fnt" -Force
   Copy-Item "font\test2_0.png" "resources\fonts\test2_0.png" -Force
   ```
5. Ausgabe: `font/test2.fnt` + `font/test2_0.png` (dann nach `resources/fonts/` kopieren)

**WICHTIG:** `test2_0.png` wird NICHT automatisch kopiert! Immer beide Dateien kopieren.

**Char-Zuordnung:**

- 32-41: Bestehende Tiles (EMPTY, WALL, PASSABLE, STAIRS etc.)
- 42-44: Horizontale Wände
  - 42=`wall_h_top` (Wand oben, Boden unten)
  - 43=`wall_h_bottom` (Wand unten, Boden oben)
  - 44=`wall_h_mid` (Wand mittig, Boden oben+unten)
- 45-47: Vertikale Wände
  - 45=`wall_v_left` (Wand links, Boden rechts)
  - 46=`wall_v_right` (Wand rechts, Boden links)
  - 47=`wall_v_mid` (Wand mittig, Boden links+rechts)
- 50-53: Außen-Ecken
  - 50=`outer_tl` (oben+links)
  - 51=`outer_tr` (oben+rechts)
  - 52=`outer_bl` (unten+links)
  - 53=`outer_br` (unten+rechts)
- 54-57: Innen-Ecken
  - 54=`inner_tl` (oben+links)
  - 55=`inner_tr` (oben+rechts)
  - 56=`inner_bl` (unten+links)
  - 57=`inner_br` (unten+rechts)
- 58-61: T-Stücke
  - 58=`t_top` (oben offen)
  - 59=`t_bottom` (unten offen)
  - 60=`t_left` (links offen)
  - 61=`t_right` (rechts offen)
- 62: Kreuzung (alle offen)

**Wand-Varianten werden zur Laufzeit berechnet** in `Map.getWallVariant(x,y)` basierend auf Nachbarschaft.

## Unit Tests

Tests ausführen mit `run_tests.ps1` (kein offenes CMD-Fenster):

```bash
& "F:\Code\Garmin\DungeonCrawler\run_tests.ps1"                              # alle Tests
& "F:\Code\Garmin\DungeonCrawler\run_tests.ps1" "debugPrintRoomMap"          # einzelner Test
```

Das Script:

1. Kompiliert mit `-t` (Test-Modus)
2. Startet Simulator mit `venu2s` (NICHT `venu2s_sim`)
3. Führt `monkeydo` (Java direkt) mit `/t` aus
4. Beendet Simulator

Wichtig: Simulator-Device muss `venu2s` sein, `venu2s_sim` funktioniert nicht mit `monkeydo`.

Manuell (ohne Script):

```bash
# Kompilieren
& "java.exe" "-Xms1g" "-Dfile.encoding=UTF-8" "-Dapple.awt.UIElement=true" "-jar" "...\monkeybrains.jar" "-o" "bin\DungeonCrawler.prg" "-f" "monkey.jungle" "-y" "f:\Code\Garmin\developer_key" "-d" "venu2s" "-w" "-t"

# Simulator starten
Start-Process "...\simulator.exe" -ArgumentList "-d", "venu2s"

# Tests ausführen (einzelner Test mit Funktionsname)
& "...\monkeydo.bat" "bin\DungeonCrawler.prg" "venu2s" "/t" "testFunctionName"
```
