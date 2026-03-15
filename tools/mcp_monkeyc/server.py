from __future__ import annotations

import base64
import os
import re
import shutil
import subprocess
import sys
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

from mcp.server.fastmcp import FastMCP
from PIL import Image, ImageDraw


mcp = FastMCP("dungeoncrawler-monkeyc")


WEAPON_PREFIXES = [
    "steel_",
    "bronze_",
    "fire_",
    "ice_",
    "grass_",
    "water_",
    "gold_",
    "demon_",
    "blood_",
    "poison_",
    "platinum_",
    "heaven_",
    "hell_",
]

WEAPON_SUFFIXES = [
    "sword",
    "staff",
    "",
    "axe",
    "lance",
    "greatsword",
    "dagger",
    "bow",
    "spell",
    "",
    "katana",
    "",
    "",
]

ARMOR_PREFIXES = [
    "steel_",
    "bronze_",
    "fire_",
    "ice_",
    "grass_",
    "water_",
    "gold_",
    "demon_",
    "blood_",
]

ARMOR_SUFFIXES = [
    "helmet",
    "armor",
    "gauntlets",
    "leg_armor",
    "ring1",
    "ring2",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
]

ALLOWED_FINAL_IMAGE_SIZES = {
    "16x16": (16, 16),
}

STYLE_PRESETS = {
    "watch16": "pixel art game sprite, single centered subject, transparent background, no text, no watermark, no frame, clear silhouette, high contrast, crisp edges, designed for strong readability when downscaled to 16x16",
    "watch16_1bit": "1-bit pixel art game sprite, single centered subject, transparent background, no text, no watermark, no frame, clear silhouette, very high contrast, crisp edges, designed for strong readability when downscaled to 16x16",
}

TOOL_CATALOG: list[dict[str, Any]] = [
    {"tool": "build_for_device", "category": "build", "use_when": "Build for one Garmin product"},
    {"tool": "build_for_products", "category": "build", "use_when": "Build for multiple products"},
    {"tool": "run_in_simulator", "category": "build", "use_when": "Launch latest or specific PRG in simulator"},
    {"tool": "run_release_build_script", "category": "release", "use_when": "Run release packaging workflow"},
    {"tool": "check_monkeyc_environment", "category": "environment", "use_when": "Verify Java/SDK/key setup"},
    {"tool": "list_connectiq_sdks", "category": "environment", "use_when": "Inspect installed Connect IQ SDKs"},
    {"tool": "list_manifest_products", "category": "manifest", "use_when": "Read supported devices from manifest"},
    {"tool": "add_manifest_product", "category": "manifest", "use_when": "Add device to manifest"},
    {"tool": "remove_manifest_product", "category": "manifest", "use_when": "Remove device from manifest"},
    {"tool": "register_drawable", "category": "assets", "use_when": "Add one drawable XML mapping"},
    {"tool": "register_drawables_from_folder", "category": "assets", "use_when": "Bulk-register PNG drawables"},
    {"tool": "validate_drawables_resources", "category": "assets", "use_when": "Check drawable XML/file consistency"},
    {"tool": "optimize_drawable_png", "category": "assets", "use_when": "Reduce colors/size for watch assets"},
    {"tool": "analyze_drawable_usage", "category": "assets", "use_when": "Find unused/missing drawable ids"},
    {"tool": "split_items_spritesheet", "category": "assets", "use_when": "Slice tiles from items spritesheet"},
    {"tool": "generate_image_and_embed", "category": "assets", "use_when": "Generate + resize + register sprite"},
    {"tool": "scaffold_item", "category": "scaffold", "use_when": "Create new item class + registrations"},
    {"tool": "scaffold_enemy", "category": "scaffold", "use_when": "Create new enemy class + registrations"},
    {"tool": "scaffold_player_class", "category": "scaffold", "use_when": "Create new player class + registration"},
    {"tool": "run_balance_script", "category": "balance", "use_when": "Run balancing simulation script"},
]

TOOL_KEYWORDS: dict[str, set[str]] = {
    "build_for_device": {"build", "compile", "device", "venu", "debug", "release"},
    "build_for_products": {"build", "multi", "devices", "products", "matrix"},
    "run_in_simulator": {"simulate", "simulator", "run", "monkeydo", "preview"},
    "run_release_build_script": {"release", "package", "tag", "deploy"},
    "check_monkeyc_environment": {"environment", "setup", "sdk", "java", "key", "precheck"},
    "list_connectiq_sdks": {"sdk", "list", "versions", "connectiq"},
    "list_manifest_products": {"manifest", "products", "devices", "list"},
    "add_manifest_product": {"manifest", "add", "product", "device"},
    "remove_manifest_product": {"manifest", "remove", "product", "device"},
    "register_drawable": {"drawable", "register", "xml", "bitmap"},
    "register_drawables_from_folder": {"drawable", "register", "folder", "bulk"},
    "validate_drawables_resources": {"validate", "drawables", "missing", "duplicates", "resources"},
    "optimize_drawable_png": {"optimize", "png", "palette", "colors", "compress"},
    "analyze_drawable_usage": {"analyze", "drawables", "usage", "unused", "missing"},
    "split_items_spritesheet": {"spritesheet", "split", "tiles", "items"},
    "generate_image_and_embed": {"image", "generate", "sprite", "openrouter", "embed"},
    "scaffold_item": {"create", "new", "item", "weapon", "armor", "consumable", "scaffold"},
    "scaffold_enemy": {"create", "new", "enemy", "monster", "spawn", "scaffold"},
    "scaffold_player_class": {"create", "new", "player", "class", "hero", "scaffold"},
    "run_balance_script": {"balance", "rounds", "simulation", "tuning"},
}


def _workspace_root() -> Path:
    env_root = os.environ.get("MONKEYC_WORKSPACE")
    if env_root:
        return Path(env_root).resolve()
    return Path.cwd().resolve()


def _abs_from_workspace(path: str) -> Path:
    raw = Path(path)
    if raw.is_absolute():
        return raw.resolve()
    return (_workspace_root() / raw).resolve()


def _to_drawable_relative_png(path: Path) -> str:
    drawables_root = (_workspace_root() / "resources" / "drawables").resolve()
    try:
        relative = path.resolve().relative_to(drawables_root)
        return str(relative).replace("\\", "/")
    except ValueError:
        return str(path.name)


