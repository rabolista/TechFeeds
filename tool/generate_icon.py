"""Generates the app icon (icon.png) and adaptive icon foreground (icon_foreground.png)
for Tech and Feeds. Run with: python3 tool/generate_icon.py
"""
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT_DIR = "assets/icon"

# Deep tech navy -> electric cyan, diagonal gradient.
TOP_LEFT = np.array([13, 27, 76])       # #0D1B4C
BOTTOM_RIGHT = np.array([0, 180, 216])  # #00B4D8


def diagonal_gradient(size):
    ys, xs = np.mgrid[0:size, 0:size]
    t = (xs.astype(np.float32) + ys.astype(np.float32)) / (2 * (size - 1))
    t = t[..., None]
    rgb = TOP_LEFT[None, None, :] * (1 - t) + BOTTOM_RIGHT[None, None, :] * t
    return rgb.astype(np.uint8)


def make_background():
    arr = diagonal_gradient(SIZE)
    img = Image.fromarray(arr, mode="RGB").convert("RGBA")
    return img


def draw_signal_glyph(canvas_size, scale=1.0, color=(255, 255, 255, 255)):
    """Draws a modern 'feed/signal' glyph: a dot with two concentric
    quarter-rings radiating up-and-right, like a classic feed/RSS icon."""
    glyph = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(glyph)

    cx = int(canvas_size * 0.30)
    cy = int(canvas_size * 0.70)
    dot_r = int(canvas_size * 0.085 * scale)

    draw.ellipse(
        [cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r],
        fill=color,
    )

    ring_specs = [
        (0.34, 0.075),
        (0.55, 0.075),
    ]
    for radius_frac, thickness_frac in ring_specs:
        r = int(canvas_size * radius_frac * scale)
        thickness = int(canvas_size * thickness_frac * scale)
        bbox = [cx - r, cy - r, cx + r, cy + r]
        draw.arc(bbox, start=270, end=360, fill=color, width=thickness)

    return glyph


def rounded_mask(size, radius_frac):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    radius = int(size * radius_frac)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


def make_full_icon():
    bg = make_background()

    # Soft glossy highlight, upper-left, for a modern glass-like feel.
    highlight = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    hd = ImageDraw.Draw(highlight)
    hd.ellipse(
        [-SIZE * 0.25, -SIZE * 0.35, SIZE * 0.75, SIZE * 0.55],
        fill=(255, 255, 255, 60),
    )
    highlight = highlight.filter(ImageFilter.GaussianBlur(SIZE * 0.08))
    bg = Image.alpha_composite(bg, highlight)

    glyph = draw_signal_glyph(SIZE, scale=1.0)
    bg = Image.alpha_composite(bg, glyph)

    return bg.convert("RGB")


def make_foreground():
    # Adaptive icons are masked (circle/squircle/rounded-square) and crop
    # ~33% from the edges, so keep the glyph within a safe center zone.
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glyph = draw_signal_glyph(SIZE, scale=0.72, color=(255, 255, 255, 255))
    canvas = Image.alpha_composite(canvas, glyph)
    return canvas


if __name__ == "__main__":
    import os

    os.makedirs(OUT_DIR, exist_ok=True)

    icon = make_full_icon()
    icon.save(f"{OUT_DIR}/icon.png")
    print(f"Wrote {OUT_DIR}/icon.png ({icon.size})")

    fg = make_foreground()
    fg.save(f"{OUT_DIR}/icon_foreground.png")
    print(f"Wrote {OUT_DIR}/icon_foreground.png ({fg.size})")
