#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import random
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple

ATTRIBUTE_KEYS = ["strength", "constitution", "dexterity", "intelligence", "wisdom", "charisma", "luck"]
ATTACK_WEIGHTS = {
    "STRENGTH": {"strength": 1.0, "constitution": 0.5, "dexterity": 0.25, "intelligence": 0.1, "wisdom": 0.05, "charisma": 0.01, "luck": 0.1},
    "CONSTITUTION": {"strength": 0.5, "constitution": 1.0, "dexterity": 0.25, "intelligence": 0.1, "wisdom": 0.05, "charisma": 0.01, "luck": 0.1},
    "DEXTERITY": {"strength": 0.25, "constitution": 0.5, "dexterity": 1.0, "intelligence": 0.25, "wisdom": 0.1, "charisma": 0.05, "luck": 0.1},
    "CHARISMA": {"strength": 0.01, "constitution": 0.05, "dexterity": 0.1, "intelligence": 0.25, "wisdom": 0.5, "charisma": 1.0, "luck": 0.25},
    "INTELLIGENCE": {"strength": 0.1, "constitution": 0.25, "dexterity": 0.5, "intelligence": 1.0, "wisdom": 0.5, "charisma": 0.25, "luck": 1.0},
    "WISDOM": {"strength": 0.05, "constitution": 0.1, "dexterity": 0.25, "intelligence": 0.5, "wisdom": 1.0, "charisma": 0.5, "luck": 0.25},
}


@dataclass
class Enemy:
    id: int
    name: str
    file: Path
    damage: int
    armor: int
    max_health: int
    kill_experience: int


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


def parse_attribute_bonus_dict(body: str) -> Dict[str, int]:
    m = re.search(r"attribute_bonus\s*=\s*\{(.*?)\};", body, re.S)
    result: Dict[str, int] = {}
    if not m:
        return result
    for att, val in re.findall(r":([a-zA-Z_]+)\s*=>\s*(-?\d+)", m.group(1)):
        result[att] = int(val)
    return result


