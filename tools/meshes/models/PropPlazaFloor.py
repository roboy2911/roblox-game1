"""Town piece: the plaza around the fountain: 60 x 40 marble paving with rings and a gold circle.
Origin: bottom center (the fountain's center). Floor top is 0.7 up."""

import math

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    R, rbox = lib.R, lib.rbox
    plaza = Look("Plaza", (235, 228, 215), "Marble", roughness=0.4)
    stone = Look("Stone", (215, 205, 190), "Marble", roughness=0.4)
    dark = Look("StoneDark", (180, 168, 150), "Marble", roughness=0.4)
    gold = lib.GOLD

    rbox(plaza, (60, 0.7, 40), (0, 0.35, 0), bevel=0.08)
    # Rings of paving around the fountain, with a gold circle
    for r0, r1, look in ((8.6, 9.6, dark), (9.6, 10.9, stone), (10.9, 11.05, gold), (11.05, 12.2, stone),
                         (13.6, 14.2, dark)):
        lib.lathe(look, [(r0, 0.0), (r1, 0.0), (r1, 0.04), (r0, 0.04)], pos=R(0, 0.7, 0), segments=96,
                  closed=True, smooth=False)
    # Spokes between the rings and a border of darker stone
    for k in range(16):
        a = 2 * math.pi * k / 16
        lib.box(dark, (0.25, 1.8, 0.04), pos=(12.9 * math.cos(a), 12.9 * math.sin(a), 0.72),
                rot=(0, 0, math.degrees(a) + 90), bevel=0.0)
    for s in (-1, 1):
        rbox(dark, (60, 0.04, 1.2), (0, 0.72, s * 19.2), bevel=0.0)
        rbox(dark, (1.2, 0.04, 37.2), (s * 29.2, 0.72, 0), bevel=0.0)
    for x in range(-26, 27, 4):
        for s in (-1, 1):
            rbox(stone, (3.8, 0.03, 3.8), (x, 0.715, s * 16.4), bevel=0.0)
