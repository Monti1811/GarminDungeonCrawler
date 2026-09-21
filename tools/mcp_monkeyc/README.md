# MCP setup for DungeonCrawler (Monkey C)

Dieser MCP-Server gibt dir wiederverwendbare Tools direkt im Chat/Agent für typische Garmin-Workflows.

## Enthaltene Tools

- `build_for_device`: Build für ein Gerät (`debug`/`release`) über `monkeybrains.jar`
- `build_for_products`: Multi-Device-Build in einem Lauf
- `split_items_spritesheet`: Schneidet ein Item-Spritesheet in 16x16-Assets
- `register_drawable`: Trägt ein Bitmap automatisch in `resources/drawables/drawables.xml` ein
- `register_drawables_from_folder`: Registriert viele PNGs aus einem Ordner (optional mit Copy nach `resources/drawables/imported`)
- `validate_drawables_resources`: Prüft doppelte IDs, fehlende Dateien, unreferenzierte PNGs
- `optimize_drawable_png`: Reduziert PNG-Farbpalette für watch-freundliche Assets
- `generate_image_and_embed`: Generiert ein Bild per Modell, skaliert es auf Tile-Größe und registriert es in `drawables.xml`
- `run_balance_script`: Führt euer Balancing-Skript aus (wenn vorhanden)
- `list_manifest_products`: Liest unterstützte Geräte aus `manifest.xml`
- `run_release_build_script`: Wrapper für `helpers/create-release.ps1` (standardmäßig ohne GitHub-Release)
- `check_monkeyc_environment`: Prüft Java, SDK, monkeybrains, monkeydo und Developer-Key
- `list_connectiq_sdks`: Listet installierte Connect IQ SDKs inkl. Tool-Verfügbarkeit
- `run_in_simulator`: Startet `monkeydo` mit einer `.prg` (optional automatisch letzte Build)
- `add_manifest_product` / `remove_manifest_product`: Produkte in `manifest.xml` ergänzen/entfernen
- `analyze_drawable_usage`: Vergleicht `Rez.Drawables.*` Nutzung im Source mit `drawables.xml`
- `scaffold_item`: Erstellt neue Item-Klasse (weapon/armor/consumable) und registriert sie in `Items.mc`
- `scaffold_enemy`: Erstellt neue Enemy-Klasse und registriert sie in `Enemies.mc` (optional weighted table)
- `scaffold_player_class`: Erstellt neue Player-Class und registriert sie in `Players.mc`

## Installation

Im Repo-Root:

```powershell
python -m pip install -r tools/mcp_monkeyc/requirements.txt
```

## VS Code MCP-Konfiguration

Es wurde eine Workspace-Konfiguration angelegt:

- `.vscode/mcp.json`

Passe dort bei Bedarf an:

- `MONKEYC_DEVELOPER_KEY_PATH` auf deinen Key
- `OPENROUTER_API_KEY` für OpenRouter-Bildgenerierung setzen
- Optional für OpenRouter-Ranking/Header: `OPENROUTER_SITE_URL`, `OPENROUTER_APP_NAME`

## Beispielaufrufe

- Build für Venu 2S (Debug)
  - `build_for_device(product="venu2s", release=false)`

- Build für Venu 3 (Release)
  - `build_for_device(product="venu3", release=true)`

- Multi-Build für mehrere Geräte
  - `build_for_products(products=["venu2s","venu3","venu3s"], release=false)`

- Ein neues KI-Icon erzeugen und registrieren
  - `generate_image_and_embed(bitmap_id="orc_icon", prompt="orc head", model="openrouter/hunter-alpha", final_size="16x16")`

- OpenRouter mit explizitem Model
  - `generate_image_and_embed(bitmap_id="orc_icon2", prompt="orc head", model="openrouter/hunter-alpha", final_size="16x16")`

- Strikten Style beibehalten, aber feinjustieren
  - `generate_image_and_embed(bitmap_id="bat_icon", prompt="bat", final_size="16x16", style_preset="watch16_1bit", style_suffix="dark fantasy mood")`