def parse_enemy_files(workspace: Path) -> Dict[int, Enemy]:
    enemies_dir = workspace / "source/Engine/Entities/Enemies"
    defaults = {"damage": 10, "armor": 0, "maxHealth": 100, "kill_experience": 10}
    parsed: Dict[int, Enemy] = {}
    for file in enemies_dir.rglob("*.mc"):
        if file.name in {"Enemy.mc", "Enemies.mc"}:
            continue
        text = read(file)
        if "extends Enemy" not in text:
            continue
        body = extract_function_body(text, "initialize")
        if not body:
            continue
        enemy_id = parse_number_assignment(body, "id", -1)
        if enemy_id < 0:
            continue
        name_match = re.search(r"name\s*=\s*\"([^\"]+)\"\s*;", body)
        parsed[enemy_id] = Enemy(
            id=enemy_id,
            name=name_match.group(1) if name_match else file.stem,
            file=file,
            damage=parse_number_assignment(body, "damage", defaults["damage"]),
            armor=parse_number_assignment(body, "armor", defaults["armor"]),
            max_health=parse_number_assignment(body, "maxHealth", parse_number_assignment(body, "current_health", defaults["maxHealth"])),
            kill_experience=parse_number_assignment(body, "kill_experience", defaults["kill_experience"]),
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
        current_mana = parse_number_assignment(body, "current_mana", max_mana)
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


def parse_item_weight_tables(workspace: Path) -> ItemWeightTables:
    text = read(workspace / "source/Engine/Util/ItemSpecificValues.mc")

    def extract_method_body(method_name: str) -> str:
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

    def parse_table(method_name: str) -> Dict[int, List[Tuple[int, float]]]:
        body = extract_method_body(method_name)
        if not body:
            return {}
        table: Dict[int, List[Tuple[int, float]]] = {}
        entry_re = re.compile(r"(\d+)\s*=>\s*tieredWeight\(depth,\s*\[(.*?)\]\)", re.S)
        tier_re = re.compile(r":max\s*=>\s*(\d+)\s*,\s*:weight\s*=>\s*([\d.]+)")
        for entry in entry_re.finditer(body):
            item_id = int(entry.group(1))
            tiers_raw = entry.group(2)
            tiers = [(int(a), float(b)) for a, b in tier_re.findall(tiers_raw)]
            if tiers:
                table[item_id] = tiers
        return table

    return ItemWeightTables(
        weapon_weights=parse_table("buildWeaponWeights"),
        armor_weights=parse_table("buildArmorWeights"),
        consumable_weights=parse_table("buildConsumableWeights"),
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


def distribute_attribute_points(base_attributes: Dict[str, int], points: int) -> Dict[str, int]:
    if points <= 0:
        return dict(base_attributes)
    out = dict(base_attributes)
    priority = sorted(ATTRIBUTE_KEYS, key=lambda key: base_attributes.get(key, 0), reverse=True)
    if not priority:
        return out
    for idx in range(points):
        attr = priority[idx % len(priority)]
        out[attr] = out.get(attr, 0) + 1
    return out


def expected_enemy_profile_for_depth(
    depth: int,
    class_id: int,
    enemies: Dict[int, Enemy],
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
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
        enemy = enemies[enemy_id]
        total_weight += final_weight
        weighted_xp += final_weight * enemy.kill_experience
        weighted_cost += final_weight * int(entry["cost"])
    if total_weight <= 0:
        return 0.0, 1.0
    return weighted_xp / total_weight, max(1.0, weighted_cost / total_weight)


def projected_player_for_depth(
    player: PlayerClass,
    class_id: int,
    depth: int,
    enemies: Dict[int, Enemy],
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
    strict_realism: bool,
    enemy_count_multiplier: float,
    enemy_budget_scale_by_depth: List[Dict[str, float]],
    rooms_per_depth_for_progression: int,
    initial_attribute_points: int,
) -> Tuple[int, int, int, Dict[str, int]]:
    cumulative_experience = 0.0
    for explored_depth in range(1, depth):
        avg_xp, avg_cost = expected_enemy_profile_for_depth(
            depth=explored_depth,
            class_id=class_id,
            enemies=enemies,
            enemy_weights=enemy_weights,
            class_multipliers=class_multipliers,
        )
        if avg_xp <= 0:
            continue
        enemies_per_room = 1.0
        if strict_realism:
            budget_scale = value_for_depth(explored_depth, enemy_budget_scale_by_depth, 1.0)
            base_budget = 10 + explored_depth * 3.5
            budget = base_budget * max(0.2, enemy_count_multiplier) * max(0.2, budget_scale)
            enemies_per_room = clamp(budget / max(1.0, avg_cost), 1.0, 15.0)
        cumulative_experience += avg_xp * enemies_per_room * max(1, rooms_per_depth_for_progression)

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
    attributes = distribute_attribute_points(player.attributes, max(0, initial_attribute_points) + levels_gained * 3)
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
    n = len(armors)
    total = base
    for armor in armors:
        if armor.defense <= 0:
            continue
        weights = ATTACK_WEIGHTS.get(armor.defense_type, ATTACK_WEIGHTS["CONSTITUTION"])
        defense = armor.defense * 0.5
        for key in ATTRIBUTE_KEYS:
            if key == "luck":
                continue
            defense += attributes[key] * float(weights.get(key, 0.0)) / (4 * n)
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


def strict_room_enemy_ids(
    depth: int,
    class_id: int,
    enemy_weights: List[Dict[str, object]],
    class_multipliers: Dict[int, Dict[int, float]],
    enemy_count_multiplier: float,
    enemy_weight_jitter: float,
    enemy_budget_scale: float,
) -> List[int]:
    multipliers = class_multipliers.get(class_id, {})

    base_budget = 10 + depth * 3.5
    budget = int(max(4, base_budget * max(0.2, enemy_count_multiplier) * max(0.2, enemy_budget_scale)))
    max_enemies = int(min(15, 2 + depth // 7 + random.randint(0, 2)))
    generated: List[int] = []

    for _ in range(max_enemies):
        candidates: Dict[int, float] = {}
        for entry in enemy_weights:
            enemy_id = int(entry["id"])
            cost = int(entry["cost"])
            if cost > budget:
                continue
            base_w = tiered_weight(depth, entry["tiers"])
            if base_w <= 0:
                continue
            final_w = base_w * multipliers.get(enemy_id, 1.0)
            final_w = jitter_weight(final_w, enemy_weight_jitter)
            if final_w > 0:
                candidates[enemy_id] = final_w

        picked = weighted_pick(candidates)
        if picked is None:
            break

        picked_cost = next(int(e["cost"]) for e in enemy_weights if int(e["id"]) == picked)
        generated.append(picked)
        budget -= picked_cost
        if budget <= 0:
            break

    if not generated:
        fallback: Dict[int, float] = {}
        for entry in enemy_weights:
            enemy_id = int(entry["id"])
            base_w = tiered_weight(depth, entry["tiers"])
            if base_w > 0:
                fallback[enemy_id] = base_w
        picked = weighted_pick(fallback)
        if picked is not None:
            generated.append(picked)

    return generated


def strict_encounter_resources(
    depth: int,
    player: PlayerClass,
    item_tables: ItemWeightTables,
    item_weight_jitter: float,
    item_drop_scale: float,
) -> Dict[str, List[int]]:
    resources = {"health": [], "mana": []}

    mapping = {
        2000: ("health", 20),
        2002: ("health", 80),
        2004: ("health", player.max_health),
        2001: ("mana", 20),
        2003: ("mana", 80),
        2005: ("mana", player.max_mana),
    }

    for item_id, (kind, amount) in mapping.items():
        tiers = item_tables.consumable_weights.get(item_id)
        if not tiers:
            continue
        weight = jitter_weight(tiered_weight(depth, tiers), item_weight_jitter)
        chance = clamp((weight * max(0.2, item_drop_scale)) / 35.0, 0.0, 0.85)
        if random.random() < chance:
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
    enemy_damage = max(1, int(math.ceil(enemy.damage - p_defense)))

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

            dealt = max(1, int(math.ceil(player_damage - enemy.armor)))
            enemy_hp -= dealt

        if enemy_hp <= 0:
            return True

        player_hp -= enemy_damage
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
    resource_mode: str,
    item_tables: Optional[ItemWeightTables],
    item_weight_jitter: float,
    item_drop_scale: float,
) -> bool:
    player_hp = float(player.max_health)
    player_mana = float(player.current_mana)
    ammo = player.starting_ammo + random.randint(0, max(0, depth // 2))

    if resource_mode == "strict" and item_tables is not None:
        resources = strict_encounter_resources(depth, player, item_tables, item_weight_jitter, item_drop_scale)
    else:
        resources = estimate_encounter_resources(depth, player)
    health_potions = resources["health"]
    mana_potions = resources["mana"]

    max_turns = 160
    turn = 0
    while turn < max_turns and player_hp > 0 and len(room_enemies) > 0:
        turn += 1

        focused_enemy = room_enemies[0]
        available_weapons: List[Item] = []
        for weapon in weapons:
            if weapon.uses_ammo and ammo <= 0:
                continue
            available_weapons.append(weapon)

        should_heal = player_hp <= player.max_health * 0.45 and len(health_potions) > 0
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

            dealt = max(1, int(math.ceil(total_damage - focused_enemy.armor)))
            focused_enemy.max_health -= dealt
            if focused_enemy.max_health <= 0:
                room_enemies.pop(0)

        incoming = 0
        for enemy in room_enemies:
            incoming += max(1, int(math.ceil(enemy.damage - p_defense)))
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
    enemy_count_multiplier: float,
    enemy_weight_jitter: float,
    item_weight_jitter: float,
    enemy_budget_scale_by_depth: List[Dict[str, float]],
    item_drop_scale_by_depth: List[Dict[str, float]],
    rooms_per_depth_for_progression: int,
    initial_attribute_points: int,
) -> Tuple[List[EncounterOutcome], Dict[int, float], Dict[int, float], Dict[int, float], Dict[int, float]]:
    outcomes: List[EncounterOutcome] = []

    for class_id, player in players.items():
        multipliers = class_multipliers.get(class_id, {})
        equipped_items = [items_by_class[name] for name in player.starting_items if name in items_by_class]
        weapons = [x for x in equipped_items if x.kind == "weapon"]
        armors = [x for x in equipped_items if x.kind == "armor"]

        for depth in depths:
            _, progressed_health, progressed_mana, progressed_attributes = projected_player_for_depth(
                player=player,
                class_id=class_id,
                depth=depth,
                enemies=enemies,
                enemy_weights=enemy_weights,
                class_multipliers=class_multipliers,
                strict_realism=strict_realism,
                enemy_count_multiplier=enemy_count_multiplier,
                enemy_budget_scale_by_depth=enemy_budget_scale_by_depth,
                rooms_per_depth_for_progression=rooms_per_depth_for_progression,
                initial_attribute_points=initial_attribute_points,
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

            attrs = apply_item_bonuses(progressed_player.attributes, equipped_items)
            p_defense = compute_player_defense(attrs, armors)

            for _ in range(rounds_per_depth):
                if strict_realism:
                    depth_budget_scale = value_for_depth(depth, enemy_budget_scale_by_depth, 1.0)
                    depth_item_drop_scale = value_for_depth(depth, item_drop_scale_by_depth, 1.0)
                    room_enemy_ids = strict_room_enemy_ids(
                        depth=depth,
                        class_id=class_id,
                        enemy_weights=enemy_weights,
                        class_multipliers=class_multipliers,
                        enemy_count_multiplier=enemy_count_multiplier,
                        enemy_weight_jitter=enemy_weight_jitter,
                        enemy_budget_scale=depth_budget_scale,
                    )
                    if not room_enemy_ids:
                        continue
                    room_enemies = [
                        Enemy(
                            id=enemies[eid].id,
                            name=enemies[eid].name,
                            file=enemies[eid].file,
                            damage=enemies[eid].damage,
                            armor=enemies[eid].armor,
                            max_health=enemies[eid].max_health,
                            kill_experience=enemies[eid].kill_experience,
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
                        resource_mode="strict",
                        item_tables=item_tables,
                        item_weight_jitter=item_weight_jitter,
                        item_drop_scale=depth_item_drop_scale,
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
                    enemy = enemies[enemy_id]
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

    adjustments: Dict[str, List[Dict[str, object]]] = {"players": [], "enemies": [], "items": [], "strictTables": []}

    # Player adjustments
    for class_id, player in players.items():
        if class_id not in class_win:
            continue
        delta = class_target[class_id] - class_win[class_id]
        if abs(delta) <= tol:
            continue
        hp_factor = clamp(1.0 + delta * 0.25, 1 - max_adj, 1 + max_adj)
        att_factor = clamp(1.0 + delta * 0.18, 1 - max_adj, 1 + max_adj)

        new_hp = bounded_int(player.max_health * hp_factor, 1)
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

        if player.max_mana > 0:
            mana_factor = clamp(1.0 + delta * 0.20, 1 - max_adj, 1 + max_adj)
            new_max_mana = bounded_int(player.max_mana * mana_factor, 1)
            if new_max_mana != player.max_mana:
                adjustments["players"].append({
                    "classId": class_id,
                    "className": player.class_name,
                    "file": str(player.file),
                    "field": "maxMana",
                    "old": player.max_mana,
                    "new": new_max_mana,
                })
                adjustments["players"].append({
                    "classId": class_id,
                    "className": player.class_name,
                    "file": str(player.file),
                    "field": "current_mana",
                    "old": player.current_mana,
                    "new": new_max_mana,
                })

        for att, old in player.attributes.items():
            if att == "luck":
                continue
            new_val = bounded_int(old * att_factor, 0)
            if new_val != old:
                adjustments["players"].append({
                    "classId": class_id,
                    "className": player.class_name,
                    "file": str(player.file),
                    "field": f":{att}",
                    "old": old,
                    "new": new_val,
                })

    # Enemy adjustments
    by_enemy: Dict[int, List[EncounterOutcome]] = {}
    for row in outcomes:
        by_enemy.setdefault(row.enemy_id, []).append(row)

    for enemy_id, rows in by_enemy.items():
        if enemy_id not in enemies or not rows:
            continue
        enemy = enemies[enemy_id]
        winrate = sum(1 for r in rows if r.win) / len(rows)
        target = sum(depth_target[r.depth] for r in rows) / len(rows)
        delta = target - winrate
        if abs(delta) <= tol:
            continue

        factor = clamp(1.0 - delta * 0.35, 1 - max_adj, 1 + max_adj)
        new_damage = bounded_int(enemy.damage * factor, 1)
        new_hp = bounded_int(enemy.max_health * factor, 1)
        new_armor = bounded_int(enemy.armor * factor, 0)

        if new_damage != enemy.damage:
            adjustments["enemies"].append({"enemyId": enemy_id, "enemyName": enemy.name, "file": str(enemy.file), "field": "damage", "old": enemy.damage, "new": new_damage})
        if new_hp != enemy.max_health:
            adjustments["enemies"].append({"enemyId": enemy_id, "enemyName": enemy.name, "file": str(enemy.file), "field": "maxHealth", "old": enemy.max_health, "new": new_hp})
        if new_armor != enemy.armor:
            adjustments["enemies"].append({"enemyId": enemy_id, "enemyName": enemy.name, "file": str(enemy.file), "field": "armor", "old": enemy.armor, "new": new_armor})

    # Item adjustments by tier pressure (uses depth curve error)
    tier_delta: Dict[int, float] = {}
    for depth, actual in depth_win.items():
        t = depth_target[depth] - actual
        tier_guess = min(8, max(0, (depth - 1) // 3))
        tier_delta.setdefault(tier_guess, 0.0)
        tier_delta[tier_guess] += t

    for tier in list(tier_delta.keys()):
        count = sum(1 for d in depth_win.keys() if min(8, max(0, (d - 1) // 3)) == tier)
        if count > 0:
            tier_delta[tier] = tier_delta[tier] / count

    for item_id, item in items_by_id.items():
        tier = infer_tier_from_item_id(item_id)
        if tier is None or tier not in tier_delta:
            continue
        delta = tier_delta[tier]
        if abs(delta) <= tol:
            continue
        factor = clamp(1.0 + delta * 0.25, 1 - max_adj, 1 + max_adj)

        if item.kind == "weapon" and item.attack > 0:
            new_attack = bounded_int(item.attack * factor, 1)
            if new_attack != item.attack:
                adjustments["items"].append({"itemId": item_id, "itemName": item.class_name, "file": str(item.file), "field": "attack", "old": item.attack, "new": new_attack})
        if item.kind == "armor" and item.defense > 0:
            new_defense = bounded_int(item.defense * factor, 0)
            if new_defense != item.defense:
                adjustments["items"].append({"itemId": item_id, "itemName": item.class_name, "file": str(item.file), "field": "defense", "old": item.defense, "new": new_defense})

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


def update_initialize_body(text: str, replacement_fn) -> str:
    marker = "function initialize"
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
                    out = re.sub(rf"((?:self\.)?{re.escape(field)}\s*=\s*){re.escape(old)}(\s*;)", rf"\g<1>{new}\2", out, count=1)
            return out

        updated = update_initialize_body(text, repl)

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
    variation = config.get("variation", {}) if isinstance(config.get("variation", {}), dict) else {}
    enemy_count_multiplier = float(variation.get("enemyCountMultiplier", 1.0))
    enemy_weight_jitter = float(variation.get("enemyWeightJitter", 0.0))
    item_weight_jitter = float(variation.get("itemWeightJitter", 0.0))
    enemy_budget_scale_by_depth = variation.get("enemyBudgetScaleByDepth", []) if isinstance(variation.get("enemyBudgetScaleByDepth", []), list) else []
    item_drop_scale_by_depth = variation.get("itemDropScaleByDepth", []) if isinstance(variation.get("itemDropScaleByDepth", []), list) else []
    rooms_per_depth_for_progression = int(config.get("roomsPerDepthForProgression", 4))
    initial_attribute_points = int(config.get("initialAttributePoints", 5))
    depths = resolve_depths(config)

    players = parse_player_classes(workspace)
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
        enemy_count_multiplier=enemy_count_multiplier,
        enemy_weight_jitter=enemy_weight_jitter,
        item_weight_jitter=item_weight_jitter,
        enemy_budget_scale_by_depth=enemy_budget_scale_by_depth,
        item_drop_scale_by_depth=item_drop_scale_by_depth,
        rooms_per_depth_for_progression=rooms_per_depth_for_progression,
        initial_attribute_points=initial_attribute_points,
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

    write_report(workspace, config, class_win, class_target, depth_win, depth_target, adjustments)

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
