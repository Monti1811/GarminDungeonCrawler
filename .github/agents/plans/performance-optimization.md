# Performance-Optimierungsplan

**Datum:** 2026-08-29  
**Status:** Plan  
**Geschätzter Aufwand:** 2-3 Tage

---

## Monkey C Memory-Regeln (WICHTIG)

Bevor Optimierungen umgesetzt werden, müssen diese Monkey C Besonderheiten beachtet werden:

### 1. Instance-Variablen vs. Local-Variablen
- **Instance-Variablen** (class `var`) leben so lange wie das Objekt — sie **verbrauchen IMMER Speicher**
- **Local-Variablen** (`var` in Funktionen) werden auf dem Stack allokiert und **nach Funktionsende freigegeben**
- **Merke:** Local-Variablen sind **~8x schneller** als Instance-Variablen (Garmin-Forum)
- **Regel:** Wenn ein Wert nur in einer Funktion gebraucht wird → **Local-Variable verwenden**, nicht cachen!

### 2. Constants sind NICHT gratis
- `const` in Monkey C wird auf dem **Heap** allokiert, nicht compile-time-inlined
- `const` verbraucht **mehr Speicher** alsHardcoded-Literale
- **Nur verwenden** wenn:
  - Der Wert moralisch wichtig ist (z.B. `AUTOSAVE_INTERVAL = 3`)
  - Oder der Wert öfter als 10x referenziert wird

### 3. Dictionary-Overhead
- Jedes Dictionary hat **~30-40 Bytes Overhead** (Hash-Table, Buckets)
- **Vermeiden** wo möglich → stattdessen:
  - Arrays mit Index-Zugriff
  - Bit-Packing in 32-bit Integers
  - Oder einfache Klassen-Attribute

### 4. loadResource() hat permanente Kosten
- `WatchUi.loadResource()` lädt **alle Resource-Tabellen in RAM** beim ersten Aufruf
- Danach verbraucht **jeder Eintrag** in der Resource-Tabelle Speicher
- **Bitmap-Caching ist korrekt** — aber nur wenn die Bitmap tatsächlich häufig gerendert wird

### 5. Keine static local variables
- Monkey C unterstützt **keine `static`-Variablen** in Funktionen
- State muss über Klassen-Variablen oder Module-Variablen gespeichert werden

### 6. Peak Memory
- Variablen in Funktionen verbrauchen Speicher nur während der Ausführung
- **Wichtig:** Zu viele Local-Variablen in einer Funktion können zu **Stack-Overflow** führen

---

## Kritische Überprüfung der Optimierungen

### ✅ KORREKT — Optimierungen die so funktionieren

