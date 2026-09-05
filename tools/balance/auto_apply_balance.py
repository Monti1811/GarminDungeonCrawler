#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


def run_round(workspace: Path, seed: int) -> tuple[int, int, int, int]:
    script = workspace / "tools/balance/auto_balance.py"
    cmd = [sys.executable, str(script), "--workspace", str(workspace), "--apply", "--seed", str(seed)]
    proc = subprocess.run(cmd, cwd=workspace, capture_output=True, text=True)
    if proc.returncode != 0:
        print(proc.stdout)
        print(proc.stderr)
        raise SystemExit(proc.returncode)

    report_path = workspace / "tools/balance/balance_report.json"
    report = json.loads(report_path.read_text(encoding="utf-8"))
    adjustments = report.get("adjustments", {})
    p = len(adjustments.get("players", []))
    e = len(adjustments.get("enemies", []))
    i = len(adjustments.get("items", []))
    s = len(adjustments.get("strictTables", []))
    return p, e, i, s, (p + e + i + s)


def main() -> None:
    parser = argparse.ArgumentParser(description="Runs auto-balance rounds and applies changes automatically")
    parser.add_argument("--workspace", default=".", help="Repo root")
    parser.add_argument("--rounds", type=int, default=3, help="Max apply rounds")
    parser.add_argument("--seed", type=int, default=42, help="Base random seed")
    args = parser.parse_args()

    workspace = Path(args.workspace).resolve()

    for round_idx in range(1, args.rounds + 1):
        p, e, i, s, total = run_round(workspace, args.seed + round_idx - 1)
        print(f"Round {round_idx}: player={p}, enemy={e}, item={i}, strictTable={s}, total={total}")
        if total == 0:
            print("No further adjustments proposed. Stopping.")
            break

    print("Finished auto-apply balance cycle.")


if __name__ == "__main__":
    main()
