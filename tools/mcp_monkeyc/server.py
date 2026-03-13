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


@mcp.tool()
def build_for_device(
    product: str = "venu2s",
    release: bool = False,
    monkeybrains_jar_path: str | None = None,
    developer_key_path: str | None = None,
    monkey_jungle_path: str = "monkey.jungle",
    output_file: str | None = None,
) -> dict[str, Any]:
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


@mcp.tool()
def split_items_spritesheet(
    image_path: str,
    output_folder: str = "resources/drawables/items",
    tile_size: int = 16,
) -> dict[str, Any]:
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


@mcp.tool()
def register_drawable(
    bitmap_id: str,
    filename: str,
    drawables_xml_path: str = "resources/drawables/drawables.xml",
) -> dict[str, Any]:
    normalized_filename = filename.replace("\\", "/")
    return _register_drawable_internal(bitmap_id, normalized_filename, drawables_xml_path)


@mcp.tool()
def generate_image_and_embed(
    bitmap_id: str,
    prompt: str,
    provider: str = "openrouter",
    model: str | None = None,
    final_size: str = "16x16",
    provider_size: str = "1024x1024",
    enforce_style_policy: bool = True,
    style_preset: str = "watch16",
    style_suffix: str | None = None,
    output_folder: str = "resources/drawables/generated",
    drawables_xml_path: str = "resources/drawables/drawables.xml",
) -> dict[str, Any]:
    size_tuple = _decode_final_size(final_size)
    if not size_tuple:
        return {
            "ok": False,
            "message": f"Unsupported final_size '{final_size}'. Allowed sizes: {', '.join(sorted(ALLOWED_FINAL_IMAGE_SIZES.keys()))}",
        }

    image_bytes: bytes | None = None
    provider_name = provider.strip().lower()
    final_prompt = _build_generation_prompt(
        base_prompt=prompt,
        enforce_style_policy=enforce_style_policy,
        style_preset=style_preset,
        style_suffix=style_suffix,
    )

    if provider_name == "openrouter":
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
            return {
                "ok": False,
                "message": f"OpenRouter image generation failed: {err}",
            }

        image_bytes, extraction_error = _extract_openrouter_image_bytes_from_completion(completion)
        if not image_bytes:
            return {
                "ok": False,
                "message": extraction_error
                or "OpenRouter did not return image bytes. Try a model that supports image output.",
            }

    elif provider_name == "openai":
        api_key = os.environ.get("OPENAI_API_KEY")
        if not api_key:
            return {
                "ok": False,
                "message": "OPENAI_API_KEY is not set. Add it to your MCP server env.",
            }

        try:
            from openai import OpenAI
        except Exception:
            return {
                "ok": False,
                "message": "openai package missing. Install dependencies from tools/mcp_monkeyc/requirements.txt.",
            }

        client = OpenAI(api_key=api_key)
        try:
            result = client.images.generate(model=model or "gpt-image-1", prompt=final_prompt, size=provider_size)
        except Exception as err:
            return {
                "ok": False,
                "message": f"OpenAI image generation failed: {err}",
            }

        if not result.data:
            return {"ok": False, "message": "Image API returned no data."}

        b64 = result.data[0].b64_json
        if not b64:
            return {"ok": False, "message": "Image API response is missing b64_json."}

        image_bytes = base64.b64decode(b64)

    elif provider_name == "imagerouter":
        api_key = os.environ.get("IMAGEROUTER_API_KEY")
        if not api_key:
            return {
                "ok": False,
                "message": "IMAGEROUTER_API_KEY is not set. Add it to your MCP server env.",
            }

        if not model:
            return {
                "ok": False,
                "message": "ImageRouter requires an explicit model (e.g. 'test/test' as shown in docs).",
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
            base_url="https://api.imagerouter.io/v1/openai",
        )
        try:
            result = client.images.generate(
                model=model,
                prompt=final_prompt,
            )
        except Exception as err:
            return {
                "ok": False,
                "message": f"ImageRouter image generation failed: {err}",
            }

        if not result.data:
            return {"ok": False, "message": "ImageRouter API returned no data."}

        b64 = result.data[0].b64_json
        if b64:
            image_bytes = base64.b64decode(b64)
        else:
            image_url = getattr(result.data[0], "url", None)
            if image_url:
                try:
                    with urllib.request.urlopen(image_url, timeout=60) as response:
                        image_bytes = response.read()
                except Exception as err:
                    return {
                        "ok": False,
                        "message": f"ImageRouter returned URL but download failed: {err}",
                    }
            else:
                return {
                    "ok": False,
                    "message": "ImageRouter API response is missing both b64_json and url.",
                }

    elif provider_name == "gemini":
        api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
        if not api_key:
            return {
                "ok": False,
                "message": "GEMINI_API_KEY (or GOOGLE_API_KEY) is not set.",
            }

        try:
            from google import genai
        except Exception:
            return {
                "ok": False,
                "message": "google-genai package missing. Install dependencies from tools/mcp_monkeyc/requirements.txt.",
            }

        client = genai.Client(api_key=api_key)
        try:
            response = client.models.generate_content(
                model=model or "gemini-2.5-flash-image",
                contents=final_prompt,
            )
        except Exception as err:
            return {
                "ok": False,
                "message": f"Gemini image generation failed: {err}",
            }
        image_bytes = _extract_gemini_image_bytes(response)
        if not image_bytes:
            return {
                "ok": False,
                "message": "Gemini response did not include image bytes. Try a different Gemini image model or prompt.",
            }
    else:
        return {
            "ok": False,
            "message": "Unsupported provider. Use 'openrouter', 'openai', 'gemini', or 'imagerouter'.",
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
        "final_size": final_size,
        "raw_image": str(raw_path),
        "final_image": str(final_path),
        "drawables_xml": register_result.get("xml_path"),
        "already_exists": register_result.get("already_exists", False),
    }


