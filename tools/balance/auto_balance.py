#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import random
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

ATTRIBUTE_KEYS = ["strength", "constitution", "dexterity", "intelligence", "wisdom", "charisma", "luck"]
ATTACK_WEIGHTS = {
    "STRENGTH": {"strength": 1.0, "constitution": 0.5, "dexterity": 0.25, "intelligence": 0.1, "wisdom": 0.05, "charisma": 0.01, "luck": 0.1},
    "CONSTITUTION": {"strength": 0.5, "constitution": 1.0, "dexterity": 0.25, "intelligence": 0.1, "wisdom": 0.05, "charisma": 0.01, "luck": 0.1},
    "DEXTERITY": {"strength": 0.25, "constitution": 0.5, "dexterity": 1.0, "intelligence": 0.25, "wisdom": 0.1, "charisma": 0.05, "luck": 0.1},
    "CHARISMA": {"strength": 0.01, "constitution": 0.05, "dexterity": 0.1, "intelligence": 0.25, "wisdom": 0.5, "charisma": 1.0, "luck": 0.25},
    "INTELLIGENCE": {"strength": 0.1, "constitution": 0.25, "dexterity": 0.5, "intelligence": 1.0, "wisdom": 0.5, "charisma": 0.25, "luck": 1.0},
    "WISDOM": {"strength": 0.05, "constitution": 0.1, "dexterity": 0.25, "intelligence": 0.5, "wisdom": 1.0, "charisma": 0.5, "luck": 0.25},
}

MAX_ENEMIES_PER_ROOM = 15
DEFAULT_MIN_ROOM_SIZE = 5
DEFAULT_MAX_ROOM_SIZE = 15
ITEM_TYPE_WEIGHTS = ((0, 20), (1, 20), (2, 40), (3, 5))  # Main.mc getItemType


@dataclass
class Enemy:
    id: int
    name: str
    file: Path
    damage: int
    armor: int
    max_health: int
    kill_experience: int
    attack_cooldown: int = 2


@dataclass
class Item:
    id: int
    class_name: str
    file: Path
    kind: str  # weapon|armor
    attack: int = 0
    defense: int = 0
    value: int = 0
    attack_type: str = "STRENGTH"
    defense_type: str = "CONSTITUTION"
    mana_loss: float = 0.0
    active_attack: int = 0
    inactive_attack: int = 0
    uses_ammo: bool = False
    ammo_attack: int = 0
    ammo_type: str = "ARROW"
    attribute_bonus: Dict[str, int] = field(default_factory=dict)


@dataclass
class PlayerClass:
    id: int
    class_name: str
    file: Path
    current_health: int
    max_health: int
    max_mana: int
    current_mana: int
    starting_ammo: int
    attributes: Dict[str, int]
    starting_items: List[str]
    level_health_gain: int
    level_mana_gain: int


@dataclass
class EncounterOutcome:
    class_id: int
    depth: int
    enemy_id: int
    win: bool


