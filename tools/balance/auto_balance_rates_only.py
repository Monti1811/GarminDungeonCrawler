#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import auto_balance as core


def clamp(value: float, minimum: float, maximum: float) -> float:
    return max(minimum, min(maximum, value))


def bounded_int(value: float, minimum: int = 0) -> int:
    return max(minimum, int(round(value)))


def segment_average(depth_pressure: Dict[int, float], start: int, end: int) -> float:
    vals = [v for d, v in depth_pressure.items() if start <= d <= end]
    return (sum(vals) / len(vals)) if vals else 0.0


def build_depth_pressure(depth_win: Dict[int, float], depth_target: Dict[int, float]) -> Dict[int, float]:
    return {d: depth_win[d] - depth_target[d] for d in depth_win.keys() if d in depth_target}


def normalize_tiers(tiers: List[Tuple[int, float]]) -> List[Tuple[int, int]]:
    return [(int(max_depth), int(round(weight))) for max_depth, weight in tiers]


def shift_tiers_boundaries(
    tiers: List[Tuple[int, int]],
    early_pressure: float,
    late_pressure: float,
    max_boundary_shift: int,
) -> List[Tuple[int, int]]:
    shifted = [list(t) for t in tiers]
    if len(shifted) < 2:
        return [(a, b) for a, b in shifted]

    start_idx = None
    for idx in range(1, len(shifted)):
        if shifted[idx - 1][1] == 0 and shifted[idx][1] > 0:
            start_idx = idx
            break

    if start_idx is not None:
        start_shift = int(round(clamp(early_pressure * 2.5, -max_boundary_shift, max_boundary_shift)))
        prev_max = shifted[start_idx - 1][0]
        lower = shifted[start_idx - 2][0] + 1 if start_idx - 2 >= 0 else 1
        upper = shifted[start_idx][0] - 1
        shifted[start_idx - 1][0] = int(clamp(prev_max + start_shift, lower, max(lower, upper)))

    if len(shifted) >= 3:
        end_shift = int(round(clamp(-late_pressure * 2.5, -max_boundary_shift, max_boundary_shift)))
        idx = len(shifted) - 2
        current = shifted[idx][0]
        lower = shifted[idx - 1][0] + 1
        upper = shifted[idx + 1][0] - 1
        shifted[idx][0] = int(clamp(current + end_shift, lower, max(lower, upper)))

    for i in range(1, len(shifted)):
        if shifted[i][0] <= shifted[i - 1][0]:
            shifted[i][0] = shifted[i - 1][0] + 1

    return [(a, b) for a, b in shifted]


def propose_enemy_rate_adjustments(
    workspace: Path,
    enemy_weights: List[Dict[str, object]],
    depth_pressure: Dict[int, float],
    max_adjustment_percent: float,
    max_boundary_shift: int,
) -> List[Dict[str, object]]:
    file_path = workspace / "source/Engine/Util/EnemySpecificValues.mc"
    adjustments: List[Dict[str, object]] = []

    early_pressure = segment_average(depth_pressure, 1, 50)
    late_pressure = segment_average(depth_pressure, 151, 999)

    for entry in enemy_weights:
        enemy_id = int(entry["id"])
        tiers = normalize_tiers(entry["tiers"])
        shifted_tiers = shift_tiers_boundaries(tiers, early_pressure, late_pressure, max_boundary_shift)

        prev = 1
        for idx, ((old_max, old_weight), (new_max, _)) in enumerate(zip(tiers, shifted_tiers)):
            pressure = segment_average(depth_pressure, prev, old_max)
            prev = old_max + 1
            factor = clamp(1.0 + pressure * 0.7, 1 - max_adjustment_percent, 1 + max_adjustment_percent)
            new_weight = bounded_int(old_weight * factor, 0)

            if new_weight != old_weight:
                adjustments.append({
                    "table": "enemy",
                    "file": str(file_path),
                    "enemyId": enemy_id,
                    "tierIndex": idx,
                    "field": "weight",
                    "maxDepth": old_max,
                    "old": old_weight,
                    "new": new_weight,
                })
            if new_max != old_max:
                adjustments.append({
                    "table": "enemy",
                    "file": str(file_path),
                    "enemyId": enemy_id,
                    "tierIndex": idx,
                    "field": "maxDepth",
                    "old": old_max,
                    "new": new_max,
                    "weight": old_weight,
                })

    return adjustments


