# Auto Balance System

This folder contains an automated balancing pipeline for the game.

## What it does

- Parses current stats directly from Monkey C source files:
  - Player classes (`source/Engine/Entities/Player/Classes/*.mc`)
  - Enemies (`source/Engine/Entities/Enemies/**/*.mc`)
  - Weapons/armor (`source/Engine/Items/**/*.mc`)
  - Spawn profile (`source/Engine/Util/EnemySpecificValues.mc`)
- Simulates many combat rounds across configured dungeon depths.
- Simulates player progression by depth using enemy XP, including:
  - class `onLevelUp()` health/mana gains
  - attribute growth from earned level-up points
- Simulation accounts for combat resources:
  - Health potion usage during fights
  - Mana pool and mana-potion recovery for mage-style weapons
  - Ammunition limits (arrows/bolts) for archer-style weapons
- Optional strict realism mode simulates full room encounters using:
  - Enemy spawn weights and costs from `EnemySpecificValues`
  - Consumable availability from `ItemSpecificValues`
  - Variable enemy counts per room by depth (budget-driven)
  - Additional strict-table balancing proposals for:
    - `source/Engine/Util/EnemySpecificValues.mc` (enemy tier weights)
    - `source/Engine/Util/ItemSpecificValues.mc` (consumable tier weights)
- Compares actual win rates against configurable target win-rate bands.
- Proposes stat changes for:
  - Player health + attributes
  - Enemy damage/health/armor
  - Item attack/defense/value
- Optionally applies those changes directly into source files.

## Configure targets

Edit `tools/balance/balance_config.json`:

- `strictRealism`: enables room simulation driven by spawn tables
- `roundsPerDepth`: simulation rounds per class per depth
- `depthRange`: start/end/step depth sweep (default now 1..200)
- `targetWinRateByDepth`: desired win-rate curve
- `tolerance`: no-change zone around target
- `maxAdjustmentPercentPerRun`: safety cap per run
- `variation`: jitter and multipliers for enemy count/weights and item weights
- `roomsPerDepthForProgression`: estimated cleared rooms per depth used for XP/level projection
  - `enemyBudgetScaleByDepth`: piecewise depth scaling for room enemy budget (controls likely enemy count/strength mix)
  - `itemDropScaleByDepth`: piecewise depth scaling for consumable availability from ItemSpecificValues

## Run (dry-run)

```powershell
C:/Users/Timon/AppData/Local/Programs/Python/Python310/python.exe tools/balance/auto_balance.py --workspace .
```

Outputs:

- `tools/balance/balance_report.json`
- `tools/balance/balance_report.md`

## Apply proposed changes

```powershell
C:/Users/Timon/AppData/Local/Programs/Python/Python310/python.exe tools/balance/auto_balance.py --workspace . --apply
```

## Run automatic apply cycles

This repeatedly runs simulation + apply for multiple rounds until no more changes are proposed (or max rounds reached):

```powershell
C:/Users/Timon/AppData/Local/Programs/Python/Python310/python.exe tools/balance/auto_apply_balance.py --workspace . --rounds 3
```

## Rates-only auto balance (recommended for your case)

This mode changes only spawn/drop tables (no player/enemy/item stat edits):

- Enemy spawn profile in `source/Engine/Util/EnemySpecificValues.mc`
  - weight per tier (`:weight`)
  - depth windows (`:max`, which controls when tiers start/end)
- Item drop profile in `source/Engine/Util/ItemSpecificValues.mc`
  - consumable tier weight (`:weight`)
  - consumable depth windows (`:max`)

Dry run:

```powershell
C:/Users/Timon/AppData/Local/Programs/Python/Python310/python.exe tools/balance/auto_balance_rates_only.py --workspace . --config tools/balance/balance_rates_config.json
```

Apply table changes:

```powershell
C:/Users/Timon/AppData/Local/Programs/Python/Python310/python.exe tools/balance/auto_balance_rates_only.py --workspace . --config tools/balance/balance_rates_config.json --apply
```

Outputs:

- `tools/balance/balance_rates_report.json`
- `tools/balance/balance_rates_report.md`

## Suggested workflow

1. Run dry-run and inspect report.
2. Run with `--apply` when proposal looks reasonable.
3. Build + playtest.
4. Repeat until win-rate curve is where you want it.

This gives you an automated baseline so balance tuning is data-driven instead of manual guessing.

Default profile now targets roughly:

- Depth 1 ≈ 100% win rate
- Depth 200 ≈ 20% win rate