def _resolve_monkeybrains_jar(custom_path: str | None) -> Path:
    if custom_path:
        candidate = Path(custom_path).resolve()
        if candidate.exists():
            return candidate
        raise FileNotFoundError(f"monkeybrains.jar not found at: {candidate}")

    appdata = os.environ.get("APPDATA")
    if not appdata:
        raise FileNotFoundError("APPDATA is missing and no monkeybrains jar path was provided.")

    sdk_root = Path(appdata) / "Garmin" / "ConnectIQ" / "Sdks"
    if not sdk_root.exists():
        raise FileNotFoundError(f"SDK folder not found: {sdk_root}")

    jars = sorted(sdk_root.rglob("monkeybrains.jar"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not jars:
        raise FileNotFoundError(f"No monkeybrains.jar found below: {sdk_root}")
    return jars[0]


def _sdk_root() -> Path:
    appdata = os.environ.get("APPDATA")
    if not appdata:
        raise FileNotFoundError("APPDATA is missing.")

    sdk_root = Path(appdata) / "Garmin" / "ConnectIQ" / "Sdks"
    if not sdk_root.exists():
        raise FileNotFoundError(f"SDK folder not found: {sdk_root}")
    return sdk_root


def _resolve_sdk_tool(tool_name: str, custom_path: str | None = None) -> Path:
    if custom_path:
        candidate = Path(custom_path).resolve()
        if candidate.exists():
            return candidate
        raise FileNotFoundError(f"Tool not found at: {candidate}")

    sdk_root = _sdk_root()
    patterns = [
        f"**/{tool_name}",
        f"**/{tool_name}.exe",
        f"**/{tool_name}.bat",
        f"**/{tool_name}.cmd",
    ]
    hits: list[Path] = []
    for pattern in patterns:
        hits.extend(sdk_root.glob(pattern))

    if not hits:
        raise FileNotFoundError(f"Tool '{tool_name}' not found under: {sdk_root}")

    hits = sorted(set(path.resolve() for path in hits), key=lambda p: p.stat().st_mtime, reverse=True)
    return hits[0]


def _find_latest_prg(product: str | None = None) -> Path | None:
    bin_dir = _workspace_root() / "bin"
    if not bin_dir.exists():
        return None

    patterns: list[str] = []
    if product:
        patterns.extend(
            [
                f"mcp-DungeonCrawler-{product}-release.prg",
                f"mcp-DungeonCrawler-{product}-debug.prg",
                f"*{product}*.prg",
            ]
        )
    patterns.extend(["optimized-DungeonCrawler.prg", "DungeonCrawler.prg", "*.prg"])

    for pattern in patterns:
        matches = sorted(bin_dir.glob(pattern), key=lambda p: p.stat().st_mtime, reverse=True)
        if matches:
            return matches[0]
    return None


def _drawable_tag(bitmap_id: str, filename: str) -> str:
    return f'    <bitmap id="{bitmap_id}" filename="{filename}" packingFormat="png" />\n'


def _normalize_bitmap_id(name: str) -> str:
    cleaned = re.sub(r"[^a-zA-Z0-9_]+", "_", name.strip())
    cleaned = re.sub(r"_+", "_", cleaned)
    return cleaned.strip("_")


def _parse_drawables_xml(drawables_xml_path: str) -> dict[str, Any]:
    xml_path = _abs_from_workspace(drawables_xml_path)
    if not xml_path.exists():
        return {
            "ok": False,
            "message": f"Drawables XML not found: {xml_path}",
            "xml_path": str(xml_path),
        }

    xml_text = xml_path.read_text(encoding="utf-8")
    pattern = re.compile(r'<bitmap\s+[^>]*id="([^"]+)"[^>]*?(?:filename="([^"]+)")?[^>]*/?>')
    entries: list[dict[str, str | None]] = []
    for match in pattern.finditer(xml_text):
        entries.append(
            {
                "id": match.group(1),
                "filename": match.group(2),
            }
        )

    return {
        "ok": True,
        "xml_path": str(xml_path),
        "xml_text": xml_text,
        "entries": entries,
    }


def _register_drawable_internal(bitmap_id: str, filename: str, drawables_xml_path: str) -> dict[str, Any]:
    xml_path = _abs_from_workspace(drawables_xml_path)
    if not xml_path.exists():
        return {
            "ok": False,
            "message": f"Drawables XML not found: {xml_path}",
        }

    xml_text = xml_path.read_text(encoding="utf-8")
    if f'id="{bitmap_id}"' in xml_text:
        return {
            "ok": True,
            "message": f"Drawable id already exists: {bitmap_id}",
            "xml_path": str(xml_path),
            "already_exists": True,
        }

    closing_tag = "</drawables>"
    if closing_tag not in xml_text:
        return {
            "ok": False,
            "message": f"Invalid XML format in {xml_path}: missing </drawables>",
        }

    entry = _drawable_tag(bitmap_id, filename)
    xml_text = xml_text.replace(closing_tag, entry + closing_tag)
    xml_path.write_text(xml_text, encoding="utf-8")

    return {
        "ok": True,
        "message": f"Registered drawable '{bitmap_id}' in {xml_path}",
        "xml_path": str(xml_path),
        "already_exists": False,
    }


def _item_name_from_index(index_1_based: int) -> str | None:
    idx = index_1_based - 1
    if 0 <= idx < 168:
        prefix = WEAPON_PREFIXES[idx // 13]
        suffix = WEAPON_SUFFIXES[idx % 13]
        return f"{prefix}{suffix}" if suffix else None
    if 181 < idx < 292:
        armor_idx = idx - 182
        prefix = ARMOR_PREFIXES[armor_idx // 13]
        suffix = ARMOR_SUFFIXES[armor_idx % 13]
        return f"{prefix}{suffix}" if suffix else None
    if idx == 312:
        return "potion_health"
    if idx == 313:
        return "potion_mana"
    if idx == 330:
        return "key"
    if idx == 340:
        return "gold"
    if idx == 344:
        return "diamond"
    if idx == 345:
        return "gold_big"
    return None


def _decode_final_size(size: str) -> tuple[int, int] | None:
    return ALLOWED_FINAL_IMAGE_SIZES.get(size)


def _build_generation_prompt(
    base_prompt: str,
    enforce_style_policy: bool,
    style_preset: str,
    style_suffix: str | None,
) -> str:
    if not enforce_style_policy:
        return base_prompt

    preset_key = style_preset.strip().lower()
    preset_text = STYLE_PRESETS.get(preset_key, STYLE_PRESETS["watch16"])
    parts = [base_prompt.strip(), f"Style constraints: {preset_text}"]

    if style_suffix and style_suffix.strip():
        parts.append(f"Additional constraints: {style_suffix.strip()}")

    return "\n\n".join(parts)


def _extract_gemini_image_bytes(response: Any) -> bytes | None:
    candidates = getattr(response, "candidates", None) or []
    for candidate in candidates:
        content = getattr(candidate, "content", None)
        parts = getattr(content, "parts", None) or []
        for part in parts:
            inline_data = getattr(part, "inline_data", None) or getattr(part, "inlineData", None)
            if not inline_data:
                continue
            data = getattr(inline_data, "data", None)
            if not data:
                continue
            if isinstance(data, (bytes, bytearray)):
                return bytes(data)
            if isinstance(data, str):
                return base64.b64decode(data)

    generated_images = getattr(response, "generated_images", None) or []
    for generated in generated_images:
        image = getattr(generated, "image", None)
        data = getattr(image, "image_bytes", None) if image else None
        if data:
            return bytes(data)

    return None


def _extract_svg_markup_from_text(text: str) -> str | None:
    fenced = re.search(r"```svg\s*(.*?)```", text, flags=re.IGNORECASE | re.DOTALL)
    if fenced:
        candidate = fenced.group(1).strip()
        if "<svg" in candidate and "</svg>" in candidate:
            return candidate

    start = text.find("<svg")
    end = text.rfind("</svg>")
    if start >= 0 and end > start:
        return text[start : end + len("</svg>")]
    return None


def _parse_svg_style_class_fills(svg_markup: str) -> dict[str, str]:
    class_fills: dict[str, str] = {}
    for style_match in re.finditer(r"<style[^>]*>(.*?)</style>", svg_markup, flags=re.IGNORECASE | re.DOTALL):
        style_block = style_match.group(1)
        for rule_match in re.finditer(r"\.([A-Za-z0-9_-]+)\s*\{([^}]*)\}", style_block):
            class_name = rule_match.group(1)
            rule_body = rule_match.group(2)
            fill_match = re.search(r"fill\s*:\s*([^;]+)", rule_body)
            if fill_match:
                class_fills[class_name] = fill_match.group(1).strip()
    return class_fills


def _svg_color_to_rgba(fill_value: str | None) -> tuple[int, int, int, int] | None:
    if not fill_value:
        return None

    value = fill_value.strip().strip('"').strip("'").lower()
    if value in {"none", "transparent"}:
        return None

    if value.startswith("#"):
        hex_part = value[1:]
        if len(hex_part) == 3:
            r = int(hex_part[0] * 2, 16)
            g = int(hex_part[1] * 2, 16)
            b = int(hex_part[2] * 2, 16)
            return (r, g, b, 255)
        if len(hex_part) == 6:
            r = int(hex_part[0:2], 16)
            g = int(hex_part[2:4], 16)
            b = int(hex_part[4:6], 16)
            return (r, g, b, 255)
    return None


def _svg_markup_to_png_bytes(svg_markup: str) -> bytes:
    root = ET.fromstring(svg_markup)
    class_fills = _parse_svg_style_class_fills(svg_markup)

    view_box = root.attrib.get("viewBox")
    width = 64
    height = 64
    if view_box:
        parts = re.split(r"[\s,]+", view_box.strip())
        if len(parts) == 4:
            width = max(1, int(float(parts[2])))
            height = max(1, int(float(parts[3])))
    else:
        raw_w = root.attrib.get("width")
        raw_h = root.attrib.get("height")
        if raw_w and raw_h:
            width = max(1, int(float(re.sub(r"[^0-9.]+", "", raw_w) or "64")))
            height = max(1, int(float(re.sub(r"[^0-9.]+", "", raw_h) or "64")))

    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    for elem in root.iter():
        tag = elem.tag.split("}")[-1]
        if tag != "rect":
            continue

        raw_fill = elem.attrib.get("fill")
        if not raw_fill:
            style_attr = elem.attrib.get("style", "")
            fill_match = re.search(r"fill\s*:\s*([^;]+)", style_attr)
            if fill_match:
                raw_fill = fill_match.group(1).strip()

        if not raw_fill:
            class_attr = elem.attrib.get("class", "")
            for class_name in class_attr.split():
                if class_name in class_fills:
                    raw_fill = class_fills[class_name]
                    break

        fill = _svg_color_to_rgba(raw_fill)
        if fill is None:
            continue

        x = float(elem.attrib.get("x", "0"))
        y = float(elem.attrib.get("y", "0"))
        w = float(elem.attrib.get("width", "0"))
        h = float(elem.attrib.get("height", "0"))
        if w <= 0 or h <= 0:
            continue

        x1 = int(round(x))
        y1 = int(round(y))
        x2 = int(round(x + w - 1))
        y2 = int(round(y + h - 1))
        draw.rectangle([x1, y1, x2, y2], fill=fill)

    from io import BytesIO

    buffer = BytesIO()
    image.save(buffer, format="PNG")
    return buffer.getvalue()


def _extract_openrouter_image_bytes_from_completion(completion: Any) -> tuple[bytes | None, str | None]:
    try:
        payload = completion.model_dump()
    except Exception:
        payload = {}

    choices = payload.get("choices") or []
    if not choices:
        return None, "OpenRouter returned no choices."

    message = (choices[0] or {}).get("message") or {}
    content = message.get("content")

    if isinstance(content, list):
        text_parts: list[str] = []
        for part in content:
            if not isinstance(part, dict):
                continue
            if part.get("type") == "image_url":
                image_url = (part.get("image_url") or {}).get("url")
                if isinstance(image_url, str) and image_url.startswith("data:image"):
                    marker = "base64,"
                    idx = image_url.find(marker)
                    if idx >= 0:
                        try:
                            return base64.b64decode(image_url[idx + len(marker) :]), None
                        except Exception as err:
                            return None, f"Failed to decode OpenRouter data URL: {err}"
                elif isinstance(image_url, str) and image_url.startswith("http"):
                    try:
                        with urllib.request.urlopen(image_url, timeout=60) as response:
                            return response.read(), None
                    except Exception as err:
                        return None, f"Failed to download OpenRouter image URL: {err}"

            if part.get("type") == "text" and isinstance(part.get("text"), str):
                text_parts.append(part.get("text"))

        if text_parts:
            content = "\n".join(text_parts)

    if isinstance(content, str):
        data_url_match = re.search(r"data:image/[^;]+;base64,([A-Za-z0-9+/=]+)", content)
        if data_url_match:
            try:
                return base64.b64decode(data_url_match.group(1)), None
            except Exception as err:
                return None, f"Failed to decode image base64 in OpenRouter text response: {err}"

        md_url_match = re.search(r"!\[[^\]]*\]\((https?://[^\)]+)\)", content)
        if md_url_match:
            image_url = md_url_match.group(1)
            try:
                with urllib.request.urlopen(image_url, timeout=60) as response:
                    return response.read(), None
            except Exception as err:
                return None, f"Failed to download markdown image URL from OpenRouter response: {err}"

        plain_url_match = re.search(r"https?://\S+", content)
        if plain_url_match and any(ext in plain_url_match.group(0).lower() for ext in [".png", ".jpg", ".jpeg", ".webp"]):
            image_url = plain_url_match.group(0).rstrip(".,)")
            try:
                with urllib.request.urlopen(image_url, timeout=60) as response:
                    return response.read(), None
            except Exception as err:
                return None, f"Failed to download plain image URL from OpenRouter response: {err}"

        svg_markup = _extract_svg_markup_from_text(content)
        if svg_markup:
            try:
                return _svg_markup_to_png_bytes(svg_markup), None
            except Exception as err:
                return None, f"OpenRouter returned SVG but conversion to PNG failed: {err}"

        preview = content[:240].replace("\n", " ")
        return None, f"OpenRouter model returned text instead of image data. Preview: {preview}"

    return None, "OpenRouter response did not contain supported image content."


def _to_pascal_case(name: str) -> str:
    chunks = re.split(r"[^a-zA-Z0-9]+", name.strip())
    cleaned = [chunk for chunk in chunks if chunk]
    return "".join(chunk[0].upper() + chunk[1:] for chunk in cleaned)


def _pascal_to_display_name(class_name: str) -> str:
    parts = re.findall(r"[A-Z][a-z0-9]*|[0-9]+", class_name)
    if not parts:
        return class_name
    return " ".join(parts)


def _snake_case(name: str) -> str:
    normalized = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", name)
    normalized = re.sub(r"[^a-zA-Z0-9]+", "_", normalized)
    normalized = re.sub(r"_+", "_", normalized)
    return normalized.strip("_").lower()


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _update_numeric_id_array(module_text: str, var_name: str, new_id: int, inline: bool = False) -> tuple[str, bool]:
    pattern = re.compile(rf"(var\s+{var_name}\s+as\s+Array<Number>\s*=\s*\[)(.*?)(\];)", re.DOTALL)
    match = pattern.search(module_text)
    if not match:
        raise ValueError(f"Could not find array '{var_name}' in module.")

    numbers = [int(token) for token in re.findall(r"\d+", match.group(2))]
    if new_id in numbers:
        return module_text, False

    numbers.append(new_id)
    numbers = sorted(set(numbers))

    if inline:
        body = ", ".join(str(n) for n in numbers)
        replacement = f"{match.group(1)}{body}{match.group(3)}"
    else:
        lines: list[str] = []
        for i in range(0, len(numbers), 10):
            lines.append("        " + ", ".join(str(n) for n in numbers[i : i + 10]))
        replacement = f"{match.group(1)}\n" + ",\n".join(lines) + f"\n    {match.group(3)}"

    updated = module_text[: match.start()] + replacement + module_text[match.end() :]
    return updated, True


def _insert_case_before_default(module_text: str, switch_anchor: str, case_snippet: str) -> tuple[str, bool]:
    switch_start = module_text.find(switch_anchor)
    if switch_start < 0:
        raise ValueError("Could not locate switch anchor in module.")

    if case_snippet.strip() in module_text:
        return module_text, False

    default_idx = module_text.find("default:", switch_start)
    if default_idx < 0:
        raise ValueError("Could not locate default case in switch.")

    line_start = module_text.rfind("\n", 0, default_idx)
    insertion_idx = 0 if line_start < 0 else line_start + 1

    normalized_case = case_snippet
    if not normalized_case.endswith("\n"):
        normalized_case += "\n"

    updated = module_text[:insertion_idx] + normalized_case + module_text[insertion_idx:]
    return updated, True


def _insert_enemy_weight_entry(module_text: str, enemy_id: int, cost: int, weight: int) -> tuple[str, bool]:
    if f":id => {enemy_id}" in module_text:
        return module_text, False

    marker = "var dungeon_enemies as Array<Dictionary<Symbol, Numeric>> = ["
    start = module_text.find(marker)
    if start < 0:
        raise ValueError("Could not locate dungeon_enemies array.")

    end = module_text.find("];", start)
    if end < 0:
        raise ValueError("Could not locate end of dungeon_enemies array.")

    entry = f"        {{ :id => {enemy_id}, :cost => {cost}, :weight => {weight} }},\n"
    updated = module_text[:end] + entry + module_text[end:]
    return updated, True


def _insert_item_factory_case(module_text: str, item_id: int, class_name: str, item_kind: str) -> tuple[str, bool]:
    case_line = f"                case {item_id}: return new {class_name}();\n"
    if case_line.strip() in module_text:
        return module_text, False

    kind = item_kind.strip().lower()
    if kind == "weapon":
        marker = "if (id < 1000) {"
    elif kind == "armor":
        marker = "if (id < 2000) {"
    elif kind == "consumable":
        marker = "if (id < 3000) {"
    else:
        raise ValueError(f"Unsupported item kind for item factory insertion: {item_kind}")

    start = module_text.find(marker)
    if start < 0:
        raise ValueError("Could not locate target item id range block.")

    default_idx = module_text.find("default: return null;", start)
    if default_idx < 0:
        raise ValueError("Could not locate default return in item factory switch.")

    updated = module_text[:default_idx] + case_line + module_text[default_idx:]
    return updated, True


def _next_item_id_for_kind(items_module_text: str, item_kind: str) -> int:
    match = re.search(r"var\s+item_ids\s+as\s+Array<Number>\s*=\s*\[(.*?)\];", items_module_text, flags=re.DOTALL)
    if not match:
        raise ValueError("Could not locate item_ids in Items.mc")

    item_ids = [int(token) for token in re.findall(r"\d+", match.group(1))]
    kind = item_kind.strip().lower()
    if kind == "weapon":
        low, high = 0, 999
    elif kind == "armor":
        low, high = 1000, 1999
    elif kind == "consumable":
        low, high = 2000, 2999
    else:
        raise ValueError(f"Unsupported item kind: {item_kind}")

    in_range = sorted(item_id for item_id in item_ids if low <= item_id <= high)
    if not in_range:
        return low

    next_id = in_range[-1] + 1
    if next_id > high:
        raise ValueError(f"No free item id left in range {low}-{high} for kind '{kind}'.")
    return next_id


def _insert_item_specific_weight_entry(
    module_text: str,
    item_id: int,
    item_kind: str,
    weight_expression: str,
) -> tuple[str, bool]:
    kind = item_kind.strip().lower()
    if kind == "weapon":
        marker = "private function buildWeaponWeights(depth as Number)"
    elif kind == "armor":
        marker = "private function buildArmorWeights(depth as Number)"
    elif kind == "consumable":
        marker = "private function buildConsumableWeights(depth as Number)"
    else:
        raise ValueError(f"Unsupported item kind for ItemSpecificValues: {item_kind}")

    fn_start = module_text.find(marker)
    if fn_start < 0:
        raise ValueError("Could not locate target function in ItemSpecificValues.mc")

    dict_start = module_text.find("return {", fn_start)
    if dict_start < 0:
        raise ValueError("Could not locate return dictionary in ItemSpecificValues.mc")

    dict_end = module_text.find("} as Dictionary<Number, Numeric>;", dict_start)
    if dict_end < 0:
        raise ValueError("Could not locate dictionary end in ItemSpecificValues.mc")

    scoped = module_text[dict_start:dict_end]
    if f"{item_id} =>" in scoped:
        return module_text, False

    insertion_idx = dict_end
    id_matches = list(re.finditer(r"^\s*(\d+)\s*=>", scoped, flags=re.MULTILINE))
    for match in id_matches:
        existing_id = int(match.group(1))
        if existing_id > item_id:
            insertion_idx = dict_start + match.start()
            break

    if insertion_idx == dict_end:
        before = module_text[:dict_end].rstrip()
        separator = "\n" if before.endswith(",") else ",\n"
        insertion = f"{separator}            {item_id} => {weight_expression}"
    else:
        insertion = f"            {item_id} => {weight_expression},\n"

    updated = module_text[:insertion_idx] + insertion + module_text[insertion_idx:]
    return updated, True


def _insert_enemy_specific_weight_entry(
    module_text: str,
    enemy_id: int,
    cost: int,
    weight_expression: str,
    enemy_name: str,
) -> tuple[str, bool]:
    fn_marker = "private function getEnemyWeightsForDepth(depth as Number)"
    fn_start = module_text.find(fn_marker)
    if fn_start < 0:
        raise ValueError("Could not locate getEnemyWeightsForDepth in EnemySpecificValues.mc")

    array_start_marker = "var enemy_weights = ["
    array_start = module_text.find(array_start_marker, fn_start)
    if array_start < 0:
        raise ValueError("Could not locate enemy_weights array in EnemySpecificValues.mc")

    array_end = module_text.find("] as Array<Dictionary<Symbol, Number>>;", array_start)
    if array_end < 0:
        raise ValueError("Could not locate enemy_weights array end in EnemySpecificValues.mc")

    scoped = module_text[array_start:array_end]
    if f":id => {enemy_id}" in scoped:
        return module_text, False

    insertion_idx = array_end
    id_matches = list(re.finditer(r"^\s*\{:id =>\s*(\d+)\s*,", scoped, flags=re.MULTILINE))
    for match in id_matches:
        existing_id = int(match.group(1))
        if existing_id > enemy_id:
            insertion_idx = array_start + match.start()
            break

    if insertion_idx == array_end:
        before = module_text[:array_end].rstrip()
        separator = "\n" if before.endswith(",") else ",\n"
        insertion = (
            f"{separator}\t\t\t{{:id => {enemy_id}, :cost => {cost}, :weight => {weight_expression}}}"
            f", // {enemy_name}"
        )
    else:
        insertion = (
            f"\t\t\t{{:id => {enemy_id}, :cost => {cost}, :weight => {weight_expression}}}, // {enemy_name}\n"
        )

    updated = module_text[:insertion_idx] + insertion + module_text[insertion_idx:]
    return updated, True


def _normalize_slot(slot: str, fallback: str) -> str:
    cleaned = re.sub(r"[^A-Z_]", "", slot.upper().strip())
    return cleaned or fallback


@mcp.tool(description="List all MCP tools with category and guidance on when to use each one.")
def list_mcp_tool_catalog(category: str | None = None) -> dict[str, Any]:
    """Return a curated catalog of available MCP tools to simplify tool selection."""
    if not category:
        return {"ok": True, "count": len(TOOL_CATALOG), "tools": TOOL_CATALOG}

    wanted = category.strip().lower()
    filtered = [entry for entry in TOOL_CATALOG if str(entry.get("category", "")).lower() == wanted]
    return {
        "ok": True,
        "category": wanted,
        "count": len(filtered),
        "tools": filtered,
    }


@mcp.tool(description="Recommend the best MCP tool(s) for a natural-language task and return quick argument templates.")
def recommend_mcp_tools(task: str, top_k: int = 3) -> dict[str, Any]:
    """Recommend matching tools for a free-text task to help AI choose the right MCP call."""
    text = task.strip().lower()
    if not text:
        return {"ok": False, "message": "task must not be empty."}

    tokens = set(re.findall(r"[a-z0-9_]+", text))
    scored: list[tuple[str, int]] = []
    for tool_name, keywords in TOOL_KEYWORDS.items():
        score = sum(1 for word in keywords if word in tokens)
        if score > 0:
            scored.append((tool_name, score))

    scored.sort(key=lambda entry: entry[1], reverse=True)
    chosen = [name for name, _ in scored[: max(1, top_k)]]

    templates = {
        "scaffold_item": {"class_name": "MyWeapon", "item_kind": "weapon", "dry_run": True},
        "scaffold_enemy": {"class_name": "MyEnemy", "enemy_id": 999, "dry_run": True},
        "generate_image_and_embed": {"bitmap_id": "monster_my_enemy", "prompt": "enemy sprite", "final_size": "16x16"},
        "build_for_device": {"product": "venu2s", "release": False},
        "run_in_simulator": {"product": "venu2s"},
    }

    recommendations: list[dict[str, Any]] = []
    for tool_name in chosen:
        meta = next((entry for entry in TOOL_CATALOG if entry["tool"] == tool_name), None)
        recommendations.append(
            {
                "tool": tool_name,
                "category": meta["category"] if meta else "other",
                "use_when": meta["use_when"] if meta else "",
                "arg_template": templates.get(tool_name),
            }
        )

    if not recommendations:
        recommendations = [
            {
                "tool": "list_mcp_tool_catalog",
                "category": "meta",
                "use_when": "No clear keyword match found; inspect available tools first.",
                "arg_template": {"category": None},
            }
        ]

    return {
        "ok": True,
        "task": task,
        "recommendations": recommendations,
    }


@mcp.tool(description="Create a new item class and register it in item factories and specific values.")
def scaffold_item(
    class_name: str,
    item_id: int | None = None,
    item_kind: str = "weapon",
    drawable_id: str | None = None,
    name: str | None = None,
    description: str | None = None,
    value: int = 10,
    weight: float = 1.0,
    attack: int = 10,
    defense: int = 5,
    slot: str | None = None,
    heal_amount: int = 20,
    effect_description: str | None = None,
    output_subfolder: str | None = None,
    register_in_items_module: bool = True,
    register_in_item_specific_values: bool = True,
    specific_weight_expression: str | None = None,
    overwrite: bool = False,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Create a new item class file and optionally register it in Items.mc and ItemSpecificValues with the next valid ID for its category."""
    class_name = _to_pascal_case(class_name)
    if not class_name:
        return {"ok": False, "message": "class_name is required."}

    kind = item_kind.strip().lower()
    if kind not in {"weapon", "armor", "consumable"}:
        return {"ok": False, "message": "item_kind must be one of: weapon, armor, consumable."}

    final_name = name or _pascal_to_display_name(class_name)
    final_description = description or f"A custom {kind} item"
    sprite = drawable_id or _snake_case(class_name)

    items_module_path = _abs_from_workspace("source/Engine/Items/Items.mc")
    if not items_module_path.exists():
        return {"ok": False, "message": f"Items module not found: {items_module_path}"}
    items_module_for_id = _read_text(items_module_path)
    expected_item_id = _next_item_id_for_kind(items_module_for_id, kind)
    if item_id is None:
        item_id = expected_item_id
    elif item_id != expected_item_id:
        return {
            "ok": False,
            "message": f"item_id must be the next valid {kind} id. Expected {expected_item_id}, got {item_id}.",
        }

    if output_subfolder:
        relative_dir = Path(output_subfolder)
    else:
        if kind == "weapon":
            relative_dir = Path("source/Engine/Items/Custom/WeaponItems")
        elif kind == "armor":
            relative_dir = Path("source/Engine/Items/Custom/ArmorItems")
        else:
            relative_dir = Path("source/Engine/Items/Custom/ConsumableItems")

    target_file = _abs_from_workspace(str(relative_dir / f"{class_name}.mc"))
    if target_file.exists() and not overwrite:
        return {
            "ok": False,
            "message": f"Target item file already exists: {target_file}. Use overwrite=true to replace it.",
        }

    normalized_slot = _normalize_slot(slot or ("RIGHT_HAND" if kind == "weapon" else "CHEST"), "RIGHT_HAND")
    var_name = class_name[0].lower() + class_name[1:]

    if kind == "weapon":
        item_text = f'''import Toybox.Lang;


class {class_name} extends WeaponItem {{

	function initialize() {{
		WeaponItem.initialize();
		id = {item_id};
		name = "{final_name}";
		description = "{final_description}";
		slot = {normalized_slot};
		value = {value};
		weight = {weight};
		attack = {attack};
		range = 1;
	}}

	function getSprite() as ResourceId {{
		return $.Rez.Drawables.{sprite};
	}}

	function deepcopy() as Item {{
		var {var_name} = new {class_name}();
		{var_name}.name = name;
		{var_name}.description = description;
		{var_name}.value = value;
		{var_name}.amount = amount;
		{var_name}.attribute_bonus = attribute_bonus;
		{var_name}.pos = pos;
		{var_name}.equipped = equipped;
		{var_name}.in_inventory = in_inventory;
		{var_name}.attack = attack;
		{var_name}.range = range;
		return {var_name};
	}}

}}
'''
    elif kind == "armor":
        armor_slot = _normalize_slot(slot or "CHEST", "CHEST")
        item_text = f'''import Toybox.Lang;


class {class_name} extends ArmorItem {{

	function initialize() {{
		ArmorItem.initialize();
		id = {item_id};
		name = "{final_name}";
		description = "{final_description}";
		value = {value};
		weight = {weight};
		slot = {armor_slot};
		defense = {defense};
	}}

	function getSprite() as ResourceId {{
		return $.Rez.Drawables.{sprite};
	}}

	function deepcopy() as Item {{
		var {var_name} = new {class_name}();
		{var_name}.name = name;
		{var_name}.description = description;
		{var_name}.value = value;
		{var_name}.amount = amount;
		{var_name}.attribute_bonus = attribute_bonus;
		{var_name}.pos = pos;
		{var_name}.equipped = equipped;
		{var_name}.in_inventory = in_inventory;
		{var_name}.defense = defense;
		return {var_name};
	}}

}}
'''
    else:
        effect_text = effect_description or f"Restores {heal_amount} health"
        item_text = f'''import Toybox.Lang;


class {class_name} extends ConsumableItem {{

	function initialize() {{
		ConsumableItem.initialize();
		self.id = {item_id};
		self.name = "{final_name}";
		self.description = "{final_description}";
		self.effect_description = "{effect_text}";
		self.value = {value};
		self.weight = {weight};
	}}

	function onUseItem(player as Player) as Void {{
		ConsumableItem.onUseItem(player);
		player.onGainHealth({heal_amount});
	}}

	function getSprite() as ResourceId {{
		return $.Rez.Drawables.{sprite};
	}}

	function deepcopy() as Item {{
		var {var_name} = new {class_name}();
		{var_name}.name = name;
		{var_name}.description = description;
		{var_name}.value = value;
		{var_name}.amount = amount;
		{var_name}.pos = pos;
		{var_name}.equipped = equipped;
		{var_name}.in_inventory = in_inventory;
		return {var_name};
	}}

}}
'''

    modified_files: list[str] = []
    if not dry_run:
        _write_text(target_file, item_text)
    modified_files.append(str(target_file))

    item_specific_values_path = _abs_from_workspace("source/Engine/Util/ItemSpecificValues.mc")
    item_id_added = False
    item_case_added = False
    item_specific_added = False

    if register_in_items_module:
        if not items_module_path.exists():
            return {"ok": False, "message": f"Items module not found: {items_module_path}"}

        items_module = _read_text(items_module_path)
        if f"case {item_id}:" in items_module:
            return {
                "ok": False,
                "message": f"Item id {item_id} already exists in Items.mc.",
                "created_file": str(target_file),
            }

        if f"new {class_name}()" in items_module:
            return {
                "ok": False,
                "message": f"Factory already references class {class_name} in Items.mc.",
                "created_file": str(target_file),
            }

        updated, item_id_added = _update_numeric_id_array(items_module, "item_ids", item_id, inline=False)
        updated, item_case_added = _insert_item_factory_case(updated, item_id, class_name, kind)
        if not dry_run:
            _write_text(items_module_path, updated)
        modified_files.append(str(items_module_path))

    if register_in_item_specific_values:
        if not item_specific_values_path.exists():
            return {"ok": False, "message": f"ItemSpecificValues file not found: {item_specific_values_path}"}

        if specific_weight_expression:
            weight_expression = specific_weight_expression
        elif kind == "weapon":
            weight_expression = "tieredWeight(depth, [ { :max => 8, :weight => 6 }, { :max => 18, :weight => 7 }, { :max => 999, :weight => 5 } ])"
        elif kind == "armor":
            weight_expression = "tieredWeight(depth, [ { :max => 8, :weight => 5 }, { :max => 18, :weight => 6 }, { :max => 999, :weight => 4 } ])"
        else:
            weight_expression = "tieredWeight(depth, [ { :max => 8, :weight => 5 }, { :max => 18, :weight => 6 }, { :max => 999, :weight => 5 } ])"

        item_specific_text = _read_text(item_specific_values_path)
        updated_specific, item_specific_added = _insert_item_specific_weight_entry(
            item_specific_text,
            item_id=item_id,
            item_kind=kind,
            weight_expression=weight_expression,
        )
        if not dry_run:
            _write_text(item_specific_values_path, updated_specific)
        modified_files.append(str(item_specific_values_path))

    return {
        "ok": True,
        "kind": kind,
        "class_name": class_name,
        "item_id": item_id,
        "file": str(target_file),
        "register_in_items_module": register_in_items_module,
        "register_in_item_specific_values": register_in_item_specific_values,
        "item_id_added": item_id_added,
        "item_case_added": item_case_added,
        "item_specific_added": item_specific_added,
        "modified_files": modified_files,
        "dry_run": dry_run,
    }


@mcp.tool(description="Create a new enemy class and register it in enemy factories and specific values.")
def scaffold_enemy(
    class_name: str,
    enemy_id: int,
    drawable_id: str | None = None,
    name: str | None = None,
    current_health: int = 40,
    max_health: int = 40,
    damage: int = 5,
    armor: int = 1,
    kill_experience: int = 10,
    energy_per_turn: int = 100,
    movement_method: str = "follow_player_direct",
    enemy_folder: str = "Custom",
    register_in_enemies_module: bool = True,
    include_in_weighted_table: bool = False,
    weighted_cost: int = 10,
    weighted_weight: int = 4,
    register_in_enemy_specific_values: bool = True,
    specific_weight_expression: str | None = None,
    overwrite: bool = False,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Create a new enemy class file and optionally register it in Enemies.mc, weighted spawns, and EnemySpecificValues."""
    class_name = _to_pascal_case(class_name)
    if not class_name:
        return {"ok": False, "message": "class_name is required."}

    final_name = name or _pascal_to_display_name(class_name)
    sprite = drawable_id or f"monster_{_snake_case(class_name)}"

    movement_map = {
        "follow_player_direct": "Enemy.followPlayerDirect(map)",
        "follow_player_simple": "Enemy.followPlayerSimple(map)",
        "follow_player_flank": "Enemy.followPlayerFlankSafe(map)",
        "follow_player_unpredictable": "Enemy.followPlayerUnpredictableSafe(map)",
        "random_movement": "Enemy.randomMovement(map)",
    }
    movement_key = movement_method.strip().lower()
    if movement_key not in movement_map:
        return {
            "ok": False,
            "message": "movement_method must be one of: follow_player_direct, follow_player_simple, follow_player_flank, follow_player_unpredictable, random_movement.",
        }

    relative_file = Path("source/Engine/Entities/Enemies") / enemy_folder / f"{class_name}.mc"
    target_file = _abs_from_workspace(str(relative_file))
    if target_file.exists() and not overwrite:
        return {
            "ok": False,
            "message": f"Target enemy file already exists: {target_file}. Use overwrite=true to replace it.",
        }

    enemy_text = f'''import Toybox.Lang;

class {class_name} extends Enemy {{
    
    function initialize() {{
        Enemy.initialize();
        id = {enemy_id};
        name = "{final_name}";
        current_health = {current_health};
        maxHealth = {max_health};
        damage = {damage};
        armor = {armor};
        kill_experience = {kill_experience};
        energy_per_turn = {energy_per_turn};
    }}

    function getSprite() as ResourceId {{
        return $.Rez.Drawables.{sprite};
    }}

    function findNextMove(map) as Point2D {{
        return {movement_map[movement_key]};
    }}
}}
'''

    modified_files: list[str] = []
    if not dry_run:
        _write_text(target_file, enemy_text)
    modified_files.append(str(target_file))

    enemy_ids_added = False
    enemy_case_added = False
    weight_entry_added = False
    enemy_specific_added = False
    enemies_module_path = _abs_from_workspace("source/Engine/Entities/Enemies/Enemies.mc")
    enemy_specific_values_path = _abs_from_workspace("source/Engine/Util/EnemySpecificValues.mc")

    if register_in_enemies_module:
        if not enemies_module_path.exists():
            return {"ok": False, "message": f"Enemies module not found: {enemies_module_path}"}

        module_text = _read_text(enemies_module_path)
        if f"case {enemy_id}:" in module_text:
            return {
                "ok": False,
                "message": f"Enemy id {enemy_id} already exists in Enemies.mc.",
                "created_file": str(target_file),
            }

        if f"new {class_name}()" in module_text:
            return {
                "ok": False,
                "message": f"Factory already references class {class_name} in Enemies.mc.",
                "created_file": str(target_file),
            }

        updated, enemy_ids_added = _update_numeric_id_array(module_text, "enemy_ids", enemy_id, inline=False)
        case_snippet = f"            case {enemy_id}: return new {class_name}();\n"
        updated, enemy_case_added = _insert_case_before_default(updated, "switch (id) {", case_snippet)

        if include_in_weighted_table:
            updated, weight_entry_added = _insert_enemy_weight_entry(updated, enemy_id, weighted_cost, weighted_weight)

        if not dry_run:
            _write_text(enemies_module_path, updated)
        modified_files.append(str(enemies_module_path))

    if register_in_enemy_specific_values:
        if not enemy_specific_values_path.exists():
            return {"ok": False, "message": f"EnemySpecificValues file not found: {enemy_specific_values_path}"}

        if specific_weight_expression:
            weight_expression = specific_weight_expression
        else:
            low = max(1, weighted_weight - 1)
            high = max(low, weighted_weight)
            weight_expression = (
                f"tieredWeight(depth, [ {{:max => 6, :weight => 0}}, {{:max => 12, :weight => {low}}}, "
                f"{{:max => 20, :weight => {high}}}, {{:max => 999, :weight => {high}}} ])"
            )

        specific_text = _read_text(enemy_specific_values_path)
        updated_specific, enemy_specific_added = _insert_enemy_specific_weight_entry(
            specific_text,
            enemy_id=enemy_id,
            cost=weighted_cost,
            weight_expression=weight_expression,
            enemy_name=final_name,
        )
        if not dry_run:
            _write_text(enemy_specific_values_path, updated_specific)
        modified_files.append(str(enemy_specific_values_path))

    return {
        "ok": True,
        "class_name": class_name,
        "enemy_id": enemy_id,
        "file": str(target_file),
        "register_in_enemies_module": register_in_enemies_module,
        "enemy_ids_added": enemy_ids_added,
        "enemy_case_added": enemy_case_added,
        "weight_entry_added": weight_entry_added,
        "register_in_enemy_specific_values": register_in_enemy_specific_values,
        "enemy_specific_added": enemy_specific_added,
        "modified_files": modified_files,
        "dry_run": dry_run,
    }


@mcp.tool(description="Create a new player class and register it in the player factory.")
def scaffold_player_class(
    class_name: str,
    player_id: int,
    default_name: str | None = None,
    description: str | None = None,
    sprite_drawable_id: str = "KnightBlue",
    current_health: int = 45,
    max_health: int = 45,
    levelup_health_bonus: int = 5,
    start_right_hand_item: str | None = "SteelSword",
    start_left_hand_item: str | None = None,
    start_chest_item: str | None = None,
    register_in_players_module: bool = True,
    overwrite: bool = False,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Create a new player class file and optionally register it in Players.mc."""
    class_name = _to_pascal_case(class_name)
    if not class_name:
        return {"ok": False, "message": "class_name is required."}

    final_default_name = default_name or class_name
    final_description = description or f"A {class_name} character"

    player_file = _abs_from_workspace(f"source/Engine/Entities/Player/Classes/{class_name}.mc")
    if player_file.exists() and not overwrite:
        return {
            "ok": False,
            "message": f"Target player class file already exists: {player_file}. Use overwrite=true to replace it.",
        }

    equip_lines: list[str] = []
    if start_right_hand_item:
        equip_lines.append(f"\t\tself.equipItem(new {start_right_hand_item}(), RIGHT_HAND, null);")
    if start_left_hand_item:
        equip_lines.append(f"\t\tself.equipItem(new {start_left_hand_item}(), LEFT_HAND, null);")
    if start_chest_item:
        equip_lines.append(f"\t\tself.equipItem(new {start_chest_item}(), CHEST, null);")
    if not equip_lines:
        equip_lines.append("\t\t// No starting equipment configured")

    player_text = f'''import Toybox.Lang;

class {class_name} extends Player {{

	function initialize(name as String) {{
		Player.initialize();
		self.id = {player_id};
		self.name = name;
		self.description = "{final_description}";

		self.current_health = {current_health};
		self.maxHealth = {max_health};

{os.linesep.join(equip_lines)}

		self.attributes = {{
			:strength => 6,
			:constitution => 6,
			:intelligence => 4,
			:wisdom => 4,
			:dexterity => 4,
			:charisma => 3,
			:luck => 3
		}};

		self.sprite = $.Rez.Drawables.{sprite_drawable_id};

	}}

	function onLevelUp() as Void {{
		Player.onLevelUp();
		maxHealth += {levelup_health_bonus};
	}}
}}
'''

    modified_files: list[str] = []
    if not dry_run:
        _write_text(player_file, player_text)
    modified_files.append(str(player_file))

    player_ids_added = False
    player_case_added = False
    players_module_path = _abs_from_workspace("source/Engine/Entities/Player/Players.mc")

    if register_in_players_module:
        if not players_module_path.exists():
            return {"ok": False, "message": f"Players module not found: {players_module_path}"}

        module_text = _read_text(players_module_path)
        if f"case {player_id}:" in module_text:
            return {
                "ok": False,
                "message": f"Player id {player_id} already exists in Players.mc.",
                "created_file": str(player_file),
            }

        if f"new {class_name}(name)" in module_text:
            return {
                "ok": False,
                "message": f"Factory already references class {class_name} in Players.mc.",
                "created_file": str(player_file),
            }

        updated, player_ids_added = _update_numeric_id_array(module_text, "player_ids", player_id, inline=True)
        player_case_snippet = (
            f"            case {player_id}:\n"
            f"                if (name == null) {{ name = \"{final_default_name}\"; }}\n"
            f"                return new {class_name}(name);\n"
        )
        updated, player_case_added = _insert_case_before_default(updated, "switch (id) {", player_case_snippet)

        if not dry_run:
            _write_text(players_module_path, updated)
        modified_files.append(str(players_module_path))

    return {
        "ok": True,
        "class_name": class_name,
        "player_id": player_id,
        "file": str(player_file),
        "register_in_players_module": register_in_players_module,
        "player_ids_added": player_ids_added,
        "player_case_added": player_case_added,
        "default_name": final_default_name,
        "modified_files": modified_files,
        "dry_run": dry_run,
    }


@mcp.tool(description="Build the app for a single Garmin product target.")
def build_for_device(
    product: str = "venu2s",
    release: bool = False,
    monkeybrains_jar_path: str | None = None,
    developer_key_path: str | None = None,
    monkey_jungle_path: str = "monkey.jungle",
    output_file: str | None = None,
) -> dict[str, Any]:
    """Build the Monkey C app for a single target product using monkeybrains and a developer key."""
    workspace = _workspace_root()
    jungle = _abs_from_workspace(monkey_jungle_path)
    if not jungle.exists():
        return {"ok": False, "message": f"monkey.jungle not found: {jungle}"}

    key_candidate = developer_key_path or os.environ.get("MONKEYC_DEVELOPER_KEY_PATH")
    if not key_candidate:
        return {
            "ok": False,
            "message": "Developer key missing. Set MONKEYC_DEVELOPER_KEY_PATH or pass developer_key_path.",
        }

    key_path = Path(key_candidate).resolve()
    if not key_path.exists():
        return {"ok": False, "message": f"Developer key not found: {key_path}"}

    try:
        jar_path = _resolve_monkeybrains_jar(monkeybrains_jar_path)
    except FileNotFoundError as err:
        return {"ok": False, "message": str(err)}

    variant = "release" if release else "debug"
    if output_file:
        output_path = _abs_from_workspace(output_file)
    else:
        output_path = workspace / "bin" / f"mcp-DungeonCrawler-{product}-{variant}.prg"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    cmd = [
        "java",
        "-Xms1g",
        "-Dfile.encoding=UTF-8",
        "-Dapple.awt.UIElement=true",
        "-jar",
        str(jar_path),
        "-o",
        str(output_path),
        "-f",
        str(jungle),
        "-y",
        str(key_path),
        "-d",
        product,
    ]
    if release:
        cmd.append("-r")

    result = subprocess.run(cmd, cwd=str(workspace), capture_output=True, text=True)
    return {
        "ok": result.returncode == 0,
        "return_code": result.returncode,
        "command": cmd,
        "output_file": str(output_path),
        "stdout_tail": result.stdout[-5000:],
        "stderr_tail": result.stderr[-5000:],
    }


@mcp.tool(description="Split an item spritesheet into tiled item PNG assets.")
def split_items_spritesheet(
    image_path: str,
    output_folder: str = "resources/drawables/items",
    tile_size: int = 16,
) -> dict[str, Any]:
    """Split an item spritesheet into 16x16 tiles and save recognized item sprites with canonical filenames."""
    source = _abs_from_workspace(image_path)
    if not source.exists():
        return {"ok": False, "message": f"Input image not found: {source}"}

    output = _abs_from_workspace(output_folder)
    output.mkdir(parents=True, exist_ok=True)

    image = Image.open(source)
    width, height = image.size
    saved: list[str] = []
    skipped = 0
    tile_counter = 1

    for y in range(0, height, tile_size):
        for x in range(0, width, tile_size):
            tile = image.crop((x, y, x + tile_size, y + tile_size))
            name = _item_name_from_index(tile_counter)
            if name:
                target = output / f"{name}.png"
                tile.save(target)
                saved.append(str(target))
            else:
                skipped += 1
            tile_counter += 1

    return {
        "ok": True,
        "source": str(source),
        "output_folder": str(output),
        "saved_count": len(saved),
        "skipped_count": skipped,
        "saved_preview": saved[:20],
    }


@mcp.tool(description="Register a drawable bitmap entry in drawables.xml.")
def register_drawable(
    bitmap_id: str,
    filename: str,
    drawables_xml_path: str = "resources/drawables/drawables.xml",
) -> dict[str, Any]:
    """Register a bitmap drawable ID and filename in drawables.xml if it does not already exist."""
    normalized_filename = filename.replace("\\", "/")
    return _register_drawable_internal(bitmap_id, normalized_filename, drawables_xml_path)


@mcp.tool(description="Generate an image via OpenRouter, resize it, and register it as drawable.")
def generate_image_and_embed(
    bitmap_id: str,
    prompt: str,
    model: str | None = None,
    final_size: str = "16x16",
    enforce_style_policy: bool = True,
    style_preset: str = "watch16",
    style_suffix: str | None = None,
    output_folder: str = "resources/drawables/generated",
    drawables_xml_path: str = "resources/drawables/drawables.xml",
) -> dict[str, Any]:
    """Generate an image via OpenRouter (with up to 3 retries), resize it to the requested final size, and register it in drawables.xml."""
    size_tuple = _decode_final_size(final_size)
    if not size_tuple:
        return {
            "ok": False,
            "message": f"Unsupported final_size '{final_size}'. Allowed sizes: {', '.join(sorted(ALLOWED_FINAL_IMAGE_SIZES.keys()))}",
        }

    image_bytes: bytes | None = None
    provider_name = "openrouter"
    final_prompt = _build_generation_prompt(
        base_prompt=prompt,
        enforce_style_policy=enforce_style_policy,
        style_preset=style_preset,
        style_suffix=style_suffix,
    )

    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        return {
            "ok": False,
            "message": "OPENROUTER_API_KEY is not set. Add it to your MCP server env.",
        }

    try:
        from openai import OpenAI
    except Exception:
        return {
            "ok": False,
            "message": "openai package missing. Install dependencies from tools/mcp_monkeyc/requirements.txt.",
        }

    client = OpenAI(
        api_key=api_key,
        base_url="https://openrouter.ai/api/v1",
    )
    extra_headers: dict[str, str] = {}
    site_url = os.environ.get("OPENROUTER_SITE_URL")
    app_name = os.environ.get("OPENROUTER_APP_NAME")
    if site_url:
        extra_headers["HTTP-Referer"] = site_url
    if app_name:
        extra_headers["X-Title"] = app_name

    max_attempts = 3
    last_error = ""
    attempts_used = 0
    for attempt in range(1, max_attempts + 1):
        attempts_used = attempt
        try:
            completion = client.chat.completions.create(
                model=model or "openrouter/hunter-alpha",
                messages=[
                    {
                        "role": "user",
                        "content": final_prompt,
                    }
                ],
                extra_headers=extra_headers or None,
            )
        except Exception as err:
            last_error = f"OpenRouter image generation failed: {err}"
            continue

        image_bytes, extraction_error = _extract_openrouter_image_bytes_from_completion(completion)
        if image_bytes:
            break
        last_error = extraction_error or "OpenRouter did not return image bytes."

    if not image_bytes:
        return {
            "ok": False,
            "message": f"OpenRouter did not return image data after {max_attempts} attempts. Last error: {last_error}",
        }

    raw_path = _abs_from_workspace(output_folder) / f"{bitmap_id}_raw.png"
    final_path = _abs_from_workspace(output_folder) / f"{bitmap_id}.png"
    raw_path.parent.mkdir(parents=True, exist_ok=True)

    raw_path.write_bytes(image_bytes)

    with Image.open(raw_path) as img:
        img = img.convert("RGBA")
        img = img.resize(size_tuple, Image.Resampling.LANCZOS)
        img.save(final_path)

    drawable_filename = _to_drawable_relative_png(final_path)
    register_result = _register_drawable_internal(
        bitmap_id=bitmap_id,
        filename=drawable_filename,
        drawables_xml_path=drawables_xml_path,
    )

    return {
        "ok": bool(register_result.get("ok")),
        "message": register_result.get("message", "Done"),
        "provider": provider_name,
        "bitmap_id": bitmap_id,
        "prompt": prompt,
        "effective_prompt": final_prompt,
        "style_policy_enforced": enforce_style_policy,
        "style_preset": style_preset,
        "attempts": attempts_used,
        "final_size": final_size,
        "raw_image": str(raw_path),
        "final_image": str(final_path),
        "drawables_xml": register_result.get("xml_path"),
        "already_exists": register_result.get("already_exists", False),
    }


@mcp.tool(description="Run the project balance script with configurable rounds.")
def run_balance_script(
    rounds: int = 50,
    script_path: str = "tools/balance/auto_apply_balance.py",
    workspace_arg: str = ".",
) -> dict[str, Any]:
    """Execute the project balance script with configurable rounds and return command output."""
    workspace = _workspace_root()
    script = _abs_from_workspace(script_path)
    if not script.exists():
        return {
            "ok": False,
            "message": f"Balance script not found: {script}",
        }

    cmd = [sys.executable, str(script), "--workspace", workspace_arg, "--rounds", str(rounds)]
    result = subprocess.run(cmd, cwd=str(workspace), capture_output=True, text=True)
    return {
        "ok": result.returncode == 0,
        "return_code": result.returncode,
        "command": cmd,
        "stdout_tail": result.stdout[-5000:],
        "stderr_tail": result.stderr[-5000:],
    }


@mcp.tool(description="List all product IDs currently declared in manifest.xml.")
def list_manifest_products(manifest_path: str = "manifest.xml") -> dict[str, Any]:
    """List all product IDs declared in manifest.xml."""
    manifest = _abs_from_workspace(manifest_path)
    if not manifest.exists():
        return {
            "ok": False,
            "message": f"manifest.xml not found: {manifest}",
        }

    content = manifest.read_text(encoding="utf-8")
    ids = sorted(set(re.findall(r"<iq:product\s+id=\"([^\"]+)\"", content)))
    return {
        "ok": True,
        "manifest": str(manifest),
        "count": len(ids),
        "products": ids,
    }


@mcp.tool(description="Build the app for multiple Garmin product targets.")
def build_for_products(
    products: list[str],
    release: bool = False,
    monkeybrains_jar_path: str | None = None,
    developer_key_path: str | None = None,
    monkey_jungle_path: str = "monkey.jungle",
    output_folder: str = "bin",
    continue_on_error: bool = True,
) -> dict[str, Any]:
    """Build the app for multiple target products and return per-product build results."""
    if not products:
        return {"ok": False, "message": "No products provided."}

    results: list[dict[str, Any]] = []
    for product in products:
        variant = "release" if release else "debug"
        out_file = str(_abs_from_workspace(output_folder) / f"mcp-DungeonCrawler-{product}-{variant}.prg")
        one = build_for_device(
            product=product,
            release=release,
            monkeybrains_jar_path=monkeybrains_jar_path,
            developer_key_path=developer_key_path,
            monkey_jungle_path=monkey_jungle_path,
            output_file=out_file,
        )
        one["product"] = product
        results.append(one)

        if not one.get("ok") and not continue_on_error:
            break

    failed = [r for r in results if not r.get("ok")]
    succeeded = [r for r in results if r.get("ok")]
    return {
        "ok": len(failed) == 0,
        "requested": len(products),
        "succeeded": len(succeeded),
        "failed": len(failed),
        "results": results,
    }


@mcp.tool(description="Validate drawables.xml against drawable files and report issues.")
def validate_drawables_resources(
    drawables_xml_path: str = "resources/drawables/drawables.xml",
    drawables_root: str = "resources/drawables",
    include_unreferenced_pngs: bool = True,
) -> dict[str, Any]:
    """Validate drawables.xml for duplicate IDs, missing files, and optionally unreferenced PNGs."""
    parsed = _parse_drawables_xml(drawables_xml_path)
    if not parsed.get("ok"):
        return parsed

    xml_path = Path(parsed["xml_path"])
    entries = parsed["entries"]
    root = _abs_from_workspace(drawables_root)
    ids_seen: set[str] = set()
    duplicate_ids: list[str] = []
    missing_files: list[dict[str, str]] = []
    referenced_files: set[str] = set()

    for entry in entries:
        bitmap_id = (entry.get("id") or "").strip()
        filename = (entry.get("filename") or "").strip()

        if bitmap_id in ids_seen:
            duplicate_ids.append(bitmap_id)
        else:
            ids_seen.add(bitmap_id)

        if filename:
            rel = filename.replace("\\", "/")
            referenced_files.add(rel)
            file_path = root / rel
            if not file_path.exists():
                missing_files.append(
                    {
                        "id": bitmap_id,
                        "filename": rel,
                    }
                )

    unreferenced_pngs: list[str] = []
    if include_unreferenced_pngs and root.exists():
        for png in root.rglob("*.png"):
            rel = str(png.relative_to(root)).replace("\\", "/")
            if rel not in referenced_files:
                unreferenced_pngs.append(rel)

    return {
        "ok": len(duplicate_ids) == 0 and len(missing_files) == 0,
        "xml_path": str(xml_path),
        "drawables_root": str(root),
        "entry_count": len(entries),
        "duplicate_id_count": len(duplicate_ids),
        "duplicate_ids": sorted(set(duplicate_ids)),
        "missing_file_count": len(missing_files),
        "missing_files": missing_files,
        "unreferenced_png_count": len(unreferenced_pngs),
        "unreferenced_pngs_preview": sorted(unreferenced_pngs)[:200],
    }


@mcp.tool(description="Bulk-register drawable PNGs from a folder into drawables.xml.")
def register_drawables_from_folder(
    source_folder: str,
    drawables_root: str = "resources/drawables",
    drawables_xml_path: str = "resources/drawables/drawables.xml",
    id_prefix: str = "",
    recursive: bool = True,
    copy_if_outside_root: bool = True,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Bulk-register PNG files from a folder into drawables.xml, optionally copying files into the drawables root."""
    source = _abs_from_workspace(source_folder)
    if not source.exists() or not source.is_dir():
        return {
            "ok": False,
            "message": f"Source folder not found: {source}",
        }

    root = _abs_from_workspace(drawables_root)
    root.mkdir(parents=True, exist_ok=True)

    parser = _parse_drawables_xml(drawables_xml_path)
    if not parser.get("ok"):
        return parser

    existing_ids = {str(entry.get("id")) for entry in parser["entries"]}
    pattern = "**/*.png" if recursive else "*.png"
    files = sorted(source.glob(pattern))

    registered: list[dict[str, str]] = []
    skipped_existing: list[str] = []
    skipped_invalid: list[str] = []

    for file_path in files:
        base_id = _normalize_bitmap_id(file_path.stem)
        full_id = _normalize_bitmap_id(f"{id_prefix}{base_id}") if id_prefix else base_id
        if not full_id:
            skipped_invalid.append(str(file_path))
            continue

        if full_id in existing_ids:
            skipped_existing.append(full_id)
            continue

        final_file = file_path
        try:
            rel = file_path.resolve().relative_to(root.resolve())
            filename = str(rel).replace("\\", "/")
        except ValueError:
            if not copy_if_outside_root:
                skipped_invalid.append(str(file_path))
                continue
            target = root / "imported" / file_path.name
            target.parent.mkdir(parents=True, exist_ok=True)
            if not dry_run:
                shutil.copy2(file_path, target)
            final_file = target
            filename = str(final_file.relative_to(root)).replace("\\", "/")

        if not dry_run:
            result = _register_drawable_internal(full_id, filename, drawables_xml_path)
            if not result.get("ok"):
                return result

        existing_ids.add(full_id)
        registered.append(
            {
                "id": full_id,
                "filename": filename,
            }
        )

    return {
        "ok": True,
        "source_folder": str(source),
        "processed_files": len(files),
        "registered_count": len(registered),
        "registered": registered,
        "skipped_existing_count": len(skipped_existing),
        "skipped_existing": sorted(skipped_existing),
        "skipped_invalid_count": len(skipped_invalid),
        "skipped_invalid": skipped_invalid,
        "dry_run": dry_run,
    }


@mcp.tool(description="Optimize a drawable PNG using palette quantization.")
def optimize_drawable_png(
    input_path: str,
    output_path: str | None = None,
    max_colors: int = 16,
    dither: bool = False,
    keep_alpha: bool = True,
) -> dict[str, Any]:
    """Optimize a PNG drawable by palette quantization for watch-friendly size and color usage."""
    source = _abs_from_workspace(input_path)
    if not source.exists():
        return {
            "ok": False,
            "message": f"Input image not found: {source}",
        }

    target = _abs_from_workspace(output_path) if output_path else source
    target.parent.mkdir(parents=True, exist_ok=True)

    with Image.open(source) as img:
        rgba = img.convert("RGBA")
        palette_source = rgba.convert("RGB")
        quantized = palette_source.quantize(
            colors=max(2, min(max_colors, 256)),
            method=Image.Quantize.MEDIANCUT,
            dither=Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE,
        )
        if keep_alpha:
            optimized = quantized.convert("RGBA")
            optimized.putalpha(rgba.getchannel("A"))
        else:
            optimized = quantized.convert("RGB")

        optimized.save(target, optimize=True)

    return {
        "ok": True,
        "input": str(source),
        "output": str(target),
        "max_colors": max_colors,
        "dither": dither,
        "keep_alpha": keep_alpha,
    }


@mcp.tool(description="Run the release build PowerShell helper script.")
def run_release_build_script(
    tag: str,
    developer_key_path: str | None = None,
    devices: list[str] | None = None,
    create_tag: bool = False,
    skip_release: bool = True,
    draft_release: bool = False,
    prerelease: bool = False,
    script_path: str = "helpers/create-release.ps1",
) -> dict[str, Any]:
    """Run the PowerShell release build helper script with tag, device, and release options."""
    workspace = _workspace_root()
    script = _abs_from_workspace(script_path)
    if not script.exists():
        return {"ok": False, "message": f"Release script not found: {script}"}

    key_candidate = developer_key_path or os.environ.get("MONKEYC_DEVELOPER_KEY_PATH")
    if not key_candidate:
        return {
            "ok": False,
            "message": "Developer key missing. Set MONKEYC_DEVELOPER_KEY_PATH or pass developer_key_path.",
        }
    key_path = Path(key_candidate).resolve()
    if not key_path.exists():
        return {"ok": False, "message": f"Developer key not found: {key_path}"}

    cmd = [
        "powershell",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        str(script),
        "-Tag",
        tag,
        "-DeveloperKeyPath",
        str(key_path),
    ]

    if devices:
        cmd.extend(["-Devices", ",".join(devices)])
    if create_tag:
        cmd.append("-CreateTag")
    if skip_release:
        cmd.append("-SkipRelease")
    if draft_release:
        cmd.append("-DraftRelease")
    if prerelease:
        cmd.append("-PreRelease")

    result = subprocess.run(cmd, cwd=str(workspace), capture_output=True, text=True)
    return {
        "ok": result.returncode == 0,
        "return_code": result.returncode,
        "command": cmd,
        "stdout_tail": result.stdout[-5000:],
        "stderr_tail": result.stderr[-5000:],
    }


@mcp.tool(description="Check local Java, SDK, and key prerequisites for Monkey C tooling.")
def check_monkeyc_environment(
    developer_key_path: str | None = None,
    monkeybrains_jar_path: str | None = None,
    monkeydo_path: str | None = None,
) -> dict[str, Any]:
    """Check local Monkey C build prerequisites such as Java, SDK tools, and developer key availability."""
    checks: dict[str, Any] = {}

    java_ok = shutil.which("java") is not None
    checks["java"] = {
        "ok": java_ok,
        "path": shutil.which("java"),
    }

    try:
        sdk_root = _sdk_root()
        checks["sdk_root"] = {"ok": True, "path": str(sdk_root)}
    except FileNotFoundError as err:
        checks["sdk_root"] = {"ok": False, "message": str(err)}

    try:
        monkeybrains = _resolve_monkeybrains_jar(monkeybrains_jar_path)
        checks["monkeybrains"] = {"ok": True, "path": str(monkeybrains)}
    except FileNotFoundError as err:
        checks["monkeybrains"] = {"ok": False, "message": str(err)}

    try:
        monkeydo = _resolve_sdk_tool("monkeydo", monkeydo_path)
        checks["monkeydo"] = {"ok": True, "path": str(monkeydo)}
    except FileNotFoundError as err:
        checks["monkeydo"] = {"ok": False, "message": str(err)}

    key_candidate = developer_key_path or os.environ.get("MONKEYC_DEVELOPER_KEY_PATH")
    key_ok = False
    key_msg: str | None = None
    key_path: str | None = None
    if key_candidate:
        key_file = Path(key_candidate).resolve()
        if key_file.exists():
            key_ok = True
            key_path = str(key_file)
        else:
            key_msg = f"Developer key not found: {key_file}"
    else:
        key_msg = "Developer key missing. Set MONKEYC_DEVELOPER_KEY_PATH or pass developer_key_path."

    checks["developer_key"] = {
        "ok": key_ok,
        "path": key_path,
        "message": key_msg,
    }

    all_ok = all(item.get("ok") for item in checks.values())
    return {
        "ok": all_ok,
        "checks": checks,
    }


@mcp.tool(description="List installed Connect IQ SDKs and tool availability.")
def list_connectiq_sdks() -> dict[str, Any]:
    """List detected Connect IQ SDK installations and whether key tools are present."""
    try:
        sdk_root = _sdk_root()
    except FileNotFoundError as err:
        return {"ok": False, "message": str(err)}

    sdks: list[dict[str, Any]] = []
    for child in sorted(sdk_root.iterdir()):
        if not child.is_dir():
            continue
        monkeybrains = list(child.rglob("monkeybrains.jar"))
        monkeydo = [*child.rglob("monkeydo.exe"), *child.rglob("monkeydo.bat"), *child.rglob("monkeydo.cmd")]
        sdks.append(
            {
                "name": child.name,
                "path": str(child),
                "has_monkeybrains": len(monkeybrains) > 0,
                "has_monkeydo": len(monkeydo) > 0,
            }
        )

    return {
        "ok": True,
        "sdk_root": str(sdk_root),
        "count": len(sdks),
        "sdks": sdks,
    }


@mcp.tool(description="Run a PRG build in the Connect IQ simulator.")
def run_in_simulator(
    prg_path: str | None = None,
    product: str | None = None,
    monkeydo_path: str | None = None,
    start_detached: bool = True,
) -> dict[str, Any]:
    """Launch a PRG in the Connect IQ simulator (monkeydo), optionally using the latest build automatically."""
    try:
        monkeydo = _resolve_sdk_tool("monkeydo", monkeydo_path)
    except FileNotFoundError as err:
        return {"ok": False, "message": str(err)}

    if prg_path:
        prg = _abs_from_workspace(prg_path)
    else:
        found = _find_latest_prg(product)
        if not found:
            return {
                "ok": False,
                "message": "No .prg build found in bin/. Build first or pass prg_path.",
            }
        prg = found

    if not prg.exists():
        return {"ok": False, "message": f"PRG not found: {prg}"}

    cmd = [str(monkeydo), str(prg)]
    if start_detached:
        process = subprocess.Popen(cmd, cwd=str(_workspace_root()))
        return {
            "ok": True,
            "detached": True,
            "pid": process.pid,
            "command": cmd,
            "prg": str(prg),
        }

    result = subprocess.run(cmd, cwd=str(_workspace_root()), capture_output=True, text=True)
    return {
        "ok": result.returncode == 0,
        "detached": False,
        "return_code": result.returncode,
        "command": cmd,
        "prg": str(prg),
        "stdout_tail": result.stdout[-5000:],
        "stderr_tail": result.stderr[-5000:],
    }


@mcp.tool(description="Add a product ID entry to manifest.xml.")
def add_manifest_product(
    product_id: str,
    manifest_path: str = "manifest.xml",
    dry_run: bool = False,
) -> dict[str, Any]:
    """Add a product ID to manifest.xml if it is not already present."""
    manifest = _abs_from_workspace(manifest_path)
    if not manifest.exists():
        return {"ok": False, "message": f"manifest.xml not found: {manifest}"}

    tree = ET.parse(manifest)
    root = tree.getroot()
    ns = {"iq": "http://www.garmin.com/xml/connectiq"}
    products = root.find("iq:products", ns)
    if products is None:
        return {"ok": False, "message": "No <iq:products> node found in manifest.xml."}

    existing = products.findall("iq:product", ns)
    existing_ids = {node.attrib.get("id", "") for node in existing}
    if product_id in existing_ids:
        return {"ok": True, "message": f"Product already present: {product_id}", "changed": False}

    ET.SubElement(products, "{http://www.garmin.com/xml/connectiq}product", attrib={"id": product_id})

    if not dry_run:
        tree.write(manifest, encoding="utf-8", xml_declaration=True)

    return {
        "ok": True,
        "changed": True,
        "dry_run": dry_run,
        "manifest": str(manifest),
        "added_product": product_id,
    }


@mcp.tool(description="Remove a product ID entry from manifest.xml.")
def remove_manifest_product(
    product_id: str,
    manifest_path: str = "manifest.xml",
    dry_run: bool = False,
) -> dict[str, Any]:
    """Remove a product ID from manifest.xml if present."""
    manifest = _abs_from_workspace(manifest_path)
    if not manifest.exists():
        return {"ok": False, "message": f"manifest.xml not found: {manifest}"}

    tree = ET.parse(manifest)
    root = tree.getroot()
    ns = {"iq": "http://www.garmin.com/xml/connectiq"}
    products = root.find("iq:products", ns)
    if products is None:
        return {"ok": False, "message": "No <iq:products> node found in manifest.xml."}

    target = None
    for node in products.findall("iq:product", ns):
        if node.attrib.get("id") == product_id:
            target = node
            break

    if target is None:
        return {"ok": True, "message": f"Product not present: {product_id}", "changed": False}

    products.remove(target)
    if not dry_run:
        tree.write(manifest, encoding="utf-8", xml_declaration=True)

    return {
        "ok": True,
        "changed": True,
        "dry_run": dry_run,
        "manifest": str(manifest),
        "removed_product": product_id,
    }


@mcp.tool(description="Analyze drawable usage in source and compare with drawables.xml.")
def analyze_drawable_usage(
    drawables_xml_path: str = "resources/drawables/drawables.xml",
    source_root: str = "source",
) -> dict[str, Any]:
    """Compare drawable IDs used in source code against drawables.xml to find unused or missing mappings."""
    parsed = _parse_drawables_xml(drawables_xml_path)
    if not parsed.get("ok"):
        return parsed

    xml_ids = {str(entry.get("id")) for entry in parsed.get("entries", []) if entry.get("id")}
    src_root = _abs_from_workspace(source_root)
    if not src_root.exists():
        return {"ok": False, "message": f"Source folder not found: {src_root}"}

    mc_files = list(src_root.rglob("*.mc"))
    used_ids: set[str] = set()
    id_pattern = re.compile(r"Rez\.Drawables\.([A-Za-z0-9_]+)")

    for mc_file in mc_files:
        text = mc_file.read_text(encoding="utf-8", errors="ignore")
        used_ids.update(id_pattern.findall(text))

    xml_not_used = sorted(xml_ids - used_ids)
    used_not_in_xml = sorted(used_ids - xml_ids)

    return {
        "ok": True,
        "source_root": str(src_root),
        "files_scanned": len(mc_files),
        "xml_ids_count": len(xml_ids),
        "used_ids_count": len(used_ids),
        "xml_not_used_count": len(xml_not_used),
        "xml_not_used_preview": xml_not_used[:200],
        "used_not_in_xml_count": len(used_not_in_xml),
        "used_not_in_xml": used_not_in_xml,
    }


if __name__ == "__main__":
    mcp.run()