| # | Optimierung | Warum korrekt |
|---|-------------|---------------|
| 1 | Bitmap-Caching | `loadResource()` pro Frame ist teuer. Cache reduziert Aufrufe von ~30/frame auf 1. **Aber:** Nur fürEntities die häufig gerendert werden (Gegner, Items im Raum). NICHT für Items im Inventory. |
| 2 | A* Pathfinder | Heuristik reduziert explorierte Knoten. **Aber:** NICHT Dictionary cachen (siehe #26). |
| 3 | Dash-AI | Ein A* statt 2-3 = weniger Peak-Memory + CPU. |
| 4 | Dirty Flag | Verhindert unnötiges Rendern. Local-Flag ist OK. |
| 5 | freeMemory() | Korrekt — setzt References auf null für GC. |
| 6 | Autosave Throttling | Reduziert Storage-Writes. Korrekt. |
| 7 | createRandomItem | Eliminiert ~139 Fehlschläge. Korrekt. |
| 8 | Integer Keys | Int-Keys sind effizienter als String-Keys. Korrekt. |
| 9 | Flag-Caching | Bitmaps cachen wenn sie oft gerendert werden. Korrekt. |
| 10 | Reflection entfernen | `Lang.Method` pro Frame ist teuer. If-Statements sind besser. |
| 13 | reconstructPath | Bug korrigiert, gibt ersten Schritt zurück. Korrekt. |
| 17 | enemy_queue Index | Index statt Remove = O(1) statt O(n). Korrekt. |
| 18 | deepcopy Bug | Shallow-Copy ist ein Bug. Korrekt. |
| 20 | Tile.save x/y | Redundante Daten entfernen. Korrekt. |
| 21 | Map.save kompakter | Flat Array statt verschachtelte Dicts. Korrekt. |
| 22 | Elementale Effects | Primitive Variablen statt Dictionary. Korrekt. |
| 23 | Log entfernen | Wird nie persistiert. Korrekt. |
| 24 | Totter Code | Listener/Forms nirgends referenziert. Korrekt. |
| 27 | Player.save keys | `keys()` vor Schleife cachen. Korrekt. |

---

### ⚠️ ÜBERARBEITEN — Optimierungen die angepasst werden müssen

#### #12 getRoomPosition — Dictionary Cache

**Problem:** `Dictionary<RoomName, Point2D>` als Instance-Variable verbraucht permanent Speicher, auch wenn man sich nicht im Dungeon befindet.

**Lösung:** Dictionary beim Verlassen des Dungeons auf null setzen:
```monkey-c
private var _room_positions as Dictionary<String, Array<Number>>? = null;

function getRoomPosition(room_name) {
    if (_room_positions != null) {
        return _room_positions[room_name];
    }
    // ... lineare Suche als Fallback (ist nur beim Dungeon-Start nötig) ...
}

// Beim Dungeon-Verlassen aufrufen:
function freeMemory() {
    _room_positions = null;
}
```
**Warum:** Dictionary werden beim Dungeon-Start aufgebaut und beim Verlassen freigegeben. In "On Demand" Modus ist die O(n²) Suche beim ersten Aufruf akzeptabel.

---

#### #15 Armor-Array — NICHT als const!

**Problem:** `const ARMOR_SLOTS = [...]` verbraucht **permanenten Heap-Speicher** (Monkey C Constants sind Heap-Objekte).

**Besser:** Local-Variable in der Funktion:
```monkey-c
function getDefense() {
    var defense = 0;
    // Local-Variable — wird nach return automatisch freigegeben
    var slots = [HEAD, CHEST, BACK, LEGS, FEET, ACCESSORY, LEFT_HAND, RIGHT_HAND];
    for (var i = 0; i < slots.size(); i++) {
        var item = equipped[slots[i]];
        if (item != null && (item instanceof ArmorItem)) {
            defense += (item as ArmorItem).getDefense();
        }
    }
    return defense;
}
```
**Warum:** `slots`-Array wird auf dem Stack allokiert und nach `return` freigegeben.

---

#### #16 Weapon-Lookups — NICHT cachen!

**Problem:** `_cached_left_weapon` / `_cached_right_weapon` als Instance-Variable verbraucht **permanenten Speicher**.

**Besser:** Local-Variable in der Funktion wenn mehrfach benötigt:
```monkey-c
function doAttack() {
    var left_weapon = getWeaponItem(LEFT_HAND);
    var right_weapon = getWeaponItem(RIGHT_HAND);
    // ... Verwenden ...
}
```
**Warum:** Local-Variablen sind ~8x schneller und werden nach Funktionsende freigegeben.

---

#### #25 Room.values() — NICHT cachen!

**Problem:** `_enemies_cache` als Instance-Variable verbraucht permanenten Speicher.

**Besser:** `values()` direkt aufrufen (ist O(n) aber temporary):
```monkey-c
// STATT:
var enemies = _enemies_cache;  // Permanent!

// LIEBER:
var enemies = _enemies.values();  // Temporary, wird GC'd
```
**Warum:** `values()` erstellt ein Array das nach dem Zug freigegeben wird. Cache verbraucht permanent Speicher.

---

#### #26 Pathfinder Dictionary — NICHT cachen!

**Problem:** 4-5 Dictionaries als Instance-Variable = **~150-200 Bytes permanent**.

**Besser:** Dictionary als Local-Variable (temporary):
```monkey-c
function findPathToPos(map, start, end) {
    // Dictionary werden auf dem Stack allokiert
    // und nach return automatisch freigegeben
    var open_dict = {};
    var closed_dict = {};
    var g_score = {};
    var came_from = {};
    // ...
}
```
**Warum:** Pathfinder wird pro Gegner aufgerufen. Dictionary sind temporary und werden nach Funktionsende GC'd. Cache verbraucht permanent Speicher für alle Gegner die jemals existiert haben.

---

### ❌ FALSCH — Optimierungen die entfernt werden sollten

#### #14 mapToString String-Konkatenation

**Problem:** `Array<Char>` + `StringUtil.charArrayToString()` verbraucht **mehr Speicher** als String-Konkatenation, weil:
1. `Array<Char>` = ein额外es Array-Objekt
2. `StringUtil.charArrayToString()` muss das Array wieder traversieren
3. Die String-Konkatenation in Monkey C ist intern optimiert (nicht wie Java)

**Lass es so wie es ist.** String-Konkatenation in Monkey C ist nicht so teuer wie in anderen Sprachen.

---

## Überarbeitete Übersicht

| # | Optimierung | Priorität | Aufwand | Impact | Status |
|---|-------------|-----------|---------|--------|--------|
| 1 | Bitmap-Caching | 🔴 Kritisch | Gering | Sehr hoch | ✅ Korrekt |
| 2 | A* Pathfinder: Heuristik + PQ | 🔴 Kritisch | Mittel | Hoch | ✅ Korrekt |
| 3 | Dash-AI: Einmal A* | 🟡 Hoch | Gering | Hoch | ✅ Korrekt |
| 4 | Foreground Dirty Flag | 🟡 Hoch | Gering | Mittel | ✅ Korrekt |
| 5 | Player.freeMemory() | 🟡 Hoch | Gering | Mittel | ✅ Korrekt |
| 6 | Autosave Throttling | 🟠 Mittel | Gering | Hoch | ✅ Korrekt |
| 7 | createRandomItem() | 🟠 Mittel | Gering | Niedrig | ✅ Korrekt |
| 8 | Integer statt String | 🟢 Niedrig | Gering | Niedrig | ✅ Korrekt |
| 9 | DCMapDrawable Flag-Caching | 🟡 Hoch | Gering | Hoch | ✅ Korrekt |
| 10 | DCGameView Reflection | 🟡 Hoch | Gering | Mittel | ✅ Korrekt |
| 12 | getRoomPosition | 🟠 Mittel | Gering | Mittel | ✅ Korrekt |
| 13 | reconstructPath | 🟠 Mittel | Gering | Mittel | ✅ Korrekt |
| 14 | mapToString | 🟠 Mittel | Gering | Mittel | ❌ Entfernen |
| 15 | Armor-Array | 🟠 Mittel | Gering | Niedrig | ⚠️ Anpassen |
| 16 | Weapon-Lookups | 🟠 Mittel | Gering | Niedrig | ❌ Entfernen |
| 17 | enemy_queue Index | 🟠 Mittel | Gering | Mittel | ✅ Korrekt |
| 18 | Map.deepcopy Bug | 🟡 Hoch | Gering | Hoch | ✅ Korrekt |
| 19 | getRoomName | 🟢 Niedrig | Gering | Niedrig | ✅ Korrekt |
| 20 | Tile.save x/y | 🟢 Niedrig | Gering | Niedrig | ✅ Korrekt |
| 21 | Map.save kompakter | 🟢 Niedrig | Groß | Mittel | ✅ Korrekt |
| 22 | Elementale Effects | 🟢 Niedrig | Mittel | Niedrig | ✅ Korrekt |
| 23 | Log entfernen | 🟢 Niedrig | Gering | Niedrig | ✅ Korrekt |
| 24 | Listener & Forms | 🟢 Niedrig | Gering | Niedrig | ✅ Korrekt |
| 25 | Room.values() | 🟢 Niedrig | Gering | Niedrig | ❌ Entfernen |
| 26 | Pathfinder Dict cachen | 🟠 Mittel | Mittel | Hoch | ❌ Entfernen |
| 27 | Player.save keys | 🟢 Niedrig | Gering | Niedrig | ✅ Korrekt |

**Ergebnis:** 20 korrekt, 1 anzupassen, 3 zu entfernen

---

## 1. Bitmap-Caching

### Problem
`Entity.getSpriteRef()` und `Item.getSpriteRef()` rufen bei jedem Aufruf `WatchUi.loadResource()` auf. Das dekomprimiert die Bitmap bei jedem Frame komplett neu.

### Betroffene Dateien
- `source/Engine/Entities/Entity.mc:32-34`
- `source/Engine/Items/Item.mc:68-70`

### Änderungen

**Entity.mc — Neue Member-Variable + Cache-Logik:**
```monkey-c
class Entity {
    // ... bestehende Variablen ...
    private var _sprite_ref as Toybox.Graphics.BitmapReference? = null;

    function getSpriteRef() as Toybox.Graphics.BitmapReference {
        if (_sprite_ref == null) {
            _sprite_ref = $.Toybox.WatchUi.loadResource(getSprite());
        }
        return _sprite_ref;
    }

    function freeSpriteCache() as Void {
        _sprite_ref = null;
    }
}
```

**Item.mc — Gleicher Ansatz:**
```monkey-c
class Item {
    // ... bestehende Variablen ...
    private var _sprite_ref as Toybox.Graphics.BitmapReference? = null;

    function getSpriteRef() as Toybox.Graphics.BitmapReference {
        if (_sprite_ref == null) {
            _sprite_ref = $.Toybox.WatchUi.loadResource(getSprite());
        }
        return _sprite_ref;
    }

    function freeSpriteCache() as Void {
        _sprite_ref = null;
    }
}
```

**Aufräumen beim Verlassen des Raums:**
```monkey-c
// In Room.freeMemory() oder bei Raumwechsel:
function clearEntitySpriteCaches() as Void {
    var enemies = _enemies.values();
    for (var i = 0; i < enemies.size(); i++) {
        (enemies[i] as Enemy).freeSpriteCache();
    }
    var items = _items.values();
    for (var i = 0; i < items.size(); i++) {
        (items[i] as Item).freeSpriteCache();
    }
}
```

**Wann cache invalidiert werden muss:**
- Wenn `getSprite()` sich ändern kann (z.B. bei Item-Equipping) → `freeSpriteCache()` aufrufen
- Wenn Entity/Item den Raum verlässt → `freeSpriteCache()` aufrufen
- Wenn `freeMemory()` aufgerufen wird → `freeSpriteCache()` aufrufen

### API-Referenz
`WatchUi.loadResource(resource)` — lädt eine Ressource aus dem Executable, gibt `BitmapReference` zurück. Kein eingebauter Cache-Mechanismus.

---

## 2. A* Pathfinder: Heuristik + Priority Queue

### Problem
- `getLowestG()` erzeugt bei jedem Aufruf ein neues Array via `.keys()` und durchsucht es linear → O(V²)
- Keine Heuristik → de facto Dijkstra statt A*
- 5 Dictionaries pro A*-Aufruf

### Betroffene Dateien
- `source/Engine/Maps/Pathfinder.mc`

### Änderungen

**Pathfinder.mc — Priority Queue (Array-basiert mit Insertion-Sort):**
```monkey-c
module Pathfinder {

    // Priority Queue: Array von [priority, value] Paaren
    // Sortiert aufsteigend nach priority
    
    function pq_enqueue(queue as Array, priority as Number, value as Number) as Void {
        var entry = [priority, value];
        var i = 0;
        while (i < queue.size() && (queue[i] as Array)[0] <= priority) {
            i++;
        }
        queue.add(entry);
        // Verschiebe ab i alle Elements nach hinten
        for (var j = queue.size() - 1; j > i; j--) {
            queue[j] = queue[j - 1];
        }
        queue[i] = entry;
    }
    
    function pq_dequeue(queue as Array) as Number {
        return (queue[0] as Array)[1] as Number;
    }
    
    // Manhattan Distance Heuristik
    function manhattanHeuristic(pos1 as Number, pos2 as Number) as Number {
        var x1 = pos1 >> 8;
        var y1 = pos1 & 0xFF;
        var x2 = pos2 >> 8;
        var y2 = pos2 & 0xFF;
        return (x1 - x2).abs() + (y1 - y2).abs();
    }
}
```

**A* mit Heuristik:**
```monkey-c
function findPathToPos(map, start_pos, end_pos) as Point2D? {
    var start_num = toIntPoint2D(start_pos);
    var end_num = toIntPoint2D(end_pos);
    
    var open_queue = [] as Array;  // Priority Queue
    var closed_dict = {} as Dictionary<Number, Boolean>;
    var g_score = {} as Dictionary<Number, Number>;
    var came_from = {} as Dictionary<Number, Number>;
    
    g_score[start_num] = 0;
    var h = manhattanHeuristic(start_num, end_num);
    pq_enqueue(open_queue, h, start_num);
    
    while (open_queue.size() > 0) {
        var current = pq_dequeue(open_queue);
        
        if (current == end_num) {
            return reconstructPathFast(came_from, current);
        }
        
        closed_dict[current] = true;
        
        var neighbors = getNeighbors(map, current);
        for (var i = 0; i < neighbors.size(); i++) {
            var neighbor = neighbors[i];
            if (closed_dict[neighbor] != null) { continue; }
            
            var tentative_g = g_score[current] + 1;
            if (g_score[neighbor] == null || tentative_g < g_score[neighbor]) {
                came_from[neighbor] = current;
                g_score[neighbor] = tentative_g;
                var f_score = tentative_g + manhattanHeuristic(neighbor, end_num);
                pq_enqueue(open_queue, f_score, neighbor);
            }
        }
    }
    return null;
}
```

**Optimiertes reconstructPath — gibt den ersten Schritt zurück:**
```monkey-c
function reconstructPathFast(came_from as Dictionary, current as Number) as Point2D? {
    while (came_from[current] != null) {
        var prev = current;
        current = came_from[current];
        if (came_from[current] == null) {
            // current ist der Start → prev ist der erste Schritt
            return fromIntPoint2D(prev);
        }
    }
    return fromIntPoint2D(current);  // Start = Ziel → direkt dort
}
```

### Performance-Verbesserung
- Vorher: O(V²) = 90,000 Vergleiche bei 300 Tiles
- Nachher: O(V log V) = ~2,500 Operationen bei 300 Tiles

---

## 3. Dash-AI: Einmal A*, erste n Schritte nehmen

### Problem
`followPlayerDash()` führt für jeden Dash-Schritt ein komplett neues A* durch. Bei `max_steps=2` sind das 2 volle A*-Durchläufe pro Feind.

### Betroffene Dateien
- `source/Engine/Entities/Enemies/Enemy.mc` (followPlayerDash)
- `source/Engine/Maps/Pathfinder.mc` (neue Funktion)

### Änderungen

**Enemy.mc — `followPlayerDash()` vereinfacht:**
```monkey-c
function followPlayerDash(map as Map, player_pos as Point2D, max_steps as Number) as Point2D? {
    // EINMAL A* ausführen
    var path = findFullPathToPos(map, self.pos, player_pos);
    if (path == null || path.size() < 2) {
        return followPlayerDirect(map, player_pos);
    }
    
    // Die ersten max_steps Schritte nehmen
    var step = max_steps < path.size() ? max_steps : path.size() - 1;
    return fromIntPoint2D(path[step]);
}
```

**Pathfinder — Neue Funktion die den vollen Pfad zurückgibt:**
```monkey-c
function findFullPathToPos(map, start_pos, end_pos) as Array<Number>? {
    // Wie findPathToPos, aber gibt das komplette Pfad-Array zurück
    var start_num = toIntPoint2D(start_pos);
    var end_num = toIntPoint2D(end_pos);
    
    var open_queue = [] as Array;
    var closed_dict = {} as Dictionary<Number, Boolean>;
    var g_score = {} as Dictionary<Number, Number>;
    var came_from = {} as Dictionary<Number, Number>;
    
    g_score[start_num] = 0;
    pq_enqueue(open_queue, manhattanHeuristic(start_num, end_num), start_num);
    
    while (open_queue.size() > 0) {
        var current = pq_dequeue(open_queue);
        
        if (current == end_num) {
            // Pfad rekonstruieren
            var path = [] as Array<Number>;
            var c = current;
            path.add(c);
            while (came_from[c] != null) {
                c = came_from[c];
                path.add(c);
            }
            // Pfad umkehren (Start → Ende)
            var reversed = [] as Array<Number>;
            for (var i = path.size() - 1; i >= 0; i--) {
                reversed.add(path[i]);
            }
            return reversed;
        }
        
        closed_dict[current] = true;
        
        var neighbors = getNeighbors(map, current);
        for (var i = 0; i < neighbors.size(); i++) {
            var neighbor = neighbors[i];
            if (closed_dict[neighbor] != null) { continue; }
            
            var tentative_g = g_score[current] + 1;
            if (g_score[neighbor] == null || tentative_g < g_score[neighbor]) {
                came_from[neighbor] = current;
                g_score[neighbor] = tentative_g;
                pq_enqueue(open_queue, tentative_g + manhattanHeuristic(neighbor, end_num), neighbor);
            }
        }
    }
    return null;
}
```

### Performance-Verbesserung
- Vorher: 2 volle A*-Durchläufe = 180,000 Operationen pro Feind
- Nachher: 1 A*-Durchlauf + Pfad-Array = ~3,000 Operationen pro Feind

---

## 4. Foreground Dirty Flag

### Problem
`DCGameView.onUpdate()` rendert den Foreground-Layer bei jedem Aufruf komplett neu, auch wenn sich nichts geändert hat.

### Betroffene Dateien
- `source/FrontEnd/Game/DCGameView.mc`
- `source/Engine/Maps/Turn.mc` (dirty flag setzen)

### Änderungen

**DCGameView.mc:**
```monkey-c
class DCGameView extends WatchUi.View {
    private var _foreground_dirty as Boolean = true;
    
    function setForegroundDirty() as Void {
        _foreground_dirty = true;
        WatchUi.requestUpdate();
    }
    
    function onUpdate(dc as Dc) as Void {
        // Background (nur bei _background_dirty)
        if (_background_dirty) {
            var bg_dc = _background_layer.getDc();
            bg_dc.clear();
            _room_drawable.drawBackground(bg_dc, ...);
            _background_dirty = false;
        }
        
        // Foreground (nur bei _foreground_dirty)
        if (_foreground_dirty) {
            var fg_dc = _foreground_layer.getDc();
            fg_dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            fg_dc.clear();
            _room_drawable.drawForeground(fg_dc, ...);
            drawPlayer(fg_dc);
            _foreground_dirty = false;
        }
        
        // Overlay (nur bei _overlay_dirty)
        if (_overlay_dirty) {
            var ov_dc = _overlay_layer.getDc();
            ov_dc.clear();
            drawOverlay(ov_dc);
            _overlay_dirty = false;
        }
    }
}
```

**Wo `_foreground_dirty` gesetzt wird:**
- `Turn.resolvePlayerActions()` — nach Spielerbewegung
- `Turn.processEnemyAction()` — nach Gegnerbewegung
- `DCGameView.addDamageText()` — bei Schaden
- `Room.pickupItem()` — bei Item-Aufnahme

---

## 5. Player.freeMemory() implementieren

### Problem
`Player.freeMemory()` ist leer. Inventar, Equipment und Attribute werden nie freigegeben.

### Betroffene Dateien
- `source/Engine/Entities/Player/Player.mc:619-621`

### Änderungen

**Player.mc:**
```monkey-c
function freeMemory() as Void {
    inventory.freeMemory();
    inventory = new Inventory(0);
    equipped = {};
    attributes = {};
    added_attributes = {};
    elemental_effects = {};
    _sprite_ref = null;  // Bitmap-Cache
}
```

---

## 6. Autosave Throttling

### Problem
Bei "Every Turn"-Autosave wird bei jedem Zug alles serialisiert (~350 Dictionaries).

### Betroffene Dateien
- `source/Engine/Maps/Turn.mc` (finishTurn)
- `source/Engine/Util/SaveData.mc` (saveGame)

### Änderungen

**Turn.mc:**
```monkey-c
private var _turn_counter as Number = 0;
const AUTOSAVE_INTERVAL = 3;  // Alle 3 Züge speichern

function finishTurn() as Void {
    // ... bestehende Logik ...
    
    _turn_counter++;
    if (_autosave && _turn_counter >= AUTOSAVE_INTERVAL) {
        $.SaveData.saveGame();
        _turn_counter = 0;
    }
}
```

---

## 7. createRandomItem() filtern

### Problem
Die Schleife filtert Items nach ID > 4000, was ~139 Fehlschläge verursacht.

### Betroffene Dateien
- `source/Engine/Items/Items.mc` (createRandomItem)

### Änderungen

**Items.mc:**
```monkey-c
function createRandomItem() as Item {
    // Statt Filter-Schleife: Direkt zufälligen Index wählen
    var index = MathUtil.rand() % item_ids.size();
    return createItemFromId(item_ids[index]);
}
```

---

## 8. Integer statt String (MapUtil)

### Problem
`MapUtil.mc` nutzt String-Konkatenation `"x,y"` als Dictionary-Key.

### Betroffene Dateien
- `source/Engine/Util/MapUtil.mc` (findNearestEmptyTileAround)

### Änderungen

**MapUtil.mc:**
```monkey-c
function findNearestEmptyTileAround(map, pos, range) as Point2D? {
    var visited = {} as Dictionary<Number, Boolean>;
    var queue = [toIntPoint2D(pos)] as Array<Number>;
    
    visited[toIntPoint2D(pos)] = true;
    
    while (queue.size() > 0) {
        var current_num = queue[0];
        queue = queue.slice(1, null);  // dequeue
        
        // ... Nachbarn prüfen ...
        var neighbor_num = toIntPoint2D(neighbor);
        if (!visited[neighbor_num]) {
            visited[neighbor_num] = true;
            queue.add(neighbor_num);
        }
    }
}
```

---

## Weitere Optimierungen (Zusätzliche Analyse)

### 9. DCMapDrawable.drawFlag() — Bitmap-Loading im Render-Loop

**Datei:** `source/FrontEnd/Map/DCMapDrawable.mc:92`

`drawFlag()` ruft `WatchUi.loadResource(rez_id)` bei jedem Frame für jedes sichtbare Flag auf (Stairs, Merchant, QuestGiver).

**Lösung:** Bitmaps beim Initialisieren cachen:
```monkey-c
private var _flag_bitmaps as Dictionary<ResourceId, BitmapReference>? = null;

function initialize() {
    _flag_bitmaps = {
        $.Rez.Drawables.Stairs => WatchUi.loadResource($.Rez.Drawables.Stairs),
        $.Rez.Drawables.Merchant => WatchUi.loadResource($.Rez.Drawables.Merchant),
        $.Rez.Drawables.QuestGiver => WatchUi.loadResource($.Rez.Drawables.QuestGiver)
    };
}

function drawFlag(dc, pos, rez_id) {
    var bitmap = _flag_bitmaps[rez_id];
    if (bitmap != null) {
        dc.drawScaledBitmap(pos[0] - size_tile/2, pos[1] - size_tile/2, size_tile * 2, size_tile * 2, bitmap);
    }
}
```

---

### 10. DCGameView Reflection pro Frame

**Datei:** `source/FrontEnd/Game/DCGameView.mc:196, 282`

```monkey-c
var method = new Lang.Method(self, bar_to_fn[second_bar]);
var bar_values = method.invoke(player) as [Numeric, Numeric];
```

Bei jedem Frame wird ein `Lang.Method`-Objekt per Symbol-Lookup erstellt.

**Lösung:** Direkte if-Abstattung statt Reflection:
```monkey-c
if (second_bar == :mana) {
    bar_values = [player.current_mana, player.max_mana];
} else if (second_bar == :stamina) {
    bar_values = [player.current_stamina, player.max_stamina];
}
```

---

### 12. getRoomPosition() — O(n²) Lineare Suche

**Datei:** `source/Engine/Maps/Dungeon.mc:264-273`

Bei jedem Raumwechsel wird das gesamte `_rooms`-Array linear durchsucht (25 String-Vergleiche bei 5x5 Dungeon).

**Lösung:** Dictionary als inverse Lookup-Map, beim Dungeon-Verlassen freigeben:
```monkey-c
private var _room_positions as Dictionary<String, Array<Number>>? = null;

function getRoomPosition(room_name) {
    if (_room_positions != null) {
        return _room_positions[room_name];
    }
    // ... lineare Suche als Fallback (nur beim Start nötig) ...
}

// Beim Dungeon-Verlassen aufrufen:
function freeMemory() {
    _room_positions = null;
}
```
**Warum:** Dictionary wird beim Dungeon-Start aufgebaut und beim Verlassen freigegeben. In "On Demand" Modus ist die O(n²) Suche beim ersten Aufruf akzeptabel.

---

### 13. reconstructPath — Bug in Implementierung

**Datei:** `source/Engine/Maps/Pathfinder.mc:102-112`

**Problem:** Die vorgeschlagene Implementierung hat einen Logikfehler:
```monkey-c
// BUG: came_from[current] == null prüft ob START erreicht ist
// Aber der Start hat came_from[current] == null (nichts vor ihm)
// Das bedeutet: Die Schleife bricht beim Start ab, nicht beim Ziel
function reconstructPathFast(came_from, current) {
    var prev = current;
    while (came_from[current] != null) {
        prev = current;
        current = came_from[current];
        if (came_from[current] == null) {
            return fromIntPoint2D(prev);  // ← Gibt den vorletzten Schritt zurück
        }
    }
    return fromIntPoint2D(prev);
}
```

**Korrekte Implementierung:**
```monkey-c
// Gibt den ERSTEN Schritt vom Start aus zurück
function reconstructPathFast(came_from, current) {
    while (came_from[current] != null) {
        var prev = current;
        current = came_from[current];
        if (came_from[current] == null) {
            // current ist der Start → prev ist der erste Schritt
            return fromIntPoint2D(prev);
        }
    }
    return fromIntPoint2D(current);  // Start = Ziel → direkt dort
}
```
**Warum korrekt:** Die Schleife traversiert den Pfad vom Ziel zurück zum Start. Wenn `came_from[current] == null`, dann ist `current` der Start und `prev` ist der erste Schritt.

---

### ~~14. Map.mapToString()~~ ENTRERNT

**Grund:** String-Konkatenation in Monkey C ist intern optimiert. `Array<Char>` + `StringUtil.charArrayToString()` verbraucht **mehr Speicher** als die direkte Konkatenation. Nicht optimieren.

---

### 15. Player.getDefense() — Armor-Array pro Kampf

**Datei:** `source/Engine/Entities/Player/Player.mc:379-401`

Bei jedem Angriff wird ein neues 8-Element-Array erstellt.

**Lösung:** Local-Variable statt const:
```monkey-c
function getDefense() {
    var defense = 0;
    // Local-Variable — wird nach return automatisch freigegeben
    var slots = [HEAD, CHEST, BACK, LEGS, FEET, ACCESSORY, LEFT_HAND, RIGHT_HAND];
    for (var i = 0; i < slots.size(); i++) {
        var item = equipped[slots[i]];
        if (item != null && (item instanceof ArmorItem)) {
            defense += (item as ArmorItem).getDefense();
        }
    }
    return defense;
}
```
**Warum:** Local-Variable wird GC'd. `const` auf dem Heap würde permanenten Speicher verbrauchen.

---

### ~~16. Redundante Weapon-Lookups pro Kampf~~ ENTRERNT

**Grund:** `_cached_left_weapon` / `_cached_right_weapon` als Instance-Variable verbraucht **permanenten Speicher**. Local-Variablen sind ~8x schneller und werden nach Funktionsende freigegeben.

**Besser:** Local-Variable in der Funktion:
```monkey-c
function doAttack() {
    var left_weapon = getWeaponItem(LEFT_HAND);  // Local — temporary
    var right_weapon = getWeaponItem(RIGHT_HAND);  // Local — temporary
    // ... Verwenden ...
}
```

function cacheWeapons() {
    _cached_left_weapon = getWeaponItem(LEFT_HAND);
    _cached_right_weapon = getWeaponItem(RIGHT_HAND);
}
```

---

### 17. enemy_queue.remove() — O(n) pro Gegner-Aktion

**Datei:** `source/Engine/Maps/Turn.mc:314`

`Array.remove(element)` durchsucht das Array linear und verschiebt alle folgenden Elemente.

**Lösung:** Index statt Remove:
```monkey-c
private var _enemy_queue_index as Number = 0;

function onEnemyActionTimer() {
    if (_enemy_queue_index < _enemy_queue.size()) {
        var enemy = _enemy_queue[_enemy_queue_index];
        _enemy_queue_index++;
        // ... verarbeiten ...
    }
}
```

---

### 18. Map.deepcopy() — Shallow-Copy (Bug!)

**Datei:** `source/Engine/Maps/Map.mc:68-79`

`setTile(i, j, tile)` kopiert die Referenz, nicht das Objekt. Beide Maps teilen sich dieselben Tiles.

**Lösung:** Deep Copy:
```monkey-c
function deepcopy() {
    var new_map = new Map(_width, _height, false);
    for (var i = 0; i < _width; i++) {
        for (var j = 0; j < _height; j++) {
            var tile = _tiles[i][j];
            if (tile != null) {
                new_map.setTile(i, j, tile.deepcopy());
            }
        }
    }
    return new_map;
}
```

---

### 19. getRoomName() — String-Konkatenation bei jedem Dungeon-Zugriff

**Datei:** `source/Engine/Util/SimUtil.mc:13-14`

Bei einem 4x4 Dungeon: ~50+ String-Allokationen nur für Dungeon-Erstellung.

**Lösung:** Room-Namen einmalig cachen oder als Integer indexieren.

---

### 20. Tile.save() — Redundante x/y Koordinaten

**Datei:** `source/Engine/Maps/Tile.mc:22-28`

x/y ergeben sich aus der Position im Map-Array. Bei 676 Tiles = 2 unnötige Integer pro Tile.

**Lösung:** Nur `type` speichern, x/y aus Index ableiten.

---

### 21. Map.save() — Flaches Array statt kompakter Kodierung

**Datei:** `source/Engine/Maps/Map.mc:241-258`

Jeder Tile wird als eigenes Dictionary mit 3 Keys gespeichert.

**Lösung:** Tile-Typen als flaches Array<Number>:
```monkey-c
function save() {
    var tiles_flat = [] as Array<Number>;
    for (var i = 0; i < _width; i++) {
        for (var j = 0; j < _height; j++) {
            var tile = _tiles[i][j];
            tiles_flat.add(tile != null ? tile.type : -1);
        }
    }
    return {:width => _width, :height => _height, :tiles => tiles_flat};
}
```

---

### 22. Elementale Effects — Dictionary pro Entity

**Datei:** `source/Engine/Entities/Entity.mc:11`

Jedes Entity hat ein eigenes `elemental_effects` Dictionary, auch wenn nie Effekte angewendet werden.

**Lösung:** Lazy Init oder einfache Klassen-Attribute:
```monkey-c
private var _fire_power as Number = 0;
private var _fire_turns as Number = 0;
private var _ice_power as Number = 0;
// ... etc.
```

---

### 23. Log — Nie persistiert + unnötige Aufrufe

**Datei:** `source/Engine/Util/Log.mc`

`Log.log()` wird bei jedem Angriff und Item-Pickup aufgerufen, aber der Log wird nie persistiert.

**Lösung:** `Log.log()` in Produktion entfernen.

---

### 24. Listener & Forms — Totter Code

**Dateien:** `source/Engine/Util/Listener.mc` (43 Zeilen), `source/Engine/Util/Forms.mc` (7 Zeilen)

Wird nirgends aufgerufen.

**Lösung:** Beide Dateien komplett entfernen.

---

### ~~25. Room.getEnemies().values()~~ ENTRERNT

**Grund:** `_enemies_cache` als Instance-Variable verbraucht permanenten Speicher. `values()` erstellt ein temporary Array das nach dem Zug automatisch GC'd wird.

---

### ~~26. Pathfinder Dictionary-Overhead~~ ENTRERNT

**Grund:** 4-5 Dictionaries als Instance-Variable = **~150-200 Bytes permanent**. Dictionary werden nach `findPathToPos()` automatisch GC'd. Cache lohnt sich nicht weil Pathfinder pro Gegner aufgerufen wird und die Dictionaries unterschiedliche Größen haben.

---

### 27. Player.save() — equipped.keys() pro Speichervorgang

**Datei:** `source/Engine/Entities/Player/Player.mc:552-558`

`equipped.keys()` wird in der Schleifenbedingung bei JEDER Iteration erneut aufgerufen.

**Lösung:** Vor der Schleife zwischenspeichern:
```monkey-c
var eq_keys = equipped.keys();
for (var i = 0; i < eq_keys.size(); i++) {
    var slot = eq_keys[i];
    // ...
}
```

---

## Umsetzungsreihenfolge (Aktualisiert)

### Phase 1 — Kritisch (Sofort)
1. **Bitmap-Caching** (#1) — größter Impact
2. **A* Pathfinder** (#2) — zweitgrößter Impact

### Phase 2 — Hoch (Diese Woche)
3. **Dash-AI vereinfacht** (#3)
4. **Foreground Dirty Flag** (#4)
5. **Player.freeMemory()** (#5)
6. **DCMapDrawable Flag-Caching** (#9)
7. **Reflection entfernen** (#10)
8. **reconstructPath optimieren** (#13)
9. **enemy_queue Index** (#17)
10. **Map.deepcopy Bug fixen** (#18)

### Phase 3 — Mittel (Nächste Woche)
12. **Autosave Throttling** (#6)
13. **createRandomItem fix** (#7)
14. **Integer statt String** (#8)
15. **getRoomPosition optimieren** (#12)
16. **Armor-Array als Local** (#15)

### Phase 4 — Niedrig (Wenn Zeit)
17. **Tile.save() optimieren** (#20)
18. **Map.save() kompakter** (#21)
19. **Elementale Effects vereinfachen** (#22)
20. **Log entfernen** (#23)
21. **Totter Code entfernen** (#24)
22. **Player.save() keys cachen** (#27)

---

## Geschätzte Gesamt-Performance-Verbesserung

| Metrik | Vorher | Nachher | Faktor |
|--------|--------|---------|--------|
| Bitmap-Loading pro Frame | 15-30x | 0-1x | **15-30x** |
| Pathfinder-Zeit pro A* | O(V²) | O(V log V) | **30-50x** |
| Rendering pro Frame | Immer | Nur bei Änderung | **2-3x** |
| Speicher-Leak Player | 100% | 0% | **∞** |
| Storage-Writes pro Zug | 1x | Alle 3 Züge | **3x** |
| Debug-Output Release | 32 Stellen | 0 | **∞** |
