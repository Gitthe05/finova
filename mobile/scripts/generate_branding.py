#!/usr/bin/env python3

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "branding"

SIZE = 1024
BLUE = (37, 99, 235)
TEAL = (20, 184, 166)


def _diagonal_gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    denom = 2 * (size - 1)
    for y in range(size):
        for x in range(size):
            t = (x + y) / denom
            px[x, y] = (
                int(BLUE[0] + (TEAL[0] - BLUE[0]) * t),
                int(BLUE[1] + (TEAL[1] - BLUE[1]) * t),
                int(BLUE[2] + (TEAL[2] - BLUE[2]) * t),
            )
    return img


def _subtle_shine(base: Image.Image) -> Image.Image:
    w, h = base.size
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = overlay.load()
    for y in range(h):
        t = max(0.0, 1.0 - y / (h * 0.55))
        alpha = int(36 * t * t)
        if alpha <= 0:
            continue
        for x in range(w):
            px[x, y] = (255, 255, 255, alpha)
    return Image.alpha_composite(base.convert("RGBA"), overlay).convert("RGB")


def _draw_f(
    canvas: Image.Image,
    *,
    color: tuple[int, int, int] = (255, 255, 255),
    scale: float = 0.52,
) -> None:
    draw = ImageDraw.Draw(canvas)
    w = canvas.width
    s = w * scale
    cx, cy = w / 2, w / 2
    stroke = max(8, int(w * 0.105))
    radius = stroke // 2

    left = cx - s * 0.2
    top = cy - s * 0.44
    bottom = cy + s * 0.44
    mid = cy - s * 0.04
    bar_right = cx + s * 0.26
    mid_right = cx + s * 0.14

    draw.rounded_rectangle(
        [left, top, left + stroke, bottom],
        radius=radius,
        fill=color,
    )
    draw.rounded_rectangle(
        [left, top, bar_right, top + stroke],
        radius=radius,
        fill=color,
    )
    draw.rounded_rectangle(
        [left, mid, mid_right, mid + stroke],
        radius=radius,
        fill=color,
    )


def _rounded_mask(size: int, radius_ratio: float = 0.22) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    r = int(size * radius_ratio)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=255)
    return mask


def app_icon() -> Image.Image:
    img = _subtle_shine(_diagonal_gradient(SIZE))
    _draw_f(img, scale=0.54)
    return img


def app_icon_foreground() -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _draw_f(img, scale=0.42)
    return img


def splash_logo() -> Image.Image:
    canvas = 512
    pad = 48
    inner = canvas - pad * 2
    grad = _diagonal_gradient(inner)
    grad = _subtle_shine(grad)
    _draw_f(grad, scale=0.58)

    mask = _rounded_mask(inner, radius_ratio=0.24)
    mark = Image.new("RGBA", (inner, inner), (0, 0, 0, 0))
    mark.paste(grad, (0, 0), mask)

    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    out.paste(mark, (pad, pad), mark)
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    app_icon().save(OUT / "app_icon.png", optimize=True)
    app_icon_foreground().save(OUT / "app_icon_foreground.png", optimize=True)
    splash_logo().save(OUT / "splash_logo.png", optimize=True)
    print(f"OK → {OUT}")


if __name__ == "__main__":
    main()