@dataclass
class ItemWeightTables:
    weapon_weights: Dict[int, List[Tuple[int, float]]]
    armor_weights: Dict[int, List[Tuple[int, float]]]
    consumable_weights: Dict[int, List[Tuple[int, float]]]
    method_bodies: Dict[str, str] = field(default_factory=dict)
    class_item_multipliers: Dict[int, Dict[int, float]] = field(default_factory=dict)
    _base_cache: Dict[int, List[Dict[int, float]]] = field(default_factory=dict)
    _class_cache: Dict[Tuple[int, int], List[Dict[int, float]]] = field(default_factory=dict)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def extract_function_body(text: str, function_name: str) -> Optional[str]:
    marker = f"function {function_name}"
    start = text.find(marker)
    if start < 0:
        return None
    brace_open = text.find("{", start)
    if brace_open < 0:
        return None
    depth = 0
    i = brace_open
    while i < len(text):
        c = text[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return text[brace_open + 1 : i]
        i += 1
    return None


def parse_number_assignment(body: str, key: str, default: int) -> int:
    m = re.search(rf"(?:self\.)?{re.escape(key)}\s*=\s*(-?\d+)\s*;", body)
    if m:
        return int(m.group(1))
    m = re.search(rf"var\s+{re.escape(key)}\s+as\s+\w+\s*=\s*(-?\d+)\s*;", body)
    return int(m.group(1)) if m else default


def parse_attributes_dict(body: str) -> Dict[str, int]:
    m = re.search(r"self\.attributes\s*=\s*\{(.*?)\};", body, re.S)
    values = {k: 0 for k in ATTRIBUTE_KEYS}
    if not m:
        return values
    block = m.group(1)
    for att, val in re.findall(r":([a-zA-Z_]+)\s*=>\s*(-?\d+)", block):
        if att in values:
            values[att] = int(val)
    return values


def normalize_start_attributes(
    attributes: Dict[str, int],
    attr_min: int,
    attr_max: int,
    attr_sum: int,
) -> Dict[str, int]:
    """Clamp each start attribute into [min, max] and redistribute so total == sum."""
    clamped = {k: int(clamp(int(attributes.get(k, 0)), attr_min, attr_max)) for k in ATTRIBUTE_KEYS}
    total = sum(clamped.values())
    if total == attr_sum:
        return clamped

    # Redistribute excess/deficit while respecting bounds (stable order, luck last).
    order = [k for k in ATTRIBUTE_KEYS if k != "luck"] + (["luck"] if "luck" in clamped else [])
    while total != attr_sum:
        delta = 1 if total < attr_sum else -1
        moved = False
        for key in order:
            new_val = clamped[key] + delta
            if attr_min <= new_val <= attr_max:
                clamped[key] = new_val
                total += delta
                moved = True
                break
        if not moved:
            break
    return clamped


def parse_attribute_bonus_dict(body: str) -> Dict[str, int]:
    m = re.search(r"attribute_bonus\s*=\s*\{(.*?)\};", body, re.S)
    result: Dict[str, int] = {}
    if not m:
        return result
    for att, val in re.findall(r":([a-zA-Z_]+)\s*=>\s*(-?\d+)", m.group(1)):
        result[att] = int(val)
    return result


def enemy_effective_attack_period(energy_per_turn: int, attack_cooldown: int) -> int:
    """Port of Turn.mc energy gating.

    An enemy only acts while energy >= Constants.MIN_ENERGY_PER_TURN (100), spends it and
    regains energy_per_turn afterwards (clamped to 100); attack_cooldown ticks down on every
    turn. Returns the resulting attack period in turns (Ogre: 34 energy -> every 3 turns).
    """
    if energy_per_turn <= 0 or attack_cooldown <= 0:
        return max(1, attack_cooldown)
    energy = 100
    cooldown = 0
    first_attack = -1
    for turn in range(1, 1000):
        if energy >= 100:
            if cooldown == 0:
                cooldown = attack_cooldown
                if first_attack < 0:
                    first_attack = turn
                else:
                    return turn - first_attack
            energy -= 100
        energy = min(100, energy + energy_per_turn)
        if cooldown > 0:
            cooldown -= 1
    return max(1, attack_cooldown)


def parse_enemy_files(workspace: Path) -> Dict[int, Enemy]:
    enemies_dir = workspace / "source/Engine/Entities/Enemies"
    defaults: Dict[str, int] = {
        "damage": 10,
        "armor": 0,
        "max_health": 100,
        "kill_experience": 10,
        "attack_cooldown": 2,
        "energy_per_turn": 100,
    }
    classes: Dict[str, Dict[str, Any]] = {}
    for file in enemies_dir.rglob("*.mc"):
        if file.name in {"Enemy.mc", "Enemies.mc"}:
            continue
        text = read(file)
        class_match = re.search(r"class\s+(\w+)\s+extends\s+(\w+)", text)
        if not class_match:
            continue
        body = extract_function_body(text, "initialize")
        if not body:
            continue
        classes[class_match.group(1)] = {
            "parent": class_match.group(2),
            "file": file,
            "body": body,
        }

    resolved: Dict[str, Dict[str, Any]] = {}

    def resolve(class_name: str, seen: Tuple[str, ...] = ()) -> Dict[str, Any]:
        """Resolve stats of a class, inheriting everything its base class defines."""
        if class_name in resolved:
            return resolved[class_name]
        entry = classes.get(class_name)
        if entry is None or class_name in seen:
            values: Dict[str, Any] = dict(defaults)
            resolved.setdefault(class_name, values)
            return values
        body = str(entry["body"])
        values = dict(resolve(str(entry["parent"]), seen + (class_name,)))
        values["file"] = entry["file"]
        enemy_id = parse_number_assignment(body, "id", -1)
        if enemy_id >= 0:
            values["id"] = enemy_id
        name_match = re.search(r"name\s*=\s*\"([^\"]+)\"\s*;", body)
        if name_match:
            values["name"] = name_match.group(1)
        elif "name" not in values:
            values["name"] = Path(str(entry["file"])).stem
        for key in ("damage", "armor", "kill_experience", "attack_cooldown", "energy_per_turn"):
            value = parse_number_assignment(body, key, -1)
            if value >= 0:
                values[key] = value
        max_health = parse_number_assignment(body, "maxHealth", -1)
        if max_health < 0:
            max_health = parse_number_assignment(body, "current_health", -1)
        if max_health >= 0:
            values["max_health"] = max_health
        resolved[class_name] = values
        return values

    parsed: Dict[int, Enemy] = {}
    for class_name in classes:
        values = resolve(class_name)
        enemy_id = values.get("id")
        if enemy_id is None:
            continue
        energy_per_turn = int(values.get("energy_per_turn", defaults["energy_per_turn"]))
        attack_cooldown = int(values.get("attack_cooldown", defaults["attack_cooldown"]))
        parsed[int(enemy_id)] = Enemy(
            id=int(enemy_id),
            name=str(values.get("name", class_name)),
            file=values["file"],
            damage=int(values.get("damage", defaults["damage"])),
            armor=int(values.get("armor", defaults["armor"])),
            max_health=int(values.get("max_health", defaults["max_health"])),
            kill_experience=int(values.get("kill_experience", defaults["kill_experience"])),
            attack_cooldown=enemy_effective_attack_period(energy_per_turn, attack_cooldown),
        )
    return parsed


def parse_item_files(workspace: Path) -> Tuple[Dict[str, Item], Dict[int, Item]]:
    items_dir = workspace / "source/Engine/Items"
    by_class: Dict[str, Item] = {}
    by_id: Dict[int, Item] = {}
    for file in items_dir.rglob("*.mc"):
        if file.name in {"Item.mc", "EquippableItem.mc", "WeaponItem.mc", "ArmorItem.mc", "ConsumableItem.mc", "KeyItem.mc", "Items.mc", "Bow.mc", "CrossBow.mc", "Ammunition.mc", "Spell.mc", "Staff.mc"}:
            continue
        text = read(file)
        class_match = re.search(r"class\s+(\w+)\s+extends\s+(\w+)", text)
        if not class_match:
            continue
        class_name, parent = class_match.groups()
        weapon_parents = {"WeaponItem", "Bow", "CrossBow", "Ammunition", "Spell", "Staff"}
        armor_parents = {"ArmorItem"}
        if parent not in weapon_parents and parent not in armor_parents:
            continue
        body = extract_function_body(text, "initialize")
        if not body:
            continue
        item_id = parse_number_assignment(body, "id", -1)
        if item_id < 0:
            continue
        mana_loss = parse_number_assignment(body, "mana_loss", 0) * 0.5
        active_attack = 0
        inactive_attack = 0
        activate_body = extract_function_body(text, "activateStaff") or extract_function_body(text, "activateSpell")
        deactivate_body = extract_function_body(text, "deactivateStaff") or extract_function_body(text, "deactivateSpell")
        if activate_body:
            active_attack = parse_number_assignment(activate_body, "attack", 0)
        if deactivate_body:
            inactive_attack = parse_number_assignment(deactivate_body, "attack", 0)
        uses_ammo = parent in {"Bow", "CrossBow"} or "extends Bow" in text
        ammo_type_match = re.search(r"ammunition_type\s*=\s*(\w+)\s*;", body)
        ammo_attack = parse_number_assignment(body, "attack", 0)
        item = Item(
            id=item_id,
            class_name=class_name,
            file=file,
            kind="weapon" if parent in weapon_parents else "armor",
            attack=parse_number_assignment(body, "attack", 0),
            defense=parse_number_assignment(body, "defense", 0),
            value=parse_number_assignment(body, "value", 0),
            attack_type=(re.search(r"attack_type\s*=\s*(\w+)\s*;", body).group(1) if re.search(r"attack_type\s*=\s*(\w+)\s*;", body) else "STRENGTH"),
            defense_type=(re.search(r"defense_type\s*=\s*(\w+)\s*;", body).group(1) if re.search(r"defense_type\s*=\s*(\w+)\s*;", body) else "CONSTITUTION"),
            mana_loss=mana_loss,
            active_attack=active_attack,
            inactive_attack=inactive_attack,
            uses_ammo=uses_ammo,
            ammo_attack=ammo_attack,
            ammo_type=(ammo_type_match.group(1) if ammo_type_match else "ARROW"),
            attribute_bonus=parse_attribute_bonus_dict(body),
        )
        by_class[class_name] = item
        by_id[item_id] = item
    return by_class, by_id


def parse_player_classes(workspace: Path) -> Dict[int, PlayerClass]:
    classes_dir = workspace / "source/Engine/Entities/Player/Classes"
    parsed: Dict[int, PlayerClass] = {}
    for file in classes_dir.glob("*.mc"):
        text = read(file)
        if "extends Player" not in text:
            continue
        class_match = re.search(r"class\s+(\w+)\s+extends\s+Player", text)
        if not class_match:
            continue
        class_name = class_match.group(1)
        body = extract_function_body(text, "initialize")
        if not body:
            continue
        player_id = parse_number_assignment(body, "id", -1)
        if player_id < 0 or player_id == 999:
            continue
        current_health = parse_number_assignment(body, "current_health", 30)
        max_health = parse_number_assignment(body, "maxHealth", current_health)
        max_mana = parse_number_assignment(body, "maxMana", 0)
        if max_mana == 0:
            max_mana = parse_number_assignment(text, "maxMana", 0)
        current_mana = parse_number_assignment(body, "current_mana", max_mana)
        if current_mana == 0 and max_mana > 0:
            current_mana = parse_number_assignment(text, "current_mana", max_mana)
        attributes = parse_attributes_dict(body)
        starting_items = re.findall(r"self\.equipItem\(new\s+(\w+)\(\)", body)
        level_up_body = extract_function_body(text, "onLevelUp") or ""
        level_health_gain = sum(int(v) for v in re.findall(r"maxHealth\s*\+=\s*(\d+)\s*;", level_up_body))
        level_mana_gain = sum(int(v) for v in re.findall(r"maxMana\s*\+=\s*(\d+)\s*;", level_up_body))
        starting_ammo = 0
        ammo_match = re.search(r"\.setAmount\((\d+)\)", body)
        if ammo_match:
            starting_ammo = int(ammo_match.group(1))
        parsed[player_id] = PlayerClass(
            id=player_id,
            class_name=class_name,
            file=file,
            current_health=current_health,
            max_health=max_health,
            max_mana=max_mana,
            current_mana=current_mana,
            starting_ammo=starting_ammo,
            attributes=attributes,
            starting_items=starting_items,
            level_health_gain=level_health_gain,
            level_mana_gain=level_mana_gain,
        )
    return parsed


def parse_enemy_weights(workspace: Path) -> List[Dict[str, object]]:
    text = read(workspace / "source/Engine/Util/EnemySpecificValues.mc")
    entries = []
    pattern = re.compile(r"\{:id\s*=>\s*(\d+),\s*:cost\s*=>\s*(\d+),\s*:weight\s*=>\s*tieredWeight\(depth,\s*\[(.*?)\]\)\}\s*", re.S)
    for m in pattern.finditer(text):
        enemy_id = int(m.group(1))
        cost = int(m.group(2))
        tiers = [(int(a), float(b)) for a, b in re.findall(r":max\s*=>\s*(\d+),\s*:weight\s*=>\s*([\d.]+)", m.group(3))]
        if tiers:
            entries.append({"id": enemy_id, "cost": cost, "tiers": tiers})
    return entries


def parse_class_multipliers(workspace: Path) -> Dict[int, Dict[int, float]]:
    text = read(workspace / "source/Engine/Util/EnemySpecificValues.mc")
    multipliers: Dict[int, Dict[int, float]] = {}
    case_pattern = re.compile(r"case\s+(\d+)\s*:\s*(.*?)(?=\n\s*case\s+\d+\s*:|\n\s*default\s*:)", re.S)
    for cm in case_pattern.finditer(text):
        class_id = int(cm.group(1))
        block = cm.group(2)
        entries = {int(enemy_id): float(mult) for enemy_id, mult in re.findall(r"(\d+)\s*=>\s*([\d.]+)", block)}
        multipliers[class_id] = entries
    return multipliers


ITEM_TABLE_METHODS = (
    "buildWeaponWeights",
    "buildArmorWeights",
    "buildConsumableWeights",
    "buildHighQualityWeights",
    "buildMerchantWeights",
)


def extract_method_body_from(text: str, method_name: str) -> str:
    pattern = re.compile(rf"private\s+function\s+{re.escape(method_name)}\s*\(.*?\)\s*as\s*[^{{]+\{{", re.S)
    m = pattern.search(text)
    if not m:
        return ""
    open_brace = text.find("{", m.start())
    depth = 0
    i = open_brace
    while i < len(text):
        c = text[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return text[open_brace + 1 : i]
        i += 1
    return ""


def parse_item_tiered_table(body: str) -> Dict[int, List[Tuple[int, float]]]:
    table: Dict[int, List[Tuple[int, float]]] = {}
    entry_re = re.compile(r"(\d+)\s*=>\s*tieredWeight\(depth,\s*\[(.*?)\]\)", re.S)
    tier_re = re.compile(r":max\s*=>\s*(\d+)\s*,\s*:weight\s*=>\s*([\d.]+)")
    for entry in entry_re.finditer(body):
        item_id = int(entry.group(1))
        tiers = [(int(a), float(b)) for a, b in tier_re.findall(entry.group(2))]
        if tiers:
            table[item_id] = tiers
    return table


_ITEM_TIER_RE = re.compile(r":max\s*=>\s*(\d+)\s*,\s*:weight\s*=>\s*([\d.]+)")


def _item_tiers_from_text(text: str) -> List[Tuple[int, float]]:
    return [(int(a), float(b)) for a, b in _ITEM_TIER_RE.findall(text)]


def _format_item_tiers(tiers: List[Tuple[int, float]]) -> str:
    parts = []
    for tier_max, weight in tiers:
        w = str(int(weight)) if float(weight).is_integer() else f"{weight:g}"
        parts.append(f"≤{int(tier_max)}: {w}")
    return ", ".join(parts)


def parse_item_inline_tiers(body: str) -> Dict[int, List[Tuple[int, float]]]:
    """id => tieredWeight(...) entries of a method body, keyed by item id."""
    table: Dict[int, List[Tuple[int, float]]] = {}
    if not body:
        return table
    for m in re.finditer(r"(\d+)\s*=>\s*tieredWeight\(depth,\s*\[(.*?)\]\)", body, re.S):
        table[int(m.group(1))] = _item_tiers_from_text(m.group(2))
    return table


def parse_item_weight_report(
    body: str,
    cross_tiers: Optional[Dict[int, List[Tuple[int, float]]]] = None,
) -> List[Tuple[str, List[int], str]]:
    """Parse a build*Weights method body into report rows: (weight_expr, sorted_item_ids, tiers_text).

    Handles var-based tables (`var steel_weight = tieredWeight(...)` + `0 => steel_weight`),
    aliases (`var bolt_weight = arrow_weight`), scaled refs (`water_weight / 2`),
    cross-table refs (`consumable_weights[2004] / 2`) and non-tiered formulas.
    """
    if not body:
        return []

    var_tiers: Dict[str, List[Tuple[int, float]]] = {}
    aliases: Dict[str, str] = {}
    consumed: List[Tuple[int, int]] = []

    for m in re.finditer(r"var\s+(\w+)\s*=\s*tieredWeight\(depth,\s*\[(.*?)\]\)\s*;", body, re.S):
        var_tiers[m.group(1)] = _item_tiers_from_text(m.group(2))
        consumed.append(m.span())
    for m in re.finditer(r"var\s+(\w+)\s*=\s*(\w+)\s*;", body):
        if not any(start <= m.start() < end for start, end in consumed):
            aliases[m.group(1)] = m.group(2)

    def lookup(name: str, guard: int = 0) -> Optional[List[Tuple[int, float]]]:
        if name in var_tiers:
            return var_tiers[name]
        if name in aliases and guard < 5:
            return lookup(aliases[name], guard + 1)
        return None

    def resolve(expr: str) -> Optional[List[Tuple[int, float]]]:
        e = expr.strip()
        m = re.fullmatch(r"(\w+)\s*/\s*(\d+)", e)
        if m and int(m.group(2)) > 0:
            tiers = lookup(m.group(1))
            if tiers is not None:
                div = int(m.group(2))
                return [(tier_max, weight / div) for tier_max, weight in tiers]
        m = re.fullmatch(r"(\w+)\[(\d+)\](?:\s*/\s*(\d+))?", e)
        if m and m.group(1) == "consumable_weights" and cross_tiers is not None:
            tiers = cross_tiers.get(int(m.group(2)))
            if tiers is not None:
                div = int(m.group(3)) if m.group(3) else 1
                return [(tier_max, weight / div) for tier_max, weight in tiers]
        return lookup(e)

    groups: Dict[str, Tuple[str, List[int], Optional[List[Tuple[int, float]]]]] = {}

    def add_entry(key: str, display: str, item_id: int, tiers: Optional[List[Tuple[int, float]]]) -> None:
        if key in groups:
            groups[key][1].append(item_id)
        else:
            groups[key] = (display, [item_id], tiers)

    spans: List[Tuple[int, int]] = list(consumed)

    for m in re.finditer(r"(\d+)\s*=>\s*tieredWeight\(depth,\s*\[(.*?)\]\)", body, re.S):
        tiers = _item_tiers_from_text(m.group(2))
        add_entry("inline:" + repr(tiers), "inline", int(m.group(1)), tiers)
        spans.append(m.span())

    for m in re.finditer(r"^\s*(\d+)\s*=>\s*(.+?),?\s*$", body, re.M):
        if any(start <= m.start(1) < end for start, end in spans):
            continue
        expr = m.group(2).strip().rstrip(",").strip()
        if expr.startswith("tieredWeight"):
            continue
        add_entry("expr:" + expr, expr, int(m.group(1)), resolve(expr))

    rows = []
    for _, (display, ids, tiers) in sorted(groups.items(), key=lambda kv: min(kv[1][1])):
        tiers_text = _format_item_tiers(tiers) if tiers else "—"
        rows.append((display, sorted(ids), tiers_text))
    return rows


def parse_class_item_multipliers(text: str) -> Dict[int, Dict[int, float]]:
    multipliers: Dict[int, Dict[int, float]] = {}
    fn = extract_function_body(text, "getClassItemMultipliers")
    if not fn:
        return multipliers
    case_pattern = re.compile(r"case\s+(\d+)\s*:\s*(.*?)(?=\n\s*case\s+\d+\s*:|\n\s*default\s*:|\Z)", re.S)
    add_re = re.compile(r"addMultipliers\s*\(\s*m\s*,\s*\[([^\]]*)\]\s*,\s*([\d.]+)\s*\)", re.S)
    for cm in case_pattern.finditer(fn):
        class_id = int(cm.group(1))
        entries: Dict[int, float] = {}
        for ids_raw, factor in add_re.findall(cm.group(2)):
            factor_f = float(factor)
            for id_str in ids_raw.split(","):
                id_str = id_str.strip()
                if id_str:
                    entries[int(id_str)] = factor_f
        multipliers[class_id] = entries
    return multipliers


class MonkeyMath:
    """Toybox Math subset used by ItemSpecificValues weight expressions."""

    @staticmethod
    def log(value: float, base: Optional[float] = None) -> float:
        if base is None:
            return math.log(value)
        return math.log(value, base)


_TIERED_CALL_RE = re.compile(r"tieredWeight\s*\(\s*depth\s*,\s*\[(.*?)\]\s*\)", re.S)
_TIER_PAIR_RE = re.compile(r":max\s*=>\s*(\d+)\s*,\s*:weight\s*=>\s*([-\d.]+)")
_CONSUMABLE_REF_RE = re.compile(r"consumable_weights\s*\[\s*(\d+)\s*\]")
_VAR_DECL_RE = re.compile(r"\bvar\s+([A-Za-z_]\w*)\s*=\s*(.*?);", re.S)


def eval_item_expr(expr: str, depth: int, env: Dict[str, float], consumable: Dict[int, float]) -> float:
    def repl_tiered(m: "re.Match[str]") -> str:
        tiers = [(int(a), float(b)) for a, b in _TIER_PAIR_RE.findall(m.group(1))]
        return repr(tiered_weight(depth, tiers))

    expr = _TIERED_CALL_RE.sub(repl_tiered, expr)
    expr = _CONSUMABLE_REF_RE.sub(lambda m: repr(float(consumable.get(int(m.group(1)), 0.0))), expr)
    try:
        return float(eval(expr, {"__builtins__": {}}, {"depth": depth, "Math": MonkeyMath, **env}))  # noqa: S307
    except Exception:
        return 0.0


def extract_dict_entries(block: str) -> List[Tuple[int, str]]:
    entries: List[Tuple[int, str]] = []
    head_re = re.compile(r"(\d+)\s*=>")
    m = head_re.search(block)
    while m:
        j = m.end()
        level = 0
        while j < len(block):
            c = block[j]
            if c in "([":
                level += 1
            elif c in ")]":
                level -= 1
            elif level == 0 and (c == "," or c == "}"):
                break
            j += 1
        expr = block[m.end() : j].strip().split("//")[0].strip()
        if expr:
            entries.append((int(m.group(1)), expr))
        m = head_re.search(block, j)
    return entries


def extract_brace_block_after(text: str, position: int) -> str:
    brace = text.find("{", position)
    if brace < 0:
        return ""
    level = 0
    i = brace
    while i < len(text):
        c = text[i]
        if c in "{[(":
            level += 1
        elif c in "}])":
            level -= 1
            if level == 0:
                return text[brace + 1 : i]
        i += 1
    return ""


def extract_return_entries(body: str) -> List[Tuple[int, str]]:
    idx = body.find("return")
    if idx < 0:
        return []
    return extract_dict_entries(extract_brace_block_after(body, idx))


_DICT_VAR_RE = re.compile(r"\bvar\s+[A-Za-z_]\w*\s*=\s*\{")


def extract_dict_var_entries(body: str) -> List[Tuple[int, str]]:
    m = _DICT_VAR_RE.search(body)
    if not m:
        return []
    return extract_dict_entries(extract_brace_block_after(body, m.start()))


def eval_item_table(body: str, depth: int, consumable: Optional[Dict[int, float]] = None) -> Dict[int, float]:
    if not body:
        return {}
    cons = consumable or {}
    env: Dict[str, float] = {}
    for name, expr in _VAR_DECL_RE.findall(body):
        expr = expr.strip()
        if expr.startswith("{"):
            continue
        env[name] = eval_item_expr(expr, depth, env, cons)
    entries = extract_return_entries(body)
    if not entries:
        entries = extract_dict_var_entries(body)
    return {item_id: eval_item_expr(expr, depth, env, cons) for item_id, expr in entries}


def item_drop_tables(tables: ItemWeightTables, depth: int) -> List[Dict[int, float]]:
    cached = tables._base_cache.get(depth)
    if cached is None:
        consumable = eval_item_table(tables.method_bodies.get("buildConsumableWeights", ""), depth)
        cached = [
            eval_item_table(tables.method_bodies.get("buildWeaponWeights", ""), depth),
            eval_item_table(tables.method_bodies.get("buildArmorWeights", ""), depth),
            consumable,
            eval_item_table(tables.method_bodies.get("buildHighQualityWeights", ""), depth, consumable),
        ]
        tables._base_cache[depth] = cached
    return cached


def item_drop_tables_for_class(tables: ItemWeightTables, depth: int, class_id: int) -> List[Dict[int, float]]:
    key = (depth, class_id)
    cached = tables._class_cache.get(key)
    if cached is None:
        multipliers = tables.class_item_multipliers.get(class_id, {})
        cached = [
            {item_id: weight * multipliers.get(item_id, 1.0) for item_id, weight in table.items()}
            for table in item_drop_tables(tables, depth)
        ]
        tables._class_cache[key] = cached
    return cached


def parse_item_weight_tables(workspace: Path) -> ItemWeightTables:
    text = read(workspace / "source/Engine/Util/ItemSpecificValues.mc")
    bodies = {name: extract_method_body_from(text, name) for name in ITEM_TABLE_METHODS}
    return ItemWeightTables(
        weapon_weights=parse_item_tiered_table(bodies["buildWeaponWeights"]),
        armor_weights=parse_item_tiered_table(bodies["buildArmorWeights"]),
        consumable_weights=parse_item_tiered_table(bodies["buildConsumableWeights"]),
        method_bodies=bodies,
        class_item_multipliers=parse_class_item_multipliers(text),
    )


def resolve_depths(config: Dict[str, object]) -> List[int]:
    if "depthRange" in config and isinstance(config["depthRange"], dict):
        depth_range = config["depthRange"]
        start = int(depth_range.get("start", 1))
        end = int(depth_range.get("end", 200))
        step = int(depth_range.get("step", 1))
        if step <= 0:
            step = 1
        return list(range(start, end + 1, step))
    if "depths" in config:
        return [int(x) for x in config["depths"]]
    return list(range(1, 201))


def tiered_weight(depth: int, tiers: List[Tuple[int, float]]) -> float:
    for max_depth, weight in tiers:
        if depth <= max_depth:
            return weight
    return tiers[-1][1] if tiers else 0.0


def target_for_depth(depth: int, rules: List[Dict[str, float]]) -> float:
    for rule in rules:
        if depth <= int(rule["maxDepth"]):
            return float(rule["target"])
    return float(rules[-1]["target"])


def value_for_depth(depth: int, rules: List[Dict[str, float]], default_value: float) -> float:
    if not rules:
        return default_value
    for rule in rules:
        if depth <= int(rule.get("maxDepth", 0)):
            return float(rule.get("value", default_value))
    return float(rules[-1].get("value", default_value))


def clamp(v: float, mn: float, mx: float) -> float:
    return max(mn, min(mx, v))


def calc_damage(base_damage: float, defense: float) -> int:
    if base_damage <= 0:
        return 1
    reduction = defense / (defense + base_damage)
    reduction = clamp(reduction, 0.0, 0.90)
    return max(1, int(round(base_damage * (1.0 - reduction))))


def attribute_point_cost_for_level(level: int) -> int:
    """Match Game's getAttributePointCostForLevel: cost = 1 + floor(level/10), clamped 1-10."""
    return max(1, min(10, 1 + level // 10))


def distribute_attribute_points(base_attributes: Dict[str, int], points: int) -> Dict[str, int]:
    if points <= 0:
        return dict(base_attributes)
    out = dict(base_attributes)
    remaining = points
    while remaining > 0:
        best_attr = None
        best_cost = remaining + 1
        for key in ATTRIBUTE_KEYS:
            cost = attribute_point_cost_for_level(out.get(key, 0))
            if cost <= remaining and cost < best_cost:
                best_cost = cost
                best_attr = key
        if best_attr is None:
            break
        out[best_attr] = out.get(best_attr, 0) + 1
        remaining -= best_cost
    return out


def expected_enemy_profile_for_depth(
    depth: int,
    class_id: int,
    enemies: Dict[int, Enemy],
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
    enemy_depth_scaling: Optional[Dict[str, object]] = None,
) -> Tuple[float, float]:
    multipliers = class_multipliers.get(class_id, {})
    total_weight = 0.0
    weighted_xp = 0.0
    weighted_cost = 0.0
    for entry in enemy_weights:
        enemy_id = int(entry["id"])
        if enemy_id not in enemies:
            continue
        base_weight = tiered_weight(depth, entry["tiers"])
        if base_weight <= 0:
            continue
        final_weight = base_weight * multipliers.get(enemy_id, 1.0)
        if final_weight <= 0:
            continue
        enemy = scale_enemy_for_depth(enemies[enemy_id], depth, enemy_depth_scaling or {})
        total_weight += final_weight
        weighted_xp += final_weight * enemy.kill_experience
        weighted_cost += final_weight * int(entry["cost"])
    if total_weight <= 0:
        return 0.0, 1.0
    return weighted_xp / total_weight, max(1.0, weighted_cost / total_weight)


# --- Item progression by depth ---
# Maps item IDs to (name, min_depth) for the best items per slot per tier.
# One new tier every 10 depths:
#   Tier 0 Steel:  depth 1+
#   Tier 1 Bronze: depth 11+
#   Tier 2 Fire:   depth 21+
#   Tier 3 Ice:    depth 31+
#   Tier 4 Grass:  depth 41+
#   Tier 5 Water:  depth 51+
#   Tier 6 Gold:   depth 61+
#   Tier 7 Demon:  depth 71+
#   Tier 8 Blood:  depth 81+

# Weapon IDs: each tier has 9 weapons (Axe=0, Bow=1, Dagger=2, Greatsword=3,
# Katana=4, Lance/Spear=5, Spell=6, Staff=7, Sword=8) within a tier block of 10.
# We pick one representative weapon per tier (Sword = *8).
TIERED_WEAPONS = [
    # (item_id, min_depth) – ordered by depth
    (8,   1),   # SteelSword
    (18, 11),   # BronzeSword
    (28, 21),   # FireSword
    (38, 31),   # IceSword
    (48, 35),   # GrassSword
    (58, 42),   # WaterSword
    (68, 61),   # GoldSword
    (78, 71),   # DemonSword
    (88, 81),   # BloodSword
]

# For Bows (position 1 in each tier block)
TIERED_BOWS = [
    (1,   1),   # SteelBow
    (11, 11),   # BronzeBow
    (21, 21),   # FireBow
    (31, 31),   # IceBow
    (41, 35),   # GrassBow
    (51, 42),   # WaterBow
    (61, 61),   # GoldBow
    (71, 71),   # DemonBow
    (81, 81),   # BloodBow
]

# Armor IDs: each tier has 6 armor pieces (Helmet=0, BreastPlate=1, Gauntlets=2,
# Shoes=3, Ring1=4, Ring2=5) within a tier block of 10, starting at 1000.
# We pick BreastPlate (defense) and Ring (attribute bonus) per tier.
TIERED_BREASTPLATES = [
    (1001,  1),  # SteelBreastPlate
    (1011, 11),  # BronzeBreastPlate
    (1021, 21),  # FireBreastPlate
    (1031, 31),  # IceBreastPlate
    (1041, 35),  # GrassBreastPlate
    (1051, 42),  # WaterBreastPlate
    (1061, 61),  # GoldBreastPlate
    (1071, 71),  # DemonBreastPlate
    (1081, 81),  # BloodBreastPlate
]

TIERED_RINGS = [
    (1004,  1),  # SteelRing1
    (1014, 11),  # BronzeRing1
    (1024, 21),  # FireRing1
    (1034, 31),  # IceRing1
    (1044, 35),  # GrassRing1
    (1054, 42),  # WaterRing1
    (1064, 61),  # GoldRing1
    (1074, 71),  # DemonRing1
    (1084, 81),  # BloodRing1
]

# Full armor set: Helmet (slot 0), Gauntlets (slot 2), Shoes (slot 3) per tier block.
TIERED_HELMETS = [
    (1000,  1),  # SteelHelmet
    (1010, 11),  # BronzeHelmet
    (1020, 21),  # FireHelmet
    (1030, 31),  # IceHelmet
    (1040, 35),  # GrassHelmet
    (1050, 42),  # WaterHelmet
    (1060, 61),  # GoldHelmet
    (1070, 71),  # DemonHelmet
    (1080, 81),  # BloodHelmet
]

TIERED_GAUNTLETS = [
    (1002,  1),  # SteelGauntlets
    (1012, 11),  # BronzeGauntlets
    (1022, 21),  # FireGauntlets
    (1032, 31),  # IceGauntlets
    (1042, 35),  # GrassGauntlets
    (1052, 42),  # WaterGauntlets
    (1062, 61),  # GoldGauntlets
    (1072, 71),  # DemonGauntlets
    (1082, 81),  # BloodGauntlets
]

TIERED_BOOTS = [
    (1003,  1),  # SteelShoes
    (1013, 11),  # BronzeShoes
    (1023, 21),  # FireShoes
    (1033, 31),  # IceShoes
    (1043, 35),  # GrassShoes
    (1053, 42),  # WaterShoes
    (1063, 61),  # GoldShoes
    (1073, 71),  # DemonShoes
    (1083, 81),  # BloodShoes
]


def _best_item_at_depth(table: List[Tuple[int, int]], depth: int, items_by_id: Dict[int, Item]) -> Optional[Item]:
    """Return the best (highest-ID) item from a tiered table available at the given depth."""
    best = None
    for item_id, min_depth in table:
        if depth >= min_depth and item_id in items_by_id:
            best = items_by_id[item_id]
    return best


def get_items_for_depth(
    player: PlayerClass,
    class_id: int,
    depth: int,
    items_by_class: Dict[str, Item],
    items_by_id: Dict[int, Item],
) -> List[Item]:
    """Determine the best equipment a player would have at a given depth.

    Uses starting items as a baseline and upgrades individual slots when
    better tiered items become available at the current depth.
    """
    # Start with the player's starting items
    equipped = [items_by_class[name] for name in player.starting_items if name in items_by_class]

    # Determine weapon type from starting weapon
    uses_ranged = any(x.kind == "weapon" and x.uses_ammo for x in equipped)
    tiered_weapons = TIERED_BOWS if uses_ranged else TIERED_WEAPONS

    # Upgrade weapon
    best_weapon = _best_item_at_depth(tiered_weapons, depth, items_by_id)
    if best_weapon is not None:
        # Replace existing weapon
        new_equipped = [x for x in equipped if x.kind != "weapon"]
        new_equipped.append(best_weapon)
        equipped = new_equipped

    # Upgrade breastplate (best defense)
    best_bp = _best_item_at_depth(TIERED_BREASTPLATES, depth, items_by_id)
    if best_bp is not None:
        new_equipped = [x for x in equipped if not (x.kind == "armor" and x.defense > 0 and x.class_name != "LifeAmulet" and x.class_name != "ManaCrystal")]
        new_equipped.append(best_bp)
        equipped = new_equipped

    # Upgrade ring (attribute bonus)
    best_ring = _best_item_at_depth(TIERED_RINGS, depth, items_by_id)
    if best_ring is not None:
        new_equipped = [x for x in equipped if not (x.kind == "armor" and x.class_name in ("SteelRing1", "SteelRing2", "BronzeRing1", "BronzeRing2", "FireRing1", "FireRing2", "IceRing1", "IceRing2", "GrassRing1", "GrassRing2", "WaterRing1", "WaterRing2", "GoldRing1", "GoldRing2", "DemonRing1", "DemonRing2", "BloodRing1", "BloodRing2"))]
        new_equipped.append(best_ring)
        equipped = new_equipped

    # Upgrade remaining armor slots (helmet, gauntlets, shoes) so defense
    # matches a realistic mid-game loadout instead of breastplate-only.
    for table in (TIERED_HELMETS, TIERED_GAUNTLETS, TIERED_BOOTS):
        best_piece = _best_item_at_depth(table, depth, items_by_id)
        if best_piece is not None and not any(x.id == best_piece.id for x in equipped):
            equipped.append(best_piece)

    return equipped


EXPECTED_ROOM_XP_CACHE: Dict[Tuple[int, int], float] = {}
EXPECTED_ROOM_XP_SAMPLES = 32


def expected_room_xp(
    depth: int,
    class_id: int,
    enemies: Dict[int, Enemy],
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
    enemy_depth_scaling: Optional[Dict[str, object]] = None,
    min_room_size: int = DEFAULT_MIN_ROOM_SIZE,
    max_room_size: int = DEFAULT_MAX_ROOM_SIZE,
) -> float:
    """Expected XP from one room: samples Main.mc geometry + calculateEnemiesForRoom + chooseEnemies."""
    key = (depth, class_id)
    cached = EXPECTED_ROOM_XP_CACHE.get(key)
    if cached is not None:
        return cached

    scaling = enemy_depth_scaling or {}
    total_xp = 0.0
    for _ in range(EXPECTED_ROOM_XP_SAMPLES):
        room_size, room_max = sample_room_geometry(min_room_size, max_room_size)
        difficulty_factor = 2 if roll_percent(10) else 1
        count, points = calculate_enemies_for_room(depth, room_size, room_max, difficulty_factor)
        if count <= 0:
            continue
        for enemy_id in choose_enemies(count, points, depth, class_id, enemy_weights, class_multipliers):
            enemy = enemies.get(enemy_id)
            if enemy is None:
                continue
            total_xp += scale_enemy_for_depth(enemy, depth, scaling).kill_experience

    result = total_xp / EXPECTED_ROOM_XP_SAMPLES
    EXPECTED_ROOM_XP_CACHE[key] = result
    return result


def projected_player_for_depth(
    player: PlayerClass,
    class_id: int,
    depth: int,
    enemies: Dict[int, Enemy],
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
    rooms_per_depth_for_progression: int,
    initial_attribute_points: int,
    enemy_depth_scaling: Optional[Dict[str, object]] = None,
    min_room_size: int = DEFAULT_MIN_ROOM_SIZE,
    max_room_size: int = DEFAULT_MAX_ROOM_SIZE,
) -> Tuple[int, int, int, Dict[str, int]]:
    cumulative_experience = 0.0
    for explored_depth in range(1, depth):
        xp_per_room = expected_room_xp(
            depth=explored_depth,
            class_id=class_id,
            enemies=enemies,
            enemy_weights=enemy_weights,
            class_multipliers=class_multipliers,
            enemy_depth_scaling=enemy_depth_scaling,
            min_room_size=min_room_size,
            max_room_size=max_room_size,
        )
        if xp_per_room <= 0:
            continue
        cumulative_experience += xp_per_room * max(1, rooms_per_depth_for_progression)

    level = 1
    levels_gained = 0
    next_level_experience = 100.0
    while cumulative_experience >= next_level_experience:
        cumulative_experience -= next_level_experience
        level += 1
        levels_gained += 1
        next_level_experience = level * 100.0

    max_health = player.max_health + levels_gained * player.level_health_gain
    max_mana = player.max_mana + levels_gained * player.level_mana_gain
    attributes = distribute_attribute_points(player.attributes, max(0, initial_attribute_points) + levels_gained * 5)
    return level, max_health, max_mana, attributes


def apply_item_bonuses(attributes: Dict[str, int], equipped_items: List[Item]) -> Dict[str, int]:
    out = dict(attributes)
    for item in equipped_items:
        for key, delta in item.attribute_bonus.items():
            if key in out:
                out[key] = int(clamp(out[key] + delta, 0, 500))
    return out


def compute_player_offense(attributes: Dict[str, int], weapons: List[Item]) -> float:
    if not weapons:
        return 1.0
    n = len(weapons)
    total = 0.0
    for weapon in weapons:
        if weapon.attack <= 0:
            continue
        weights = ATTACK_WEIGHTS.get(weapon.attack_type, ATTACK_WEIGHTS["STRENGTH"])
        attack = weapon.attack * 0.7
        for key in ATTRIBUTE_KEYS:
            if key == "luck":
                continue
            attack += attributes[key] * float(weights.get(key, 0.0)) / (2 * n)
        total += attack
    return max(1.0, total)


def compute_player_defense(attributes: Dict[str, int], armors: List[Item]) -> float:
    base = float(attributes.get("constitution", 0))
    if not armors:
        return max(0.0, base)
    total = base
    armors_size = 8  # Game's Player.getDefense always passes armors_size = 8
    for armor in armors:
        if armor.defense <= 0:
            continue
        weights = ATTACK_WEIGHTS.get(armor.defense_type, ATTACK_WEIGHTS["CONSTITUTION"])
        defense = armor.defense * 0.5
        for key in ATTRIBUTE_KEYS:
            if key == "luck":
                continue
            defense += attributes[key] * float(weights.get(key, 0.0)) / (4 * armors_size)
        total += defense
    return max(0.0, total)


def compute_weapon_attack_value(weapon: Item, attributes: Dict[str, int], weapons_size: int, attack_value: float) -> float:
    weights = ATTACK_WEIGHTS.get(weapon.attack_type, ATTACK_WEIGHTS["STRENGTH"])
    attack = attack_value * 0.7
    for key in ATTRIBUTE_KEYS:
        if key == "luck":
            continue
        attack += attributes[key] * float(weights.get(key, 0.0)) / (2 * max(1, weapons_size))
    return max(0.0, attack)


def estimate_encounter_resources(depth: int, player: PlayerClass) -> Dict[str, List[int]]:
    hp_potions: List[int] = []
    mana_potions: List[int] = []

    if random.random() < clamp(0.20 + depth * 0.008, 0.0, 0.55):
        hp_potions.append(20)
    if random.random() < clamp((depth - 6) * 0.01, 0.0, 0.35):
        hp_potions.append(80)
    if random.random() < clamp((depth - 14) * 0.006, 0.0, 0.20):
        hp_potions.append(player.max_health)

    if player.max_mana > 0:
        if random.random() < clamp(0.18 + depth * 0.007, 0.0, 0.50):
            mana_potions.append(20)
        if random.random() < clamp((depth - 6) * 0.01, 0.0, 0.30):
            mana_potions.append(80)
        if random.random() < clamp((depth - 14) * 0.006, 0.0, 0.18):
            mana_potions.append(player.max_mana)

    return {"health": hp_potions, "mana": mana_potions}


def jitter_weight(value: float, jitter: float) -> float:
    if jitter <= 0:
        return value
    delta = random.uniform(-jitter, jitter)
    return max(0.0, value * (1.0 + delta))


def weighted_pick(weight_map: Dict[int, float]) -> Optional[int]:
    if not weight_map:
        return None
    keys = list(weight_map.keys())
    weights = [weight_map[k] for k in keys]
    total = sum(weights)
    if total <= 0:
        return None
    return random.choices(keys, weights=weights, k=1)[0]


def scale_enemy_for_depth(enemy: Enemy, depth: int, scaling: Dict[str, object]) -> Enemy:
    if not scaling.get("enabled", False):
        return enemy
    start_depth = int(scaling.get("startDepth", 1))
    if depth < start_depth:
        return enemy
    f = depth - start_depth
    if f <= 0:
        return enemy
    return Enemy(
        id=enemy.id,
        name=enemy.name,
        file=enemy.file,
        damage=int(enemy.damage * (1.0 + f * float(scaling.get("damageScale", 0.015)))),
        armor=int(enemy.armor * (1.0 + f * float(scaling.get("armorScale", 0.01)))),
        max_health=int(enemy.max_health * (1.0 + f * float(scaling.get("healthScale", 0.02)))),
        kill_experience=int(enemy.kill_experience * (1.0 + f * float(scaling.get("xpScale", 0.01)))),
        attack_cooldown=enemy.attack_cooldown,
    )


def mc_clamp(value: float, low: float, high: float) -> float:
    if value < low:
        return low
    if value > high:
        return high
    return value


def roll_percent(chance: int) -> bool:
    """MathUtil.isRandomPercent: uniform roll 1..100, true when roll <= chance."""
    return random.randint(1, 100) <= chance


def sample_room_geometry(min_room_size: int, max_room_size: int) -> Tuple[int, int]:
    """Room interior area and enemy cap for one room (Main.mc createRoomShapeForDungeon)."""
    size_x = 2 * (random.randint(min_room_size, max_room_size) // 2)
    size_y = 2 * (random.randint(min_room_size, max_room_size) // 2)
    room_size = (size_x - 1) * (size_y - 1)
    room_max = (size_x * size_y) // 10
    return room_size, room_max


def calculate_enemies_for_room(depth: int, room_size: int, room_max: int, difficulty_factor: int) -> Tuple[int, int]:
    """Main.mc calculateEnemiesForRoom: returns (enemy_count, enemy_points)."""
    if roll_percent(10):
        return 0, 0
    depth_sqrt = math.sqrt(depth)
    room_size_scaling = room_size / 50.0
    num_enemies = 1 + room_size_scaling + (depth_sqrt / 2.0) / difficulty_factor
    cap = min(room_max, MAX_ENEMIES_PER_ROOM)
    count = int(mc_clamp(math.floor(num_enemies), 1, cap))
    points = 2 + int(math.floor(depth * difficulty_factor + depth_sqrt * room_size_scaling))
    return count, points


def choose_enemies(
    max_enemies: int,
    allocated_points: int,
    depth: int,
    class_id: int,
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
) -> List[int]:
    """Main.mc chooseEnemies: min-cost preference plus weighted pick (rand quantised to 0.01)."""
    multipliers = class_multipliers.get(class_id, {})
    entries = [
        (
            int(entry["id"]),
            int(entry["cost"]),
            tiered_weight(depth, entry["tiers"]) * multipliers.get(int(entry["id"]), 1.0),
        )
        for entry in enemy_weights
    ]
    chosen: List[int] = []
    remaining = allocated_points
    while remaining > 0 and len(chosen) < max_enemies:
        min_cost = 10 if remaining > 50 else (5 if remaining > 20 else 0)
        eligible = [(eid, cost, w) for eid, cost, w in entries if cost <= remaining and cost >= min_cost]
        total = sum(w for _, _, w in eligible)
        if total <= 0:
            eligible = [(eid, cost, w) for eid, cost, w in entries if cost <= remaining]
            total = sum(w for _, _, w in eligible)
        if total <= 0 or not eligible:
            break
        roll = (random.randint(0, 99) / 100.0) * total
        accumulated = 0.0
        picked: Optional[Tuple[int, int]] = None
        for eid, cost, weight in eligible:
            accumulated += weight
            if roll <= accumulated:
                picked = (eid, cost)
                break
        if picked is None:
            picked = (eligible[-1][0], eligible[-1][1])
        chosen.append(picked[0])
        remaining -= picked[1]
    return chosen


def strict_room_enemy_ids(
    depth: int,
    class_id: int,
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
    min_room_size: int = DEFAULT_MIN_ROOM_SIZE,
    max_room_size: int = DEFAULT_MAX_ROOM_SIZE,
) -> Tuple[List[int], int]:
    """One room's spawn: geometry, difficulty roll, enemy count/points, chooseEnemies."""
    room_size, room_max = sample_room_geometry(min_room_size, max_room_size)
    difficulty_factor = 2 if roll_percent(10) else 1
    count, points = calculate_enemies_for_room(depth, room_size, room_max, difficulty_factor)
    if count <= 0:
        return [], room_size
    return choose_enemies(count, points, depth, class_id, enemy_weights, class_multipliers), room_size


def game_item_type() -> int:
    """Main.mc getItemType: integer weighted pick over {weapon, armor, consumable, high quality}."""
    total = sum(weight for _, weight in ITEM_TYPE_WEIGHTS)
    roll = random.randint(0, total - 1)
    for type_id, weight in ITEM_TYPE_WEIGHTS:
        roll -= weight
        if roll < 0:
            return type_id
    return 0


def game_weighted_item_pick(weights: Dict[int, float]) -> Optional[int]:
    """Items.createRandomWeightedItem: integer roll against cumulative float weights."""
    total = sum(weights.values())
    if total <= 0:
        return None
    roll = random.randint(0, max(0, math.floor(total) - 1))
    current = 0.0
    picked: Optional[int] = None
    for item_id, weight in weights.items():
        current += weight
        if roll < current:
            picked = item_id
            break
    return picked


def strict_encounter_resources(
    depth: int,
    player: PlayerClass,
    class_id: int,
    enemy_count: int,
    room_size: int,
    item_tables: Optional[ItemWeightTables],
) -> Dict[str, List[int]]:
    """Main.mc getItemsNumForRoom + getItemType + Items.createRandomWeightedItem."""
    resources: Dict[str, List[int]] = {"health": [], "mana": []}
    if item_tables is None:
        return resources

    items = 0.5 + 0.15 * math.sqrt(depth) + enemy_count / 4.0 + room_size / 100.0
    if roll_percent(30):
        return resources
    if enemy_count > 0:
        items = max(1.0, items)
    num_items = int(math.floor(items))
    if num_items <= 0:
        return resources

    mapping = {
        2000: ("health", 20),
        2002: ("health", 80),
        2004: ("health", player.max_health),
        2001: ("mana", 20),
        2003: ("mana", 80),
        2005: ("mana", player.max_mana),
    }
    tables = item_drop_tables_for_class(item_tables, depth, class_id)
    for _ in range(num_items):
        item_type = game_item_type()
        if item_type != 2 and item_type != 3:
            continue
        item_id = game_weighted_item_pick(tables[item_type])
        if item_id is None:
            continue
        drop = mapping.get(item_id)
        if drop is None:
            continue
        kind, amount = drop
        if kind == "mana" and player.max_mana <= 0:
            continue
        resources[kind].append(amount)

    return resources


def simulate_duel(player: PlayerClass, enemy: Enemy, attrs: Dict[str, int], weapons: List[Item], p_defense: float, depth: int) -> bool:
    player_hp = float(player.max_health)
    enemy_hp = float(enemy.max_health)
    player_mana = float(player.current_mana)
    ammo = player.starting_ammo + random.randint(0, max(0, depth // 3))
    resources = estimate_encounter_resources(depth, player)
    health_potions = resources["health"]
    mana_potions = resources["mana"]
    enemy_curr_cd = 0

    max_turns = 60
    for _ in range(max_turns):
        available_weapons: List[Item] = []
        for weapon in weapons:
            if weapon.uses_ammo and ammo <= 0:
                continue
            available_weapons.append(weapon)

        should_heal = player_hp <= player.max_health * 0.40 and len(health_potions) > 0
        minimum_mana_cost = min((w.mana_loss for w in available_weapons if w.mana_loss > 0), default=0.0)
        should_mana = minimum_mana_cost > 0 and player_mana < minimum_mana_cost and len(mana_potions) > 0 and enemy_hp > 0

        if should_heal:
            heal = max(health_potions)
            health_potions.remove(heal)
            player_hp = min(float(player.max_health), player_hp + heal)
        elif should_mana:
            refill = max(mana_potions)
            mana_potions.remove(refill)
            player_mana = min(float(player.max_mana), player_mana + refill)
        else:
            if not available_weapons:
                player_damage = 1.0
            else:
                weapon_attacks: List[float] = []
                weapon_count = len(available_weapons)
                for weapon in available_weapons:
                    attack_value = float(weapon.attack)
                    if weapon.mana_loss > 0:
                        if player_mana >= weapon.mana_loss:
                            attack_value = float(weapon.active_attack if weapon.active_attack > 0 else weapon.attack)
                            player_mana -= weapon.mana_loss
                        else:
                            attack_value = float(weapon.inactive_attack if weapon.inactive_attack > 0 else weapon.attack)
                    if weapon.uses_ammo:
                        if ammo > 0:
                            ammo -= 1
                            attack_value += weapon.ammo_attack
                        else:
                            continue
                    weapon_attacks.append(compute_weapon_attack_value(weapon, attrs, weapon_count, attack_value))

                player_damage = sum(weapon_attacks) if weapon_attacks else 1.0

            dealt = calc_damage(player_damage, enemy.armor)
            enemy_hp -= dealt

        if enemy_hp <= 0:
            return True

        if enemy_curr_cd == 0:
            player_hp -= calc_damage(enemy.damage, p_defense)
            enemy_curr_cd = enemy.attack_cooldown
        if enemy_curr_cd > 0:
            enemy_curr_cd -= 1
        if player_hp <= 0:
            return False

    return enemy_hp <= 0 and player_hp > 0


def simulate_room(
    player: PlayerClass,
    room_enemies: List[Enemy],
    attrs: Dict[str, int],
    weapons: List[Item],
    p_defense: float,
    depth: int,
    class_id: int,
    room_size: int,
    item_tables: Optional[ItemWeightTables],
) -> bool:
    player_hp = float(player.max_health)
    player_mana = float(player.current_mana)
    ammo = player.starting_ammo + random.randint(0, max(0, depth // 2))

    spawn_enemy_count = len(room_enemies)
    if item_tables is not None:
        resources = strict_encounter_resources(depth, player, class_id, spawn_enemy_count, room_size, item_tables)
    else:
        resources = estimate_encounter_resources(depth, player)
    health_potions = resources["health"]
    mana_potions = resources["mana"]

    max_turns = 160
    turn = 0
    enemy_curr_cd = [0] * len(room_enemies)
    while turn < max_turns and player_hp > 0 and len(room_enemies) > 0:
        turn += 1

        focused_enemy = room_enemies[0]
        available_weapons: List[Item] = []
        for weapon in weapons:
            if weapon.uses_ammo and ammo <= 0:
                continue
            available_weapons.append(weapon)

        should_heal = player_hp <= player.max_health * (0.55 if len(room_enemies) > 3 else 0.45) and len(health_potions) > 0
        min_mana_cost = min((w.mana_loss for w in available_weapons if w.mana_loss > 0), default=0.0)
        should_mana = min_mana_cost > 0 and player_mana < min_mana_cost and len(mana_potions) > 0

        if should_heal:
            heal = max(health_potions)
            health_potions.remove(heal)
            player_hp = min(float(player.max_health), player_hp + heal)
        elif should_mana:
            refill = max(mana_potions)
            mana_potions.remove(refill)
            player_mana = min(float(player.max_mana), player_mana + refill)
        else:
            if not available_weapons:
                total_damage = 1.0
            else:
                attacks: List[float] = []
                weapon_count = len(available_weapons)
                for weapon in available_weapons:
                    attack_value = float(weapon.attack)
                    if weapon.mana_loss > 0:
                        if player_mana >= weapon.mana_loss:
                            attack_value = float(weapon.active_attack if weapon.active_attack > 0 else weapon.attack)
                            player_mana -= weapon.mana_loss
                        else:
                            attack_value = float(weapon.inactive_attack if weapon.inactive_attack > 0 else weapon.attack)
                    if weapon.uses_ammo:
                        if ammo <= 0:
                            continue
                        ammo -= 1
                        attack_value += weapon.ammo_attack
                    attacks.append(compute_weapon_attack_value(weapon, attrs, weapon_count, attack_value))
                total_damage = sum(attacks) if attacks else 1.0

            dealt = calc_damage(total_damage, focused_enemy.armor)
            focused_enemy.max_health -= dealt
            if focused_enemy.max_health <= 0:
                room_enemies.pop(0)
                enemy_curr_cd.pop(0)

        incoming = 0
        for i, enemy in enumerate(room_enemies):
            if enemy_curr_cd[i] == 0:
                incoming += calc_damage(enemy.damage, p_defense)
                enemy_curr_cd[i] = enemy.attack_cooldown
            if enemy_curr_cd[i] > 0:
                enemy_curr_cd[i] -= 1
        player_hp -= incoming

    return player_hp > 0 and len(room_enemies) == 0


def simulate(
    rounds_per_depth: int,
    depths: List[int],
    target_rules: List[Dict[str, float]],
    players: Dict[int, PlayerClass],
    enemies: Dict[int, Enemy],
    items_by_class: Dict[str, Item],
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
    strict_realism: bool,
    item_tables: Optional[ItemWeightTables],
    rooms_per_depth_for_progression: int,
    initial_attribute_points: int,
    enemy_depth_scaling: Optional[Dict[str, object]] = None,
    min_room_size: int = DEFAULT_MIN_ROOM_SIZE,
    max_room_size: int = DEFAULT_MAX_ROOM_SIZE,
) -> Tuple[List[EncounterOutcome], Dict[int, float], Dict[int, float], Dict[int, float], Dict[int, float]]:
    outcomes: List[EncounterOutcome] = []
    EXPECTED_ROOM_XP_CACHE.clear()

    # Build items_by_id lookup for item progression
    items_by_id: Dict[int, Item] = {item.id: item for item in items_by_class.values()}

    for class_id, player in players.items():
        multipliers = class_multipliers.get(class_id, {})
        starting_equipped = [items_by_class[name] for name in player.starting_items if name in items_by_class]

        for depth in depths:
            _, progressed_health, progressed_mana, progressed_attributes = projected_player_for_depth(
                player=player,
                class_id=class_id,
                depth=depth,
                enemies=enemies,
                enemy_weights=enemy_weights,
                class_multipliers=class_multipliers,
                rooms_per_depth_for_progression=rooms_per_depth_for_progression,
                initial_attribute_points=initial_attribute_points,
                enemy_depth_scaling=enemy_depth_scaling,
                min_room_size=min_room_size,
                max_room_size=max_room_size,
            )
            progressed_player = PlayerClass(
                id=player.id,
                class_name=player.class_name,
                file=player.file,
                current_health=progressed_health,
                max_health=progressed_health,
                max_mana=progressed_mana,
                current_mana=progressed_mana,
                starting_ammo=player.starting_ammo,
                attributes=progressed_attributes,
                starting_items=player.starting_items,
                level_health_gain=player.level_health_gain,
                level_mana_gain=player.level_mana_gain,
            )

            # Use item progression: better items at deeper depths
            equipped_items = get_items_for_depth(player, class_id, depth, items_by_class, items_by_id)
            weapons = [x for x in equipped_items if x.kind == "weapon"]
            armors = [x for x in equipped_items if x.kind == "armor"]

            attrs = apply_item_bonuses(progressed_player.attributes, equipped_items)
            p_defense = compute_player_defense(attrs, armors)

            for _ in range(rounds_per_depth):
                if strict_realism:
                    room_enemy_ids, room_size = strict_room_enemy_ids(
                        depth=depth,
                        class_id=class_id,
                        enemy_weights=enemy_weights,
                        class_multipliers=class_multipliers,
                        min_room_size=min_room_size,
                        max_room_size=max_room_size,
                    )
                    if not room_enemy_ids:
                        continue
                    room_enemies = [
                        scale_enemy_for_depth(
                            Enemy(
                                id=enemies[eid].id,
                                name=enemies[eid].name,
                                file=enemies[eid].file,
                                damage=enemies[eid].damage,
                                armor=enemies[eid].armor,
                                max_health=enemies[eid].max_health,
                                kill_experience=enemies[eid].kill_experience,
                                attack_cooldown=enemies[eid].attack_cooldown,
                            ),
                            depth,
                            enemy_depth_scaling or {},
                        )
                        for eid in room_enemy_ids
                        if eid in enemies
                    ]
                    if not room_enemies:
                        continue
                    room_enemy_ids_snapshot = [enemy.id for enemy in room_enemies]
                    win = simulate_room(
                        player=progressed_player,
                        room_enemies=room_enemies,
                        attrs=attrs,
                        weapons=weapons,
                        p_defense=p_defense,
                        depth=depth,
                        class_id=class_id,
                        room_size=room_size,
                        item_tables=item_tables,
                    )
                    for enemy_id in room_enemy_ids_snapshot:
                        outcomes.append(EncounterOutcome(class_id=class_id, depth=depth, enemy_id=enemy_id, win=win))
                else:
                    weighted_enemy_ids = []
                    weighted_values = []
                    for entry in enemy_weights:
                        enemy_id = int(entry["id"])
                        if enemy_id not in enemies:
                            continue
                        base_weight = tiered_weight(depth, entry["tiers"])
                        if base_weight <= 0:
                            continue
                        w = base_weight * multipliers.get(enemy_id, 1.0)
                        if w <= 0:
                            continue
                        weighted_enemy_ids.append(enemy_id)
                        weighted_values.append(w)
                    if not weighted_enemy_ids:
                        continue

                    enemy_id = random.choices(weighted_enemy_ids, weights=weighted_values, k=1)[0]
                    enemy = scale_enemy_for_depth(enemies[enemy_id], depth, enemy_depth_scaling or {})
                    win = simulate_duel(progressed_player, enemy, attrs, weapons, p_defense, depth)
                    outcomes.append(EncounterOutcome(class_id=class_id, depth=depth, enemy_id=enemy_id, win=win))

    class_win: Dict[int, float] = {}
    class_target: Dict[int, float] = {}
    depth_win: Dict[int, float] = {}
    depth_target: Dict[int, float] = {}

    for class_id in players.keys():
        rows = [o for o in outcomes if o.class_id == class_id]
        if not rows:
            continue
        class_win[class_id] = sum(1 for x in rows if x.win) / len(rows)
        class_target[class_id] = sum(target_for_depth(x.depth, target_rules) for x in rows) / len(rows)

    for depth in depths:
        rows = [o for o in outcomes if o.depth == depth]
        if not rows:
            continue
        depth_win[depth] = sum(1 for x in rows if x.win) / len(rows)
        depth_target[depth] = target_for_depth(depth, target_rules)

    return outcomes, class_win, class_target, depth_win, depth_target


def infer_tier_from_item_id(item_id: int) -> Optional[int]:
    if 0 <= item_id <= 89:
        return item_id // 10
    if 1000 <= item_id <= 1089:
        return (item_id - 1000) // 10
    return None


def bounded_int(value: float, minimum: int = 0) -> int:
    return max(minimum, int(round(value)))


def depth_segment_average(depth_values: Dict[int, float], max_depth: int, previous_max_depth: int) -> float:
    values = [v for d, v in depth_values.items() if previous_max_depth < d <= max_depth]
    if not values:
        return 0.0
    return sum(values) / len(values)


def propose_enemy_specific_weight_adjustments(
    workspace: Path,
    outcomes: List[EncounterOutcome],
    depth_win: Dict[int, float],
    depth_target: Dict[int, float],
    enemy_weights: List[Dict[str, object]],
    tolerance: float,
    max_adj: float,
) -> List[Dict[str, object]]:
    enemy_delta: Dict[int, float] = {}
    by_enemy: Dict[int, List[EncounterOutcome]] = {}
    for row in outcomes:
        by_enemy.setdefault(row.enemy_id, []).append(row)

    for enemy_id, rows in by_enemy.items():
        if not rows:
            continue
        winrate = sum(1 for r in rows if r.win) / len(rows)
        target = sum(depth_target.get(r.depth, 0.0) for r in rows) / len(rows)
        enemy_delta[enemy_id] = target - winrate

    depth_pressure = {depth: depth_win[depth] - depth_target[depth] for depth in depth_win.keys() if depth in depth_target}
    file_path = workspace / "source/Engine/Util/EnemySpecificValues.mc"
    adjustments: List[Dict[str, object]] = []

    for entry in enemy_weights:
        enemy_id = int(entry["id"])
        if enemy_id not in enemy_delta:
            continue
        difficulty = clamp(enemy_delta[enemy_id] / 0.35, -1.0, 1.0)
        prev_max = 0
        for max_depth, tier_weight in entry["tiers"]:
            old_weight = int(round(float(tier_weight)))
            if old_weight <= 0:
                prev_max = max_depth
                continue
            segment_pressure = depth_segment_average(depth_pressure, int(max_depth), int(prev_max))
            if abs(segment_pressure) <= tolerance:
                prev_max = max_depth
                continue
            factor = clamp(1.0 + segment_pressure * difficulty * 0.45, 1 - max_adj, 1 + max_adj)
            new_weight = bounded_int(old_weight * factor, 0)
            if new_weight != old_weight:
                adjustments.append({
                    "category": "strict-tables",
                    "table": "enemy",
                    "file": str(file_path),
                    "enemyId": enemy_id,
                    "maxDepth": int(max_depth),
                    "field": "weight",
                    "old": old_weight,
                    "new": new_weight,
                })
            prev_max = max_depth

    if not adjustments:
        avg_pressure_values = list(depth_pressure.values())
        avg_pressure = (sum(avg_pressure_values) / len(avg_pressure_values)) if avg_pressure_values else 0.0
        if abs(avg_pressure) > tolerance and enemy_delta:
            ranked = sorted(enemy_delta.items(), key=lambda kv: kv[1], reverse=True)
            if avg_pressure > 0:
                candidates = [enemy_id for enemy_id, d in ranked if d > 0]
            else:
                candidates = [enemy_id for enemy_id, d in ranked if d < 0]
            selected = candidates[:3] if candidates else [enemy_id for enemy_id, _ in ranked[:3]]

            for enemy_id in selected:
                matching = [entry for entry in enemy_weights if int(entry["id"]) == enemy_id]
                if not matching:
                    continue
                tiers = matching[0]["tiers"]
                tier_max, tier_weight = tiers[-1]
                old_weight = int(round(float(tier_weight)))
                if old_weight <= 0:
                    continue
                delta = enemy_delta.get(enemy_id, 0.0)
                factor = clamp(1.0 + avg_pressure * clamp(delta / 0.35, -1.0, 1.0) * 0.6, 1 - max_adj, 1 + max_adj)
                new_weight = bounded_int(old_weight * factor, 0)
                if new_weight == old_weight:
                    new_weight = old_weight + (1 if factor >= 1.0 else -1)
                    new_weight = max(0, new_weight)
                if new_weight != old_weight:
                    adjustments.append({
                        "category": "strict-tables",
                        "table": "enemy",
                        "file": str(file_path),
                        "enemyId": int(enemy_id),
                        "maxDepth": int(tier_max),
                        "field": "weight",
                        "old": old_weight,
                        "new": new_weight,
                    })

    return adjustments


def enforce_tier_constraints(
    item_adjustments: List[Dict[str, object]],
    items_by_id: Dict[int, "ParsedItem"],
    min_tier_gap: float = 0.5,
    max_intra_tier_deviation: float = 0.3,
) -> List[Dict[str, object]]:
    """Post-process item adjustments to enforce two rules:
    1. Each tier's average stat must be at least min_tier_gap higher than the previous tier.
    2. Items within the same tier must not deviate more than max_intra_tier_deviation from the tier average.
    """
    ITEM_ATK_MIN, ITEM_ATK_MAX = 1, 100
    ITEM_DEF_MIN, ITEM_DEF_MAX = 0, 70
    # Build lookup: (item_id, field) -> new value from adjustments
    adj_map: Dict[tuple, int] = {}
    for adj in item_adjustments:
        key = (adj["itemId"], adj["field"])
        adj_map[key] = adj["new"]

    # Get effective stats per item (use adjusted value if present, else original)
    def get_stat(item_id: int, field: str) -> int:
        key = (item_id, field)
        if key in adj_map:
            return adj_map[key]
        item = items_by_id.get(item_id)
        if item is None:
            return 0
        return item.attack if field == "attack" else item.defense

    # Group items by tier
    tier_items: Dict[int, List[int]] = {}
    for item_id in items_by_id:
        tier = infer_tier_from_item_id(item_id)
        if tier is not None:
            tier_items.setdefault(tier, []).append(item_id)

    # For each tier, compute average of attack and defense separately
    tier_avg: Dict[int, Dict[str, float]] = {}
    for tier, item_ids in tier_items.items():
        attacks = [get_stat(i, "attack") for i in item_ids if items_by_id[i].kind == "weapon" and get_stat(i, "attack") > 0]
        defenses = [get_stat(i, "defense") for i in item_ids if items_by_id[i].kind == "armor" and get_stat(i, "defense") > 0]
        tier_avg[tier] = {
            "attack": sum(attacks) / len(attacks) if attacks else 0,
            "defense": sum(defenses) / len(defenses) if defenses else 0,
        }

    # Rule 1: Enforce tier progression (each tier >= previous tier + min_tier_gap)
    sorted_tiers = sorted(tier_avg.keys())
    for i in range(1, len(sorted_tiers)):
        prev_tier = sorted_tiers[i - 1]
        curr_tier = sorted_tiers[i]
        for field in ["attack", "defense"]:
            if tier_avg[curr_tier][field] > 0 and tier_avg[prev_tier][field] > 0:
                min_required = tier_avg[prev_tier][field] + min_tier_gap
                if tier_avg[curr_tier][field] < min_required:
                    # Boost all items in this tier proportionally
                    boost = min_required / tier_avg[curr_tier][field]
                    for item_id in tier_items[curr_tier]:
                        item = items_by_id[item_id]
                        if field == "attack" and item.kind == "weapon" and item.attack > 0:
                            old_val = get_stat(item_id, "attack")
                            new_val = clamp(bounded_int(old_val * boost, 1), ITEM_ATK_MIN, ITEM_ATK_MAX)
                            if new_val != old_val:
                                key = (item_id, "attack")
                                adj_map[key] = new_val
                        elif field == "defense" and item.kind == "armor" and item.defense > 0:
                            old_val = get_stat(item_id, "defense")
                            new_val = clamp(bounded_int(old_val * boost, 0), ITEM_DEF_MIN, ITEM_DEF_MAX)
                            if new_val != old_val:
                                key = (item_id, "defense")
                                adj_map[key] = new_val
                    # Update tier average
                    tier_avg[curr_tier][field] = min_required

    # Recompute tier averages after progression enforcement
    for tier, item_ids in tier_items.items():
        attacks = [get_stat(i, "attack") for i in item_ids if items_by_id[i].kind == "weapon" and get_stat(i, "attack") > 0]
        defenses = [get_stat(i, "defense") for i in item_ids if items_by_id[i].kind == "armor" and get_stat(i, "defense") > 0]
        tier_avg[tier] = {
            "attack": sum(attacks) / len(attacks) if attacks else 0,
            "defense": sum(defenses) / len(defenses) if defenses else 0,
        }

    # Rule 2: Enforce intra-tier consistency (clamp items to tier average +/- deviation)
    for tier, item_ids in tier_items.items():
        for field in ["attack", "defense"]:
            avg = tier_avg[tier][field]
            if avg <= 0:
                continue
            min_val = max(1 if field == "attack" else 0, int(avg * (1 - max_intra_tier_deviation)))
            max_val = min(ITEM_ATK_MAX if field == "attack" else ITEM_DEF_MAX, int(avg * (1 + max_intra_tier_deviation)))
            for item_id in item_ids:
                item = items_by_id[item_id]
                if field == "attack" and item.kind == "weapon" and item.attack > 0:
                    old_val = get_stat(item_id, "attack")
                    new_val = clamp(old_val, min_val, max_val)
                    if new_val != old_val:
                        adj_map[(item_id, "attack")] = new_val
                elif field == "defense" and item.kind == "armor" and item.defense > 0:
                    old_val = get_stat(item_id, "defense")
                    new_val = clamp(old_val, min_val, max_val)
                    if new_val != old_val:
                        adj_map[(item_id, "defense")] = new_val

    # Rebuild adjustments list from adj_map, comparing to original values
    result: List[Dict[str, object]] = []
    for (item_id, field), new_val in adj_map.items():
        item = items_by_id.get(item_id)
        if item is None:
            continue
        old_val = item.attack if field == "attack" else item.defense
        if new_val != old_val:
            result.append({
                "itemId": item_id,
                "itemName": item.class_name,
                "file": str(item.file),
                "field": field,
                "old": old_val,
                "new": new_val,
            })
    return result


def propose_item_specific_consumable_adjustments(
    workspace: Path,
    depth_win: Dict[int, float],
    depth_target: Dict[int, float],
    item_tables: Optional[ItemWeightTables],
    tolerance: float,
    max_adj: float,
) -> List[Dict[str, object]]:
    if item_tables is None:
        return []

    depth_pressure = {depth: depth_win[depth] - depth_target[depth] for depth in depth_win.keys() if depth in depth_target}
    file_path = workspace / "source/Engine/Util/ItemSpecificValues.mc"
    adjustments: List[Dict[str, object]] = []
    consumable_ids = [2000, 2001, 2002, 2003, 2004, 2005]

    for item_id in consumable_ids:
        tiers = item_tables.consumable_weights.get(item_id, [])
        prev_max = 0
        for max_depth, tier_weight in tiers:
            old_weight = int(round(float(tier_weight)))
            if old_weight <= 0:
                prev_max = max_depth
                continue
            segment_pressure = depth_segment_average(depth_pressure, int(max_depth), int(prev_max))
            if abs(segment_pressure) <= tolerance:
                prev_max = max_depth
                continue
            factor = clamp(1.0 - segment_pressure * 0.55, 1 - max_adj, 1 + max_adj)
            new_weight = bounded_int(old_weight * factor, 0)
            if new_weight != old_weight:
                adjustments.append({
                    "category": "strict-tables",
                    "table": "item-consumable",
                    "file": str(file_path),
                    "itemId": int(item_id),
                    "maxDepth": int(max_depth),
                    "field": "weight",
                    "old": old_weight,
                    "new": new_weight,
                })
            prev_max = max_depth

    return adjustments


def tune(
    workspace: Path,
    config: Dict[str, object],
    players: Dict[int, PlayerClass],
    enemies: Dict[int, Enemy],
    items_by_id: Dict[int, Item],
    outcomes: List[EncounterOutcome],
    class_win: Dict[int, float],
    class_target: Dict[int, float],
    depth_win: Dict[int, float],
    depth_target: Dict[int, float],
    strict_realism: bool,
    enemy_weights: List[Dict[str, object]],
    item_tables: Optional[ItemWeightTables],
) -> Dict[str, List[Dict[str, object]]]:
    tol = float(config.get("tolerance", 0.05))
    max_adj = float(config.get("maxAdjustmentPercentPerRun", 12)) / 100.0

    # Hard bounds for all adjustable stats
    PLAYER_HP_MIN, PLAYER_HP_MAX = 20, 150
    PLAYER_LHP_MIN, PLAYER_LHP_MAX = 3, 20
    PLAYER_LMP_MIN, PLAYER_LMP_MAX = 1, 8
    ENEMY_DMG_MIN, ENEMY_DMG_MAX = 1, 80
    ENEMY_HP_MIN, ENEMY_HP_MAX = 10, 400
    ENEMY_ARM_MIN, ENEMY_ARM_MAX = 0, 40
    ITEM_ATK_MIN, ITEM_ATK_MAX = 1, 100
    ITEM_DEF_MIN, ITEM_DEF_MAX = 0, 70

    adjustments: Dict[str, List[Dict[str, object]]] = {"players": [], "enemies": [], "items": [], "strictTables": []}

    # Player adjustments
    for class_id, player in players.items():
        if class_id not in class_win:
            continue
        delta = class_target[class_id] - class_win[class_id]
        if abs(delta) <= tol:
            continue
        hp_factor = clamp(1.0 + delta * 0.50, 1 - max_adj, 1 + max_adj)

        new_hp = clamp(bounded_int(player.max_health * hp_factor, 1), PLAYER_HP_MIN, PLAYER_HP_MAX)
        if new_hp != player.max_health:
            adjustments["players"].append({
                "classId": class_id,
                "className": player.class_name,
                "file": str(player.file),
                "field": "maxHealth",
                "old": player.max_health,
                "new": new_hp,
            })
            adjustments["players"].append({
                "classId": class_id,
                "className": player.class_name,
                "file": str(player.file),
                "field": "current_health",
                "old": player.current_health,
                "new": new_hp,
            })

        if player.level_health_gain > 0:
            lh_factor = clamp(1.0 + delta * 0.40, 1 - max_adj, 1 + max_adj)
            new_lh = clamp(bounded_int(player.level_health_gain * lh_factor, 1), PLAYER_LHP_MIN, PLAYER_LHP_MAX)
            if new_lh != player.level_health_gain:
                adjustments["players"].append({
                    "classId": class_id,
                    "className": player.class_name,
                    "file": str(player.file),
                    "field": "level_health_gain",
                    "old": player.level_health_gain,
                    "new": new_lh,
                })

        if player.level_mana_gain > 0:
            lm_factor = clamp(1.0 + delta * 0.35, 1 - max_adj, 1 + max_adj)
            new_lm = clamp(bounded_int(player.level_mana_gain * lm_factor, 1), PLAYER_LMP_MIN, PLAYER_LMP_MAX)
            if new_lm != player.level_mana_gain:
                adjustments["players"].append({
                    "classId": class_id,
                    "className": player.class_name,
                    "file": str(player.file),
                    "field": "level_mana_gain",
                    "old": player.level_mana_gain,
                    "new": new_lm,
                })

    # Enemy adjustments (depth-segmented, independent stat scaling)
    DEPTH_SEGMENTS = [(1, 25), (26, 35), (36, 50), (51, 75), (76, 100), (101, 150), (151, 200)]
    by_enemy_seg: Dict[Tuple[int, int], List[EncounterOutcome]] = {}
    for row in outcomes:
        seg = next((s for s in DEPTH_SEGMENTS if s[0] <= row.depth <= s[1]), DEPTH_SEGMENTS[-1])
        by_enemy_seg.setdefault((row.enemy_id, seg[0]), []).append(row)

    enemy_adj_accum: Dict[int, Dict[str, float]] = {}
    for (enemy_id, _seg_start), rows in by_enemy_seg.items():
        if enemy_id not in enemies or not rows:
            continue
        enemy = enemies[enemy_id]
        winrate = sum(1 for r in rows if r.win) / len(rows)
        target = sum(depth_target[r.depth] for r in rows) / len(rows)
        delta = target - winrate
        if abs(delta) <= tol:
            continue

        seg_weight = len(rows) / max(1, len([r for r in outcomes if r.enemy_id == enemy_id]))
        dmg_factor = clamp(1.0 - delta * 0.50 * seg_weight, 1 - max_adj, 1 + max_adj)
        hp_factor = clamp(1.0 - delta * 0.40 * seg_weight, 1 - max_adj, 1 + max_adj)
        arm_factor = clamp(1.0 - delta * 0.30 * seg_weight, 1 - max_adj, 1 + max_adj)

        accum = enemy_adj_accum.setdefault(enemy_id, {"dmg": 1.0, "hp": 1.0, "arm": 1.0})
        accum["dmg"] *= dmg_factor
        accum["hp"] *= hp_factor
        accum["arm"] *= arm_factor

    for enemy_id, factors in enemy_adj_accum.items():
        enemy = enemies[enemy_id]
        new_damage = clamp(bounded_int(enemy.damage * factors["dmg"], 1), ENEMY_DMG_MIN, ENEMY_DMG_MAX)
        new_hp = clamp(bounded_int(enemy.max_health * factors["hp"], 1), ENEMY_HP_MIN, ENEMY_HP_MAX)
        new_armor = clamp(bounded_int(enemy.armor * factors["arm"], 0), ENEMY_ARM_MIN, ENEMY_ARM_MAX)
        if new_damage != enemy.damage:
            adjustments["enemies"].append({"enemyId": enemy_id, "enemyName": enemy.name, "file": str(enemy.file), "field": "damage", "old": enemy.damage, "new": new_damage})
        if new_hp != enemy.max_health:
            adjustments["enemies"].append({"enemyId": enemy_id, "enemyName": enemy.name, "file": str(enemy.file), "field": "maxHealth", "old": enemy.max_health, "new": new_hp})
        if new_armor != enemy.armor:
            adjustments["enemies"].append({"enemyId": enemy_id, "enemyName": enemy.name, "file": str(enemy.file), "field": "armor", "old": enemy.armor, "new": new_armor})

    # Item adjustments disabled: items have fixed hand-tuned values per tier.
    # Enemies are balanced around items, not the other way around.

    if strict_realism:
        adjustments["strictTables"].extend(
            propose_enemy_specific_weight_adjustments(
                workspace=workspace,
                outcomes=outcomes,
                depth_win=depth_win,
                depth_target=depth_target,
                enemy_weights=enemy_weights,
                tolerance=tol,
                max_adj=max_adj,
            )
        )
        adjustments["strictTables"].extend(
            propose_item_specific_consumable_adjustments(
                workspace=workspace,
                depth_win=depth_win,
                depth_target=depth_target,
                item_tables=item_tables,
                tolerance=tol,
                max_adj=max_adj,
            )
        )

    return adjustments


def update_function_body(text: str, function_name: str, replacement_fn) -> str:
    marker = f"function {function_name}"
    start = text.find(marker)
    if start < 0:
        return text
    open_brace = text.find("{", start)
    if open_brace < 0:
        return text
    depth = 0
    i = open_brace
    while i < len(text):
        c = text[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                body = text[open_brace + 1 : i]
                new_body = replacement_fn(body)
                return text[: open_brace + 1] + new_body + text[i:]
        i += 1
    return text


def update_initialize_body(text: str, replacement_fn) -> str:
    return update_function_body(text, "initialize", replacement_fn)


def apply_adjustments(adjustments: Dict[str, List[Dict[str, object]]]) -> int:
    changed_files = 0
    grouped: Dict[Path, List[Dict[str, object]]] = {}
    for _, entries in adjustments.items():
        for entry in entries:
            grouped.setdefault(Path(str(entry["file"])), []).append(entry)

    for file, entries in grouped.items():
        text = read(file)

        def repl(body: str) -> str:
            out = body
            for change in entries:
                if str(change.get("category", "")) == "strict-tables":
                    continue
                field = str(change["field"])
                old = str(change["old"])
                new = str(change["new"])
                if field.startswith(":"):
                    out = re.sub(rf"({re.escape(field)}\s*=>\s*){re.escape(old)}(\b)", rf"\g<1>{new}\2", out, count=1)
                else:
                    pattern = rf"((?:self\.)?{re.escape(field)}\s*=\s*){re.escape(old)}(\s*;)"
                    if re.search(pattern, out):
                        out = re.sub(pattern, rf"\g<1>{new}\2", out, count=1)
            return out

        updated = update_initialize_body(text, repl)

        level_entries = [e for e in entries if e.get("field") in ("level_health_gain", "level_mana_gain")]
        if level_entries:
            def repl_level(body: str) -> str:
                out = body
                for change in level_entries:
                    field = str(change["field"])
                    old = str(change["old"])
                    new = str(change["new"])
                    target = "maxHealth" if field == "level_health_gain" else "maxMana"
                    pattern = rf"({re.escape(target)}\s*\+=\s*){re.escape(old)}(\s*;)"
                    if re.search(pattern, out):
                        out = re.sub(pattern, rf"\g<1>{new}\2", out, count=1)
                return out
            updated = update_function_body(updated, "onLevelUp", repl_level)

        if any(str(e.get("category", "")) == "strict-tables" for e in entries):
            for change in entries:
                if str(change.get("category", "")) != "strict-tables":
                    continue
                old = str(change.get("old"))
                new = str(change.get("new"))
                max_depth = int(change.get("maxDepth"))
                if change.get("table") == "enemy":
                    enemy_id = int(change.get("enemyId"))
                    pattern = re.compile(
                        rf"(\:id\s*=>\s*{enemy_id}\s*,.*?\:max\s*=>\s*{max_depth}\s*,\s*\:weight\s*=>\s*){re.escape(old)}(\b)",
                        re.S,
                    )
                    updated = pattern.sub(rf"\g<1>{new}\2", updated, count=1)
                elif change.get("table") == "item-consumable":
                    item_id = int(change.get("itemId"))
                    pattern = re.compile(
                        rf"({item_id}\s*=>\s*tieredWeight\(depth,\s*\[.*?\:max\s*=>\s*{max_depth}\s*,\s*\:weight\s*=>\s*){re.escape(old)}(\b)",
                        re.S,
                    )
                    updated = pattern.sub(rf"\g<1>{new}\2", updated, count=1)

        if updated != text:
            file.write_text(updated, encoding="utf-8")
            changed_files += 1
    return changed_files


def write_report(
    workspace: Path,
    config: Dict[str, object],
    class_win: Dict[int, float],
    class_target: Dict[int, float],
    depth_win: Dict[int, float],
    depth_target: Dict[int, float],
    adjustments: Dict[str, List[Dict[str, object]]],
    players: Optional[Dict[int, "ParsedPlayer"]] = None,
    enemies: Optional[Dict[int, "ParsedEnemy"]] = None,
    items_by_id: Optional[Dict[int, "ParsedItem"]] = None,
    enemy_weights: Optional[List[Dict[str, object]]] = None,
    item_tables: Optional[ItemWeightTables] = None,
) -> None:
    out_dir = workspace / "tools/balance"
    out_dir.mkdir(parents=True, exist_ok=True)

    report = {
        "config": config,
        "classResults": {str(k): {"actualWinRate": class_win[k], "targetWinRate": class_target[k]} for k in class_win},
        "depthResults": {str(k): {"actualWinRate": depth_win[k], "targetWinRate": depth_target[k]} for k in depth_win},
        "adjustments": adjustments,
    }

    (out_dir / "balance_report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")

    lines = [
        "# Balance Report",
        "",
        "## Player Classes",
        "",
        "| Class | HP | Mana | Strength | Dex | Int | Con | Level HP | Level Mana |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    if players:
        class_names = {0: "Warrior", 1: "Mage", 2: "Archer", 3: "Nameless", 4: "Paladin", 5: "God"}
        for cid in sorted(players.keys()):
            p = players[cid]
            name = class_names.get(cid, p.class_name)
            hp = p.max_health
            mana = p.max_mana if p.max_mana > 0 else "-"
            attrs = p.attributes
            str_val = attrs.get("strength", "?")
            dex_val = attrs.get("dexterity", "?")
            int_val = attrs.get("intelligence", "?")
            con_val = attrs.get("constitution", "?")
            lvl_hp = p.level_health_gain
            lvl_mp = p.level_mana_gain if p.level_mana_gain > 0 else "-"
            lines.append(f"| {name} | {hp} | {mana} | {str_val} | {dex_val} | {int_val} | {con_val} | {lvl_hp} | {lvl_mp} |")
    lines.append("")

    # Enemies table
    lines += [
        "## Enemies",
        "",
        "| Enemy | HP | Damage | Armor | XP |",
        "|---|---:|---:|---:|---:|",
    ]
    if enemies:
        for eid in sorted(enemies.keys()):
            e = enemies[eid]
            lines.append(f"| {e.name} | {e.max_health} | {e.damage} | {e.armor} | {e.kill_experience} |")
    lines.append("")

    # Enemy spawn weights per depth tier
    if enemy_weights:

        def _fmt_weight(value: float) -> str:
            return str(int(value)) if float(value).is_integer() else f"{value:g}"

        def _weight_at_depth(tiers: List[Tuple[int, float]], depth: int) -> float:
            for tier_max, weight in tiers:
                if depth <= tier_max:
                    return weight
            return tiers[-1][1]

        tier_maxes = sorted({int(tier_max) for entry in enemy_weights for tier_max, _ in entry["tiers"]})  # type: ignore[index]
        if tier_maxes:
            lines += [
                "## Enemy Spawn Weights",
                "",
                "Current `:cost` / `:weight` tables from `EnemySpecificValues.mc` (weight for depth tier).",
                "",
                "| Enemy | Cost | " + " | ".join(f"≤{m}" for m in tier_maxes) + " |",
                "|---|---:|" + "---:|" * len(tier_maxes),
            ]
            for entry in sorted(enemy_weights, key=lambda x: int(x["id"])):
                eid = int(entry["id"])  # type: ignore[arg-type]
                name = enemies[eid].name if enemies and eid in enemies else str(eid)
                tiers = entry["tiers"]  # type: ignore[assignment]
                cells = " | ".join(_fmt_weight(_weight_at_depth(tiers, m)) for m in tier_maxes)
                lines.append(f"| {name} | {entry['cost']} | {cells} |")  # type: ignore[index]
            lines.append("")

    # Items table grouped by tier
    lines += [
        "## Items",
        "",
    ]
    if items_by_id:
        tier_names = {0: "Steel", 1: "Bronze", 2: "Fire", 3: "Ice", 4: "Grass", 5: "Water", 6: "Gold", 7: "Demon", 8: "Blood"}
        for tier_id in range(9):
            tier_items = [(iid, item) for iid, item in items_by_id.items() if infer_tier_from_item_id(iid) == tier_id]
            if not tier_items:
                continue
            lines.append(f"### Tier {tier_id}: {tier_names.get(tier_id, '?')}")
            lines.append("")
            lines.append("| Item | Type | Attack | Defense | Weight |")
            lines.append("|---|---|---:|---:|---:|")
            for iid, item in sorted(tier_items):
                kind = item.kind if hasattr(item, 'kind') else "?"
                atk = item.attack if hasattr(item, 'attack') else "-"
                def_val = item.defense if hasattr(item, 'defense') else "-"
                weight = item.weight if hasattr(item, 'weight') else "-"
                lines.append(f"| {item.class_name} | {kind} | {atk} | {def_val} | {weight} |")
            lines.append("")

    # Item drop weights per depth tier
    if item_tables and item_tables.method_bodies:

        bodies = item_tables.method_bodies
        consumable_body = bodies.get("buildConsumableWeights", "")
        cross_tiers = parse_item_inline_tiers(consumable_body)
        weight_sections = [
            ("Weapons", bodies.get("buildWeaponWeights", "")),
            ("Armor", bodies.get("buildArmorWeights", "")),
            ("Consumables", consumable_body),
            ("High Quality", bodies.get("buildHighQualityWeights", "")),
            ("Merchant", bodies.get("buildMerchantWeights", "")),
        ]
        rendered_any = False
        for title, body in weight_sections:
            rows = parse_item_weight_report(body, cross_tiers=cross_tiers)
            if not rows:
                continue
            if not rendered_any:
                lines += [
                    "## Item Drop Weights",
                    "",
                    "Current tiered drop weights from `ItemSpecificValues.mc` (`build*Weights`).",
                    "",
                ]
                rendered_any = True
            lines += [
                f"### {title}",
                "",
                "| Weight | Item IDs | Tiers (depth ≤ max: weight) |",
                "|---|---|---|",
            ]
            for display, ids, tiers_text in rows:
                ids_text = ", ".join(str(i) for i in ids)
                lines.append(f"| {display} | {ids_text} | {tiers_text} |")
            lines.append("")

    lines += [
        "## Class Win Rates",
        "",
        "| Class ID | Actual | Target | Delta |",
        "|---:|---:|---:|---:|",
    ]
    for cid in sorted(class_win.keys()):
        actual = class_win[cid]
        target = class_target[cid]
        lines.append(f"| {cid} | {actual:.3f} | {target:.3f} | {actual - target:+.3f} |")

    lines += [
        "",
        "## Summary",
        "",
    ]

    # Class summary
    lines.append("### Classes")
    lines.append("")
    for cid in sorted(class_win.keys()):
        actual = class_win[cid]
        target = class_target[cid]
        delta = actual - target
        status = "ok" if abs(delta) <= 0.05 else ("weak" if delta < 0 else "strong")
        lines.append(f"- **Class {cid}**: {actual:.1%} (target {target:.1%}, {delta:+.1%}) [{status}]")
    lines.append("")

    # Depth segments
    def segment_stats(dwin, dtgt, dmin, dmax):
        vals = [(dwin[d], dtgt[d]) for d in dwin if dmin <= d <= dmax and d in dtgt]
        if not vals:
            return 0.0, 0.0, 0.0
        avg_actual = sum(a for a, _ in vals) / len(vals)
        avg_target = sum(t for _, t in vals) / len(vals)
        return avg_actual, avg_target, avg_actual - avg_target

    segments = [
        ("Early (1-25)", 1, 25),
        ("Mid (26-100)", 26, 100),
        ("Late (101-150)", 101, 150),
        ("Endgame (151-200)", 151, 200),
    ]
    lines.append("### Depth Segments")
    lines.append("")
    for name, dmin, dmax in segments:
        avg_a, avg_t, delta = segment_stats(depth_win, depth_target, dmin, dmax)
        status = "ok" if abs(delta) <= 0.05 else ("too easy" if delta > 0 else "too hard")
        lines.append(f"- **{name}**: {avg_a:.1%} (target {avg_t:.1%}, {delta:+.1%}) [{status}]")
    lines.append("")

    # Changes summary
    lines.append("### Changes Applied")
    lines.append("")
    lines.append(f"- Player updates: {len(adjustments['players'])}")
    lines.append(f"- Enemy updates: {len(adjustments['enemies'])}")
    lines.append(f"- Item updates: {len(adjustments['items'])}")
    lines.append(f"- Strict table updates: {len(adjustments.get('strictTables', []))}")

    lines += [
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
        "## Proposed Changes",
        "",
        f"- Player updates: {len(adjustments['players'])}",
        f"- Enemy updates: {len(adjustments['enemies'])}",
        f"- Item updates: {len(adjustments['items'])}",
        f"- Strict table updates: {len(adjustments.get('strictTables', []))}",
    ]

    (out_dir / "balance_report.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Auto-balance simulator for DungeonCrawler")
    parser.add_argument("--workspace", default=".", help="Repo root")
    parser.add_argument("--config", default="tools/balance/balance_config.json", help="Balance config file")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    parser.add_argument("--apply", action="store_true", help="Apply suggested stat updates in source files")
    parser.add_argument("--strict-realism", action="store_true", help="Use strict room simulation based on EnemySpecificValues and ItemSpecificValues")
    args = parser.parse_args()

    workspace = Path(args.workspace).resolve()
    config = json.loads(read((workspace / args.config).resolve()))
    random.seed(args.seed)

    strict_realism = bool(config.get("strictRealism", False)) or args.strict_realism
    room_size_cfg = config.get("roomSizeRange", {}) if isinstance(config.get("roomSizeRange", {}), dict) else {}
    min_room_size = int(room_size_cfg.get("min", DEFAULT_MIN_ROOM_SIZE))
    max_room_size = int(room_size_cfg.get("max", DEFAULT_MAX_ROOM_SIZE))
    rooms_per_depth_for_progression = int(config.get("roomsPerDepthForProgression", 9))
    initial_attribute_points = int(config.get("initialAttributePoints", 5))
    enemy_depth_scaling = config.get("enemyDepthScaling", {}) if isinstance(config.get("enemyDepthScaling", {}), dict) else {}
    depths = resolve_depths(config)

    players = parse_player_classes(workspace)
    start_attr_cfg = config.get("startAttributes", {}) if isinstance(config.get("startAttributes", {}), dict) else {}
    attr_min = int(start_attr_cfg.get("min", 0))
    attr_max = int(start_attr_cfg.get("max", 20))
    attr_sum = int(start_attr_cfg.get("sum", 50))
    for player in players.values():
        normalized = normalize_start_attributes(player.attributes, attr_min, attr_max, attr_sum)
        if normalized != player.attributes:
            print(
                f"Normalized start attributes for {player.class_name}: "
                f"{player.attributes} -> {normalized}"
            )
            player.attributes = normalized
    enemies = parse_enemy_files(workspace)
    items_by_class, items_by_id = parse_item_files(workspace)
    enemy_weights = parse_enemy_weights(workspace)
    class_multipliers = parse_class_multipliers(workspace)
    item_tables = parse_item_weight_tables(workspace) if strict_realism else None

    outcomes, class_win, class_target, depth_win, depth_target = simulate(
        rounds_per_depth=int(config["roundsPerDepth"]),
        depths=depths,
        target_rules=config["targetWinRateByDepth"],
        players=players,
        enemies=enemies,
        items_by_class=items_by_class,
        enemy_weights=enemy_weights,
        class_multipliers=class_multipliers,
        strict_realism=strict_realism,
        item_tables=item_tables,
        rooms_per_depth_for_progression=rooms_per_depth_for_progression,
        initial_attribute_points=initial_attribute_points,
        enemy_depth_scaling=enemy_depth_scaling,
        min_room_size=min_room_size,
        max_room_size=max_room_size,
    )

    adjustments = tune(
        workspace=workspace,
        config=config,
        players=players,
        enemies=enemies,
        items_by_id=items_by_id,
        outcomes=outcomes,
        class_win=class_win,
        class_target=class_target,
        depth_win=depth_win,
        depth_target=depth_target,
        strict_realism=strict_realism,
        enemy_weights=enemy_weights,
        item_tables=item_tables,
    )

    changed_files = 0
    if args.apply:
        changed_files = apply_adjustments(adjustments)

    write_report(
        workspace,
        config,
        class_win,
        class_target,
        depth_win,
        depth_target,
        adjustments,
        players,
        enemies,
        items_by_id,
        enemy_weights=enemy_weights,
        item_tables=item_tables,
    )

    print("Balance simulation complete")
    print(f"Encounters simulated: {len(outcomes)}")
    print(f"Class results: {len(class_win)} classes")
    print(f"Proposed player changes: {len(adjustments['players'])}")
    print(f"Proposed enemy changes: {len(adjustments['enemies'])}")
    print(f"Proposed item changes: {len(adjustments['items'])}")
    print(f"Proposed strict table changes: {len(adjustments.get('strictTables', []))}")
    if args.apply:
        print(f"Files changed: {changed_files}")
    print("Reports: tools/balance/balance_report.json and tools/balance/balance_report.md")


if __name__ == "__main__":
    main()
