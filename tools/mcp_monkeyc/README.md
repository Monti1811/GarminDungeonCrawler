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
- `OPENAI_API_KEY` in deiner Umgebung setzen
- `IMAGEROUTER_API_KEY` für ImageRouter-Bildgenerierung setzen
- `GEMINI_API_KEY` (oder `GOOGLE_API_KEY`) für Gemini-Bildgenerierung setzen

## Beispielaufrufe

- Build für Venu 2S (Debug)
  - `build_for_device(product="venu2s", release=false)`

- Build für Venu 3 (Release)
  - `build_for_device(product="venu3", release=true)`

- Multi-Build für mehrere Geräte
  - `build_for_products(products=["venu2s","venu3","venu3s"], release=false)`

- Ein neues KI-Icon erzeugen und registrieren
  - `generate_image_and_embed(bitmap_id="orc_icon", prompt="orc head", provider="openrouter", model="openrouter/hunter-alpha", final_size="16x16")`

- OpenRouter als Default (provider weglassen)
  - `generate_image_and_embed(bitmap_id="orc_icon2", prompt="orc head", model="openrouter/hunter-alpha", final_size="16x16")`

- Ein neues KI-Icon über Gemini-Key erzeugen und registrieren
  - `generate_image_and_embed(bitmap_id="slime_icon", prompt="slime", provider="gemini", final_size="16x16")`

- Ein neues KI-Icon über ImageRouter erzeugen und registrieren
  - `generate_image_and_embed(bitmap_id="wolf_icon", prompt="wolf", provider="imagerouter", model="test/test", final_size="16x16")`

- Strikten Style beibehalten, aber feinjustieren
  - `generate_image_and_embed(bitmap_id="bat_icon", prompt="bat", provider="gemini", final_size="16x16", style_preset="watch16_1bit", style_suffix="dark fantasy mood")`

- Style-Policy bewusst abschalten (nur wenn nötig)
  - `generate_image_and_embed(bitmap_id="test_icon", prompt="any style", provider="openai", final_size="16x16", enforce_style_policy=false)`

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

- Release-Build-Script lokal ausführen (ohne GH-Release)
  - `run_release_build_script(tag="v0.3.0", devices=["venu2s","venu3"], skip_release=true)`

- Items aus Spritesheet schneiden
  - `split_items_spritesheet(image_path="media/items_source.png")`

## Hinweise

- `generate_image_and_embed` erzeugt immer zwei Dateien:
  - `<bitmap_id>_raw.png` (Originalausgabe)
  - `<bitmap_id>.png` (auf Tile-Größe skaliert)
- Für Image Generation werden Provider unterstützt:
  - OpenRouter via `OPENROUTER_API_KEY` (wird standardmäßig zuerst verwendet)
  - OpenAI via `OPENAI_API_KEY`
  - ImageRouter via `IMAGEROUTER_API_KEY`
  - Gemini via `GEMINI_API_KEY` (oder `GOOGLE_API_KEY`)
- `final_size` ist absichtlich auf erlaubte Größen eingeschränkt (aktuell nur `16x16`) für konsistente Watch-Assets.
- Standardmäßig erzwingt `generate_image_and_embed` eine Style-Policy für 16x16-watch-taugliche Pixel-Art (`enforce_style_policy=true`).
- Verfügbare `style_preset` Werte: `watch16`, `watch16_1bit`.
- Wenn `auto_apply_balance.py` fehlt, liefert `run_balance_script` eine klare Fehlermeldung statt Abbruch.
