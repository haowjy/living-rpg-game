#!/usr/bin/env python3
"""Generate the three tiny paper-doll sprite sheets used by the demo scene."""

from pathlib import Path
import struct
import zlib


CELL_SIZE = 64
FRAMES = 4
DIRECTIONS = ("down", "left", "right", "up")
SHEET_SIZE = CELL_SIZE * FRAMES
OUTPUT_DIR = Path(__file__).parents[1] / "assets/characters/paper_doll"
TRANSPARENT = (0, 0, 0, 0)

SKIN = (211, 145, 104, 255)
SKIN_SHADOW = (164, 93, 73, 255)
OUTLINE = (54, 43, 48, 255)
OUTFIT = (49, 116, 140, 255)
OUTFIT_LIGHT = (83, 166, 169, 255)
BELT = (225, 180, 79, 255)
HAIR = (77, 47, 43, 255)
HAIR_LIGHT = (128, 77, 58, 255)


class Sheet:
    def __init__(self) -> None:
        self.pixels = [[TRANSPARENT for _ in range(SHEET_SIZE)] for _ in range(SHEET_SIZE)]

    def pixel(self, x: int, y: int, color: tuple[int, int, int, int]) -> None:
        if 0 <= x < SHEET_SIZE and 0 <= y < SHEET_SIZE:
            self.pixels[y][x] = color

    def rect(self, x: int, y: int, width: int, height: int,
             color: tuple[int, int, int, int]) -> None:
        for py in range(y, y + height):
            for px in range(x, x + width):
                self.pixel(px, py, color)

    def ellipse(self, center_x: int, center_y: int, radius_x: int, radius_y: int,
                color: tuple[int, int, int, int]) -> None:
        for py in range(center_y - radius_y, center_y + radius_y + 1):
            for px in range(center_x - radius_x, center_x + radius_x + 1):
                dx = (px - center_x) / radius_x
                dy = (py - center_y) / radius_y
                if dx * dx + dy * dy <= 1.0:
                    self.pixel(px, py, color)

    def write_png(self, path: Path) -> None:
        raw = b"".join(
            b"\x00" + b"".join(bytes(pixel) for pixel in row)
            for row in self.pixels
        )

        def chunk(kind: bytes, data: bytes) -> bytes:
            return (
                struct.pack(">I", len(data))
                + kind
                + data
                + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
            )

        png = b"\x89PNG\r\n\x1a\n"
        png += chunk(b"IHDR", struct.pack(">IIBBBBB", SHEET_SIZE, SHEET_SIZE, 8, 6, 0, 0, 0))
        png += chunk(b"IDAT", zlib.compress(raw, 9))
        png += chunk(b"IEND", b"")
        path.write_bytes(png)


def cell_origin(direction: int, frame: int) -> tuple[int, int]:
    return frame * CELL_SIZE, direction * CELL_SIZE


def draw_body(sheet: Sheet, direction: int, frame: int) -> None:
    ox, oy = cell_origin(direction, frame)
    step = (0, 1, 0, -1)[frame]
    bob = abs(step)
    facing = DIRECTIONS[direction]

    # Legs alternate by one pixel; the whole torso bobs on passing frames.
    sheet.rect(ox + 25 + step, oy + 42 + bob, 6, 12, OUTLINE)
    sheet.rect(ox + 26 + step, oy + 42 + bob, 4, 11, SKIN_SHADOW)
    sheet.rect(ox + 33 - step, oy + 42 + bob, 6, 12, OUTLINE)
    sheet.rect(ox + 34 - step, oy + 42 + bob, 4, 11, SKIN)

    sheet.rect(ox + 24, oy + 27 + bob, 16, 20, OUTLINE)
    sheet.rect(ox + 26, oy + 28 + bob, 12, 18, SKIN)

    arm_swing = step if facing in ("down", "up") else 0
    sheet.rect(ox + 20, oy + 29 + bob + arm_swing, 5, 15, OUTLINE)
    sheet.rect(ox + 21, oy + 30 + bob + arm_swing, 3, 13, SKIN_SHADOW)
    sheet.rect(ox + 39, oy + 29 + bob - arm_swing, 5, 15, OUTLINE)
    sheet.rect(ox + 40, oy + 30 + bob - arm_swing, 3, 13, SKIN)

    head_x = ox + 32 + (-1 if facing == "left" else 1 if facing == "right" else 0)
    sheet.ellipse(head_x, oy + 20 + bob, 10, 11, OUTLINE)
    sheet.ellipse(head_x, oy + 20 + bob, 8, 9, SKIN)
    if facing == "left":
        sheet.rect(ox + 22, oy + 20 + bob, 3, 3, SKIN)
        sheet.pixel(ox + 27, oy + 19 + bob, OUTLINE)
    elif facing == "right":
        sheet.rect(ox + 40, oy + 20 + bob, 3, 3, SKIN)
        sheet.pixel(ox + 37, oy + 19 + bob, OUTLINE)
    elif facing == "down":
        sheet.pixel(ox + 28, oy + 19 + bob, OUTLINE)
        sheet.pixel(ox + 36, oy + 19 + bob, OUTLINE)