- Style-Policy bewusst abschalten (nur wenn nötig)
  - `generate_image_and_embed(bitmap_id="test_icon", prompt="any style", final_size="16x16", enforce_style_policy=false)`

- Nur XML-Registrierung für bestehende Datei
  - `register_drawable(bitmap_id="my_icon", filename="generated/my_icon.png")`

- Alle PNGs aus Ordner registrieren (Dry-Run)
  - `register_drawables_from_folder(source_folder="media/new-icons", id_prefix="gen_", dry_run=true)`

- Drawables prüfen
  - `validate_drawables_resources()`

- PNG für watch optimieren
  - `optimize_drawable_png(input_path="resources/drawables/generated/orc_icon.png", max_colors=8)`

- Geräte aus Manifest lesen
  - `list_manifest_products()`

- Monkey C Umgebung prüfen
  - `check_monkeyc_environment()`

- Installierte SDKs anzeigen
  - `list_connectiq_sdks()`

- Letzte Build direkt im Simulator starten
  - `run_in_simulator(product="venu2s")`

- Produkt in Manifest hinzufügen
  - `add_manifest_product(product_id="venu3")`

- Produkt aus Manifest entfernen
  - `remove_manifest_product(product_id="venu3")`

- Drawables-Nutzung gegen Source prüfen
  - `analyze_drawable_usage()`

- Neues Item scaffolden und automatisch in Factory eintragen
  - `scaffold_item(class_name="ShadowSword", item_kind="weapon", drawable_id="shadow_sword")`

- Neuen Enemy scaffolden und in weighted Spawns aufnehmen
  - `scaffold_enemy(class_name="ShadowOrc", enemy_id=36, drawable_id="monster_shadow_orc", include_in_weighted_table=true, weighted_cost=8, weighted_weight=6)`

- Neue Player-Klasse scaffolden
  - `scaffold_player_class(class_name="Assassin", player_id=5, default_name="Assassin", sprite_drawable_id="KnightBlue", start_right_hand_item="SteelDagger")`

- Release-Build-Script lokal ausführen (ohne GH-Release)
  - `run_release_build_script(tag="v0.3.0", devices=["venu2s","venu3"], skip_release=true)`

- Items aus Spritesheet schneiden
  - `split_items_spritesheet(image_path="media/items_source.png")`

## Hinweise

- `generate_image_and_embed` erzeugt immer zwei Dateien:
  - `<bitmap_id>_raw.png` (Originalausgabe)
  - `<bitmap_id>.png` (auf Tile-Größe skaliert)
- Für Image Generation werden Provider unterstützt:
  - OpenRouter via `OPENROUTER_API_KEY`
- `final_size` ist absichtlich auf erlaubte Größen eingeschränkt (aktuell nur `16x16`) für konsistente Watch-Assets.
- Standardmäßig erzwingt `generate_image_and_embed` eine Style-Policy für 16x16-watch-taugliche Pixel-Art (`enforce_style_policy=true`).
- Verfügbare `style_preset` Werte: `watch16`, `watch16_1bit`.
- Wenn OpenRouter kein Bild liefert, versucht `generate_image_and_embed` es automatisch bis zu 3 mal.
- Wenn `auto_apply_balance.py` fehlt, liefert `run_balance_script` eine klare Fehlermeldung statt Abbruch.
- Die Scaffold-Tools brechen bei doppelten IDs/Klassen in den Factory-Modulen sauber mit Fehlermeldung ab.
- `scaffold_item` verwendet immer die nächste freie ID je Bereich (`0-999`, `1000-1999`, `2000-2999`).
- Wenn `item_id` explizit gesetzt wird, muss sie exakt der nächsten freien ID entsprechen.
- `scaffold_item` ergänzt neue IDs standardmäßig auch in `ItemSpecificValues`.
- `scaffold_enemy` ergänzt neue IDs standardmäßig auch in `EnemySpecificValues`.
- Für Vorschau ohne Dateischreiben: `dry_run=true` in `scaffold_item`, `scaffold_enemy`, `scaffold_player_class`.