def propose_item_consumable_rate_adjustments(
    workspace: Path,
    item_tables: core.ItemWeightTables,
    depth_pressure: Dict[int, float],
    max_adjustment_percent: float,
    max_boundary_shift: int,
) -> List[Dict[str, object]]:
    file_path = workspace / "source/Engine/Util/ItemSpecificValues.mc"
    adjustments: List[Dict[str, object]] = []

    early_pressure = segment_average(depth_pressure, 1, 50)
    late_pressure = segment_average(depth_pressure, 151, 999)

    for item_id, tiers_raw in item_tables.consumable_weights.items():
        tiers = normalize_tiers(tiers_raw)
        shifted_tiers = shift_tiers_boundaries(tiers, -early_pressure, -late_pressure, max_boundary_shift)

        prev = 1
        for idx, ((old_max, old_weight), (new_max, _)) in enumerate(zip(tiers, shifted_tiers)):
            pressure = segment_average(depth_pressure, prev, old_max)
            prev = old_max + 1
            factor = clamp(1.0 - pressure * 0.8, 1 - max_adjustment_percent, 1 + max_adjustment_percent)
            new_weight = bounded_int(old_weight * factor, 0)

            if new_weight != old_weight:
                adjustments.append({
                    "table": "item-consumable",
                    "file": str(file_path),
                    "itemId": int(item_id),
                    "tierIndex": idx,
                    "field": "weight",
                    "maxDepth": old_max,
                    "old": old_weight,
                    "new": new_weight,
                })
            if new_max != old_max:
                adjustments.append({
                    "table": "item-consumable",
                    "file": str(file_path),
                    "itemId": int(item_id),
                    "tierIndex": idx,
                    "field": "maxDepth",
                    "old": old_max,
                    "new": new_max,
                    "weight": old_weight,
                })

    return adjustments


def apply_rate_adjustments(adjustments: List[Dict[str, object]]) -> int:
    changed_files = 0
    grouped: Dict[Path, List[Dict[str, object]]] = {}
    for change in adjustments:
        grouped.setdefault(Path(str(change["file"])), []).append(change)

    for file_path, changes in grouped.items():
        text = file_path.read_text(encoding="utf-8")
        updated = text

        for change in changes:
            table = str(change["table"])
            field = str(change["field"])
            old = str(change["old"])
            new = str(change["new"])

            if table == "enemy":
                enemy_id = int(change["enemyId"])
                if field == "weight":
                    max_depth = int(change["maxDepth"])
                    pattern = re.compile(
                        rf"(\:id\s*=>\s*{enemy_id}\s*,.*?\:max\s*=>\s*{max_depth}\s*,\s*\:weight\s*=>\s*){re.escape(old)}(\b)",
                        re.S,
                    )
                    updated = pattern.sub(rf"\g<1>{new}\2", updated, count=1)
                else:
                    weight = int(change["weight"])
                    pattern = re.compile(
                        rf"(\:id\s*=>\s*{enemy_id}\s*,.*?\:max\s*=>\s*){re.escape(old)}(\s*,\s*\:weight\s*=>\s*{weight}\b)",
                        re.S,
                    )
                    updated = pattern.sub(rf"\g<1>{new}\2", updated, count=1)

            elif table == "item-consumable":
                item_id = int(change["itemId"])
                if field == "weight":
                    max_depth = int(change["maxDepth"])
                    pattern = re.compile(
                        rf"({item_id}\s*=>\s*tieredWeight\(depth,\s*\[.*?\:max\s*=>\s*{max_depth}\s*,\s*\:weight\s*=>\s*){re.escape(old)}(\b)",
                        re.S,
                    )
                    updated = pattern.sub(rf"\g<1>{new}\2", updated, count=1)
                else:
                    weight = int(change["weight"])
                    pattern = re.compile(
                        rf"({item_id}\s*=>\s*tieredWeight\(depth,\s*\[.*?\:max\s*=>\s*){re.escape(old)}(\s*,\s*\:weight\s*=>\s*{weight}\b)",
                        re.S,
                    )
                    updated = pattern.sub(rf"\g<1>{new}\2", updated, count=1)

        if updated != text:
            file_path.write_text(updated, encoding="utf-8")
            changed_files += 1

    return changed_files