def draw_outfit(sheet: Sheet, direction: int, frame: int) -> None:
    ox, oy = cell_origin(direction, frame)
    step = (0, 1, 0, -1)[frame]
    bob = abs(step)
    facing = DIRECTIONS[direction]

    sheet.rect(ox + 24, oy + 28 + bob, 16, 4, OUTLINE)
    sheet.rect(ox + 25, oy + 29 + bob, 14, 13, OUTFIT)
    sheet.rect(ox + 25, oy + 39 + bob, 14, 4, OUTFIT_LIGHT)
    sheet.rect(ox + 24, oy + 37 + bob, 16, 3, BELT)
    sheet.pixel(ox + 31, oy + 38 + bob, OUTLINE)
    sheet.pixel(ox + 32, oy + 38 + bob, OUTLINE)
    if facing == "up":
        sheet.rect(ox + 29, oy + 30 + bob, 6, 8, OUTFIT_LIGHT)
    elif facing == "left":
        sheet.rect(ox + 25, oy + 30 + bob, 3, 8, OUTFIT_LIGHT)
    elif facing == "right":
        sheet.rect(ox + 36, oy + 30 + bob, 3, 8, OUTFIT_LIGHT)


def draw_hair(sheet: Sheet, direction: int, frame: int) -> None:
    ox, oy = cell_origin(direction, frame)
    step = (0, 1, 0, -1)[frame]
    bob = abs(step)
    facing = DIRECTIONS[direction]
    head_x = ox + 32 + (-1 if facing == "left" else 1 if facing == "right" else 0)

    sheet.ellipse(head_x, oy + 14 + bob, 10, 7, HAIR)
    sheet.rect(head_x - 10, oy + 14 + bob, 20, 5, HAIR)
    if facing == "down":
        sheet.rect(ox + 22, oy + 16 + bob, 4, 10, HAIR)
        sheet.rect(ox + 38, oy + 16 + bob, 4, 10, HAIR)
        sheet.rect(ox + 25, oy + 11 + bob, 7, 3, HAIR_LIGHT)
    elif facing == "up":
        sheet.ellipse(ox + 32, oy + 20 + bob, 9, 10, HAIR)
        sheet.rect(ox + 25, oy + 11 + bob, 8, 4, HAIR_LIGHT)
    elif facing == "left":
        sheet.rect(ox + 35, oy + 15 + bob, 6, 13, HAIR)
        sheet.rect(ox + 24, oy + 11 + bob, 7, 3, HAIR_LIGHT)
    else:
        sheet.rect(ox + 23, oy + 15 + bob, 6, 13, HAIR)
        sheet.rect(ox + 33, oy + 11 + bob, 7, 3, HAIR_LIGHT)


def generate(name: str, draw) -> None:
    sheet = Sheet()
    for direction in range(len(DIRECTIONS)):
        for frame in range(FRAMES):
            draw(sheet, direction, frame)
    sheet.write_png(OUTPUT_DIR / f"{name}.png")


if __name__ == "__main__":
    generate("base_body", draw_body)
    generate("outfit", draw_outfit)
    generate("hair", draw_hair)