@mcp.tool()
def run_balance_script(
    rounds: int = 50,
    script_path: str = "tools/balance/auto_apply_balance.py",
    workspace_arg: str = ".",
) -> dict[str, Any]:
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


@mcp.tool()
def list_manifest_products(manifest_path: str = "manifest.xml") -> dict[str, Any]:
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


@mcp.tool()
def build_for_products(
    products: list[str],
    release: bool = False,
    monkeybrains_jar_path: str | None = None,
    developer_key_path: str | None = None,
    monkey_jungle_path: str = "monkey.jungle",
    output_folder: str = "bin",
    continue_on_error: bool = True,
) -> dict[str, Any]:
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


@mcp.tool()
def validate_drawables_resources(
    drawables_xml_path: str = "resources/drawables/drawables.xml",
    drawables_root: str = "resources/drawables",
    include_unreferenced_pngs: bool = True,
) -> dict[str, Any]:
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


@mcp.tool()
def register_drawables_from_folder(
    source_folder: str,
    drawables_root: str = "resources/drawables",
    drawables_xml_path: str = "resources/drawables/drawables.xml",
    id_prefix: str = "",
    recursive: bool = True,
    copy_if_outside_root: bool = True,
    dry_run: bool = False,
) -> dict[str, Any]:
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


@mcp.tool()
def optimize_drawable_png(
    input_path: str,
    output_path: str | None = None,
    max_colors: int = 16,
    dither: bool = False,
    keep_alpha: bool = True,
) -> dict[str, Any]:
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


@mcp.tool()
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


@mcp.tool()
def check_monkeyc_environment(
    developer_key_path: str | None = None,
    monkeybrains_jar_path: str | None = None,
    monkeydo_path: str | None = None,
) -> dict[str, Any]:
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


@mcp.tool()
def list_connectiq_sdks() -> dict[str, Any]:
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


@mcp.tool()
def run_in_simulator(
    prg_path: str | None = None,
    product: str | None = None,
    monkeydo_path: str | None = None,
    start_detached: bool = True,
) -> dict[str, Any]:
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


@mcp.tool()
def add_manifest_product(
    product_id: str,
    manifest_path: str = "manifest.xml",
    dry_run: bool = False,
) -> dict[str, Any]:
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


@mcp.tool()
def remove_manifest_product(
    product_id: str,
    manifest_path: str = "manifest.xml",
    dry_run: bool = False,
) -> dict[str, Any]:
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


@mcp.tool()
def analyze_drawable_usage(
    drawables_xml_path: str = "resources/drawables/drawables.xml",
    source_root: str = "source",
) -> dict[str, Any]:
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
