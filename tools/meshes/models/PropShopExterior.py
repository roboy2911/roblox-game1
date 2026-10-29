"""Shop building: floor, walls, roof, storefront (windows, doors, pillars, awnings, sign frame).
Written in the shop's own Roblox coordinates (see ShopBuilder.luau): X -20..20, Z -17 (front) .. 17,
floor top at Y = 1. Origin: the shop's center at ground level.
Parts named "Accent..." take each shop's own color. The sign text, OPEN sign, lanterns, pawn balls
and bushes are separate (parts / other props)."""

import math

KEEP_ORIGIN = True
SIDES = (-1, 1)


def build(lib):
    Look = lib.Look
    R, rbox, rcolumn = lib.R, lib.rbox, lib.rcolumn
    cream = Look("Wall", (250, 240, 220), roughness=0.7)
    trim = Look("Trim", (236, 224, 200), roughness=0.6)
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    dark_marble = Look("DarkMarble", (45, 45, 60), "Marble", roughness=0.25)
    gold = lib.GOLD
    roof = Look("Roof", (70, 65, 90), "Slate", roughness=0.8)
    glass = Look("Glass", (190, 230, 255), "Glass", roughness=0.0, transparency=0.55, reflectance=0.15)
    accent = Look("Accent", (140, 80, 220), roughness=0.4)
    accent_neon = Look("AccentNeon", (140, 80, 220), "Neon", emission=4)
    stripe = Look("Stripe", (255, 255, 255), "Fabric", roughness=0.9)
    accent_fabric = Look("AccentFabric", (140, 80, 220), "Fabric", roughness=0.9)

    # Floor with checkered tiles and a gold inlay line around the room
    rbox(marble, (40, 1, 34), (0, 0.5, 0), bevel=0.04)
    for ix in range(10):
        for iz in range(8):
            if (ix + iz) % 2 == 0:
                rbox(dark_marble, (3.9, 0.06, 3.9), (-18 + ix * 4, 1.02, -14 + iz * 4), bevel=0.02)
    for z in (-15.9, 15.4):
        rbox(gold, (38, 0.04, 0.15), (0, 1.03, z), bevel=0)
    for s in SIDES:
        rbox(gold, (0.15, 0.04, 31.4), (s * 18.9, 1.03, -0.25), bevel=0)

    # Walls, with a raised base, corner pilasters and a cornice along the top outside
    # Back wall with a doorway (x 1..5) into the back room
    rbox(cream, (21, 16, 1), (-9.5, 9, 16.5), bevel=0.05)
    rbox(cream, (15, 16, 1), (12.5, 9, 16.5), bevel=0.05)
    rbox(cream, (4, 7.5, 1), (3, 13.25, 16.5), bevel=0.05)
    for s in SIDES:
        rbox(cream, (1, 16, 34), (s * 19.5, 9, 0), bevel=0.05)
        rbox(accent, (0.3, 1.2, 34), (s * 20.15, 0.8, 0), bevel=0.06)
        rbox(trim, (1.4, 16.4, 1.4), (s * 19.8, 9.2, 16.8), bevel=0.1)
        rbox(gold, (1.2, 0.4, 34), (s * 19.6, 18.2, 0), bevel=0.12, bevel_segments=3)
        rbox(trim, (0.5, 0.5, 34.6), (s * 20.15, 17.3, 0), bevel=0.15, bevel_segments=3)
    # Colored base strip along the back, except where the back room attaches (x -8..14)
    rbox(accent, (12.3, 1.2, 0.3), (-14.15, 0.8, 17.15), bevel=0.06)
    rbox(accent, (6.3, 1.2, 0.3), (17.15, 0.8, 17.15), bevel=0.06)
    rbox(gold, (40, 0.4, 1.2), (0, 18.2, 16.4), bevel=0.12, bevel_segments=3)
    rbox(trim, (41, 0.5, 0.5), (0, 17.3, 17.15), bevel=0.15, bevel_segments=3)

    # Front wall: doorway in the middle, a big window on each side
    for s in SIDES:
        rbox(cream, (3, 16, 1), (s * 5.5, 9, -16.5), bevel=0.05)
        rbox(cream, (4, 16, 1), (s * 18, 9, -16.5), bevel=0.05)
        rbox(cream, (9, 2.5, 1), (s * 11.5, 2.25, -16.5), bevel=0.05)
        rbox(cream, (9, 5.5, 1), (s * 11.5, 14.25, -16.5), bevel=0.05)
        rbox(accent, (16, 1.2, 0.3), (s * 12, 0.8, -17.15), bevel=0.06)

        # Window: glass, gold frame with rounded edges, cross bars, marble sill, keystone
        cx = s * 11.5
        rbox(glass, (9, 8, 0.2), (cx, 7.5, -16.5), bevel=0.0)
        rbox(gold, (9.6, 0.4, 0.4), (cx, 3.5, -17.2), bevel=0.12, bevel_segments=3)
        rbox(gold, (9.6, 0.4, 0.4), (cx, 11.5, -17.2), bevel=0.12, bevel_segments=3)
        rbox(gold, (0.4, 8.4, 0.4), (s * 7, 7.5, -17.2), bevel=0.12, bevel_segments=3)
        rbox(gold, (0.4, 8.4, 0.4), (s * 16, 7.5, -17.2), bevel=0.12, bevel_segments=3)
        rbox(gold, (0.25, 8, 0.2), (cx, 7.5, -16.7), bevel=0.06)
        rbox(gold, (9, 0.2, 0.2), (cx, 8.3, -16.7), bevel=0.06)
        rbox(gold, (9.2, 0.3, 0.3), (cx, 3.6, -16.1), bevel=0.08)  # inside frame
        rbox(marble, (10, 0.4, 1.2), (cx, 3.2, -17.5), bevel=0.1, bevel_segments=2)
        rbox(marble, (10.3, 0.15, 1.3), (cx, 2.95, -17.5), bevel=0.05)
        key = [(-0.5, 0.0), (0.5, 0.0), (0.35, 1.1), (-0.35, 1.1)]
        lib.slab(gold, key, 0.3, pos=(-cx, -17.3, 11.7), rot=(90, 0, 0), bevel=0.05, sharp=True)

        # Striped awning: curved stripes sloping down to the street, with a scalloped edge
        top = [(-16.95, 12.85), (-18.0, 12.75), (-19.3, 12.2), (-20.6, 11.05)]
        band = top + [(z, y - 0.16) for z, y in reversed(top)]
        for i in range(1, 11):
            x = cx + (i - 5.5)
            look = accent_fabric if i % 2 == 0 else stripe
            lib.slab(look, band, 1.0, pos=(-x, 0, 0), rot=(90, 0, 90), bevel=0.01, resolution=3)
            scallop = [(0.5, 0.0), (0.35, -0.3), (0.0, -0.42), (-0.35, -0.3), (-0.5, 0.0), (-0.5, 0.35),
                       (0.5, 0.35)]
            lib.slab(look, scallop, 0.08, pos=(-x, -20.66, 10.95), rot=(90, 0, 0), bevel=0.01, resolution=3)
        lib.rod(gold, R(cx - 5.1, 10.95, -20.75), R(cx + 5.1, 10.95, -20.75), 0.07)
        for sx in (-5.05, 5.05):
            lib.rod(gold, R(cx + sx, 12.6, -17.1), R(cx + sx, 11.0, -20.7), 0.05)

    # Doorway: gold frame with rounded edges and two glass doors swung open
    rbox(cream, (8, 6, 1), (0, 14, -16.5), bevel=0.05)
    for s in SIDES:
        rbox(gold, (0.6, 10, 1.4), (s * 3.7, 6, -16.5), bevel=0.15, bevel_segments=3)
        rbox(glass, (0.2, 9.0, 3.2), (s * 3.15, 5.7, -14.3), bevel=0.0)
        for z in (-15.85, -12.75):
            rbox(gold, (0.35, 9.2, 0.3), (s * 3.15, 5.7, z), bevel=0.08)
        for y in (1.2, 10.2):
            rbox(gold, (0.35, 0.3, 3.4), (s * 3.15, y, -14.3), bevel=0.08)
        rbox(gold, (0.12, 2.0, 0.12), (s * 2.85, 5.7, -13.2), bevel=0.04)
        rbox(gold, (0.12, 2.0, 0.12), (s * 3.45, 5.7, -13.2), bevel=0.04)
    rbox(gold, (8, 0.6, 1.4), (0, 10.7, -16.5), bevel=0.15, bevel_segments=3)
    lib.slab(gold, [(-1.2, 0.0), (1.2, 0.0), (0.9, 0.5), (0.0, 0.8), (-0.9, 0.5)], 0.3,
             pos=(0, -17.25, 11.0), rot=(90, 0, 0), bevel=0.06)
    rbox(marble, (8, 0.3, 1), (0, 0.85, -17.5), bevel=0.08)
    rbox(marble, (6, 0.5, 5), (0, 0.45, -20.5), bevel=0.1, bevel_segments=2)
    for z in (-19.2, -20.5, -21.8):
        rbox(dark_marble, (5.6, 0.04, 0.08), (0, 0.71, z), bevel=0)

    # Marble pillars: square base, faceted (fluted-look) shaft, gold capital
    for x in (-19.5, -5.5, 5.5, 19.5):
        rbox(marble, (2.3, 0.5, 2.3), (x, 0.45, -17.6), bevel=0.08, bevel_segments=2)
        rbox(marble, (2.0, 0.4, 2.0), (x, 0.9, -17.6), bevel=0.1, bevel_segments=2)
        shaft = [(0.0, 1.1), (0.95, 1.1), (0.85, 1.4), (0.8, 2.0), (0.76, 9.0), (0.72, 15.6), (0.85, 15.8),
                 (0.0, 15.8)]
        lib.lathe(marble, shaft, pos=R(x, 0, -17.6), segments=20, smooth=False)
        cap = [(0.0, 15.8), (0.8, 15.8), (0.95, 16.0), (1.15, 16.25), (0.0, 16.25)]
        lib.lathe(gold, cap, pos=R(x, 0, -17.6), segments=32)
        rbox(gold, (2.3, 0.45, 2.3), (x, 16.5, -17.6), bevel=0.1, bevel_segments=2)
        rbox(gold, (2.0, 0.3, 2.0), (x, 16.85, -17.6), bevel=0.08)

    # Parapet above the roof line with the sign frame, dentils and a neon strip
    rbox(accent, (40, 5, 1), (0, 19.5, -16.5), bevel=0.06)
    rbox(gold, (40.6, 0.5, 1.6), (0, 22.25, -16.5), bevel=0.15, bevel_segments=3)
    for k in range(40):
        rbox(gold, (0.45, 0.3, 0.3), (-19.5 + k, 21.85, -17.1), bevel=0.04)
    for y in (21.7, 17.3):
        rbox(gold, (24.8, 0.4, 0.6), (0, y, -17.3), bevel=0.12, bevel_segments=3)
    for x in (-12.2, 12.2):
        rbox(gold, (0.4, 4.8, 0.6), (x, 19.5, -17.3), bevel=0.12, bevel_segments=3)
        for y in (17.3, 21.7):
            lib.sphere(gold, 0.42, pos=R(x, y, -17.55), segments=16, rings=10)
    rbox(accent_neon, (24, 0.3, 0.3), (0, 16.6, -17.15), bevel=0.08)

    # Ceiling and roof with a slight overhang and gold edge
    rbox(cream, (38, 0.2, 32), (0, 16.9, 0), bevel=0.0)
    rbox(roof, (40.4, 1, 34.4), (0, 17.5, 0), bevel=0.15, bevel_segments=2)
    for x in (-10, 10):
        rbox(roof, (3, 1.2, 2), (x, 18.6, 10), bevel=0.2, bevel_segments=2)  # roof vents
        rbox(lib.STEEL, (2.4, 0.2, 1.4), (x, 19.25, 10), bevel=0.05)