def write_report(
    workspace: Path,
    config: Dict[str, object],
    depth_win: Dict[int, float],
    depth_target: Dict[int, float],
    adjustments: List[Dict[str, object]],
) -> None:
    out_dir = workspace / "tools/balance"
    out_dir.mkdir(parents=True, exist_ok=True)

    report = {
        "config": config,
        "depthResults": {str(k): {"actualWinRate": depth_win[k], "targetWinRate": depth_target[k]} for k in depth_win},
        "rateAdjustments": adjustments,
    }
    (out_dir / "balance_rates_report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")

    lines = [
        "# Balance Rates Report",
        "",
        "## Depth Win Rates",
        "",
        "| Depth | Actual | Target | Delta |",
        "|---:|---:|---:|---:|",
    ]
    for depth in sorted(depth_win.keys()):
        actual = depth_win[depth]
        target = depth_target[depth]
        lines.append(f"| {depth} | {actual:.3f} | {target:.3f} | {actual - target:+.3f} |")

    lines += [
        "",
        "## Proposed Rate Changes",
        "",
        f"- Total rate changes: {len(adjustments)}",
        f"- Enemy table changes: {sum(1 for x in adjustments if x.get('table') == 'enemy')}",
        f"- Item consumable changes: {sum(1 for x in adjustments if x.get('table') == 'item-consumable')}",
    ]
    (out_dir / "balance_rates_report.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Rates-only auto-balancer for DungeonCrawler")
    parser.add_argument("--workspace", default=".", help="Repo root")
    parser.add_argument("--config", default="tools/balance/balance_rates_config.json", help="Rates config file")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    parser.add_argument("--apply", action="store_true", help="Apply only rate-table changes in source files")
    args = parser.parse_args()

    workspace = Path(args.workspace).resolve()
    config = json.loads((workspace / args.config).read_text(encoding="utf-8"))

    core.random.seed(args.seed)

    strict_realism = True
    variation = config.get("variation", {}) if isinstance(config.get("variation", {}), dict) else {}
    enemy_count_multiplier = float(variation.get("enemyCountMultiplier", 1.0))
    enemy_weight_jitter = float(variation.get("enemyWeightJitter", 0.0))
    item_weight_jitter = float(variation.get("itemWeightJitter", 0.0))
    enemy_budget_scale_by_depth = variation.get("enemyBudgetScaleByDepth", []) if isinstance(variation.get("enemyBudgetScaleByDepth", []), list) else []
    item_drop_scale_by_depth = variation.get("itemDropScaleByDepth", []) if isinstance(variation.get("itemDropScaleByDepth", []), list) else []

    depths = core.resolve_depths(config)
    players = core.parse_player_classes(workspace)
    enemies = core.parse_enemy_files(workspace)
    items_by_class, _ = core.parse_item_files(workspace)
    enemy_weights = core.parse_enemy_weights(workspace)
    class_multipliers = core.parse_class_multipliers(workspace)
    item_tables = core.parse_item_weight_tables(workspace)

    outcomes, _, _, depth_win, depth_target = core.simulate(
        rounds_per_depth=int(config.get("roundsPerDepth", 10)),
        depths=depths,
        target_rules=config["targetWinRateByDepth"],
        players=players,
        enemies=enemies,
        items_by_class=items_by_class,
        enemy_weights=enemy_weights,
        class_multipliers=class_multipliers,
        strict_realism=strict_realism,
        item_tables=item_tables,
        enemy_count_multiplier=enemy_count_multiplier,
        enemy_weight_jitter=enemy_weight_jitter,
        item_weight_jitter=item_weight_jitter,
        enemy_budget_scale_by_depth=enemy_budget_scale_by_depth,
        item_drop_scale_by_depth=item_drop_scale_by_depth,
        rooms_per_depth_for_progression=int(config.get("roomsPerDepthForProgression", 4)),
        initial_attribute_points=int(config.get("initialAttributePoints", 5)),
    )

    depth_pressure = build_depth_pressure(depth_win, depth_target)
    max_adj = float(config.get("maxRateAdjustmentPercentPerRun", 12)) / 100.0
    max_boundary_shift = int(config.get("maxBoundaryShift", 2))

    adjustments: List[Dict[str, object]] = []
    adjustments.extend(
        propose_enemy_rate_adjustments(
            workspace=workspace,
            enemy_weights=enemy_weights,
            depth_pressure=depth_pressure,
            max_adjustment_percent=max_adj,
            max_boundary_shift=max_boundary_shift,
        )
    )
    adjustments.extend(
        propose_item_consumable_rate_adjustments(
            workspace=workspace,
            item_tables=item_tables,
            depth_pressure=depth_pressure,
            max_adjustment_percent=max_adj,
            max_boundary_shift=max_boundary_shift,
        )
    )

    changed_files = 0
    if args.apply:
        changed_files = apply_rate_adjustments(adjustments)

    write_report(workspace, config, depth_win, depth_target, adjustments)

    print("Rates-only balance simulation complete")
    print(f"Encounters simulated: {len(outcomes)}")
    print(f"Proposed rate changes: {len(adjustments)}")
    print(f"EnemySpecificValues changes: {sum(1 for x in adjustments if x.get('table') == 'enemy')}")
    print(f"ItemSpecificValues changes: {sum(1 for x in adjustments if x.get('table') == 'item-consumable')}")
    if args.apply:
        print(f"Files changed: {changed_files}")
    print("Reports: tools/balance/balance_rates_report.json and tools/balance/balance_rates_report.md")


if __name__ == "__main__":
    main()
