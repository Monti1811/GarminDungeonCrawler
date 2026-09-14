# Tooling

Balance scripts, MCP server, and helper utilities.

## Balance System (`tools/balance/`)

Automated balancing pipeline for game stats.

### Scripts

| Script | Purpose |
|--------|---------|
| `auto_balance.py` | Main balance script: simulates combat, proposes stat changes |
| `auto_apply_balance.py` | Applies proposed changes from `balance_report.json` to source files |
| `auto_balance_rates_only.py` | Balances spawn rates only (not stats) |

### Configuration

| File | Purpose |
|------|---------|
| `balance_config.json` | Main config: depth range, target win rates, tolerance |
| `balance_config.full10.json` | Full 10-depth range config |
| `balance_config.noscale.json` | No scaling mode |
| `balance_config.stage1.json` | Stage 1 (early game) focus |
| `balance_rates_config.json` | Rate-specific balancing config |

### How It Works

1. **Parse source** -- reads Monkey C files for player/enemy/item stats
2. **Simulate combat** -- runs Monte Carlo simulations across depths
3. **Compare targets** -- checks win rates against target curves
4. **Propose changes** -- generates stat adjustments
5. **Output report** -- `balance_report.json` / `balance_report.md`

### Running Balance

```bash
python tools/balance/auto_balance.py
python tools/balance/auto_apply_balance.py
```

### Output

- `balance_report.json` -- machine-readable proposed changes
- `balance_report.md` -- human-readable summary
- `balance_rates_report.json` / `.md` -- rate-specific reports

## MCP Server (`tools/mcp_monkeyc/`)

Python MCP server exposing 20+ tools for AI-assisted Connect IQ development.

### Tools

| Tool | Category | Description |
|------|----------|-------------|
| `build_for_device` | Build | Compile for specific Garmin device |
| `run_in_simulator` | Build | Run PRG in simulator |
| `split_items_spritesheet` | Assets | Split spritesheet into individual PNGs |
| `register_drawable` | Assets | Register PNG in drawables.xml |
| `validate_drawables_resources` | Assets | Validate drawables against files |
| `scaffold_item` | Code Gen | Create new item class + register in factory |
| `scaffold_enemy` | Code Gen | Create new enemy class + register in factory |
| `scaffold_player_class` | Code Gen | Create new player class + register in factory |
| `generate_image_and_embed` | Assets | AI-generate image, resize, register |
| `generate_font_tile` | Assets | Generate font tile via AI |
| `rebuild_font_atlas` | Assets | Rebuild bitmap font from BMFont config |
| `optimize_drawable_png` | Assets | Optimize PNG with palette quantization |
| `analyze_drawable_usage` | Analysis | Compare drawable usage vs definitions |
| `list_manifest_products` | Config | List devices in manifest.xml |
| `add_manifest_product` | Config | Add device to manifest |
| `remove_manifest_product` | Config | Remove device from manifest |
| `check_monkeyc_environment` | Dev | Verify Java, SDK, key prerequisites |
| `run_balance_script` | Balance | Run balance pipeline |
| `run_release_build_script` | Release | Build and create GitHub release |

### Running the MCP Server

```bash
cd tools/mcp_monkeyc
pip install -r requirements.txt
python server.py
```

## Helper Utilities (`helpers/`)

### create_font.py

Slices a spritesheet PNG into individual 16x16 tiles for BMFont input.

```bash
python helpers/create_font.py <spritesheet.png> <output_dir>
```

### split_images.py

Splits item/monster spritesheets into individual PNGs organized by type:
- Weapons by tier
- Armors by tier
- Monsters by name

Generates `drawables.xml` registration entries.

```bash
python helpers/split_images.py <spritesheet.png> <output_dir>
```

### create-release.ps1

PowerShell script for multi-device release builds.

```powershell
.\helpers\create-release.ps1 -Tag v1.2.0 -DeveloperKeyPath "F:\Code\Garmin\developer_key"
```

**Optional parameters:**
- `-Devices venu2s,venu3` -- build selected devices only
- `-CreateTag` -- create and push git tag
- `-MonkeybrainsJarPath` -- override SDK path

See [build.md](build.md) for full release instructions.
