"""Shop interior details: wood wall panels, rugs, guitar wall, paintings, boxes, ceiling light and
crown molding. Same coordinates as PropShopExterior (origin: shop center at ground level; the room
is x -19..19, z -16..32). The banner stays a part because it carries text."""

import math

KEEP_ORIGIN = True
SIDES = (-1, 1)


def guitar(lib, look, x, y0, z):
    """A wall-mounted acoustic guitar facing -Z, its bottom at Roblox height y0."""
    rosewood = lib.Look("Rosewood", (55, 35, 28), "Wood", roughness=0.6)
    half = [(0.0, 0.0), (0.9, 0.1), (1.25, 0.6), (1.2, 1.4), (0.95, 1.9), (1.0, 2.3), (1.05, 2.9),
            (0.85, 3.4), (0.35, 3.6)]
    outline = [(0.0, 0.0)] + half[1:] + [(0.0, 3.62)] + [(-px, py) for px, py in reversed(half[1:])]
    lib.slab(look, outline, 0.5, pos=(-x, z, y0), rot=(90, 0, 0), bevel=0.08, resolution=4)
    lib.cylinder(lib.DARK, 0.42, 0.04, pos=(-x, z - 0.26, y0 + 2.45), rot=(90, 0, 0), verts=24, bevel=0)
    lib.torus(lib.WHITE, 0.5, 0.03, pos=(-x, z - 0.27, y0 + 2.45), rot=(90, 0, 0), major_seg=24, minor_seg=6)
    lib.box(rosewood, (0.6, 0.12, 0.2), pos=(-x, z - 0.27, y0 + 0.9), bevel=0.03)
    lib.box(rosewood, (0.38, 0.22, 3.1), pos=(-x, z + 0.05, y0 + 5.1), bevel=0.04)
    head = [(-0.25, 0.0), (0.25, 0.0), (0.32, 0.5), (0.3, 0.95), (0.0, 1.05), (-0.3, 0.95), (-0.32, 0.5)]
    lib.slab(rosewood, head, 0.18, pos=(-x, z + 0.05, y0 + 6.62), rot=(90, 0, 0), bevel=0.04, resolution=4)
    for k in range(3):
        for side in (-1, 1):
            lib.cylinder(lib.STEEL, 0.05, 0.25, pos=(-x + side * 0.38, z + 0.05, y0 + 6.9 + k * 0.25),
                         rot=(0, 90, 0), verts=8)
    for i in range(6):
        lib.rod(lib.STEEL, (-x - 0.25 + i * 0.1, z - 0.3, y0 + 0.95), (-x - 0.12 + i * 0.05, z - 0.08, y0 + 6.62),
                0.012, verts=4)
    # Wall hook holding the neck
    lib.box(lib.GOLD, (0.5, 0.4, 0.12), pos=(-x, z + 0.25, y0 + 6.45), bevel=0.04)


def build(lib):
    Look = lib.Look
    R, rbox = lib.R, lib.rbox
    wood = Look("DarkWood", (85, 55, 40), "Wood", roughness=0.45)
    wood_light = Look("PanelWood", (110, 72, 50), "Wood", roughness=0.45)
    board = Look("Board", (205, 165, 115), "WoodPlanks", roughness=0.6)
    gold = lib.GOLD
    trim = Look("Trim", (236, 224, 200), roughness=0.6)
    accent_rug = Look("AccentRug", (140, 80, 220), "Fabric", roughness=1.0)
    rug_gold = Look("RugGold", (255, 196, 54), "Fabric", roughness=1.0)
    rug_cream = Look("RugCream", (250, 240, 220), "Fabric", roughness=1.0)
    glow = Look("Glow", (255, 225, 160), "Neon", emission=5)
    cardboard = Look("Cardboard", (196, 152, 100), "Cardboard", roughness=0.9)
    tape = Look("Tape", (225, 190, 130), roughness=0.4)

    def panels(length, skip=None):
        """Centers and widths of raised panels along a wall `length` long (centered on 0)."""
        n = int(length // 3.2)
        for k in range(n):
            a = -length / 2 + (k + 0.5) * length / n
            if skip and skip[0] < a < skip[1]:
                continue
            yield a, length / n

    # Dark wood panels along the lower walls: frame, raised panels, gold rail, baseboard
    rbox(wood, (38, 4, 0.2), (0, 3, 31.9), bevel=0.02)
    rbox(gold, (38, 0.3, 0.4), (0, 5.15, 31.8), bevel=0.12, bevel_segments=3)
    rbox(wood, (38, 0.5, 0.35), (0, 1.25, 31.82), bevel=0.08)
    for a, w in panels(38, skip=(-8, 8)):  # the middle is behind the back wall shelf
        rbox(wood_light, (w - 0.7, 2.4, 0.12), (a, 3.1, 31.76), bevel=0.06, bevel_segments=2)
    for s in SIDES:
        rbox(wood, (0.2, 4, 48), (s * 18.9, 3, 8), bevel=0.02)
        rbox(gold, (0.4, 0.3, 48), (s * 18.8, 5.15, 8), bevel=0.12, bevel_segments=3)
        rbox(wood, (0.35, 0.5, 48), (s * 18.82, 1.25, 8), bevel=0.08)
        for a, w in panels(48, skip=(-22, -6)):  # skip behind the front wall shelves (z -13.5..1.5)
            rbox(wood_light, (0.12, 2.4, w - 0.7), (s * 18.76, 3.1, 8 + a), bevel=0.06, bevel_segments=2)

    # Crown molding where the walls meet the ceiling
    rbox(trim, (38, 0.6, 0.6), (0, 16.5, 31.7), bevel=0.2, bevel_segments=3)
    rbox(trim, (38, 0.6, 0.6), (0, 16.5, -15.7), bevel=0.2, bevel_segments=3)
    for s in SIDES:
        rbox(trim, (0.6, 0.6, 48), (s * 18.7, 16.5, 8), bevel=0.2, bevel_segments=3)

    # Rug from the door to the checkout: gold border, cream line, colored field, center medallion
    rbox(rug_gold, (10.8, 0.08, 14.8), (0, 1.09, -7), bevel=0.03)
    rbox(rug_cream, (10.2, 0.1, 14.2), (0, 1.1, -7), bevel=0.02)
    rbox(accent_rug, (9.8, 0.12, 13.8), (0, 1.11, -7), bevel=0.02)
    lib.slab(rug_gold, [(0, -2.0), (1.4, 0), (0, 2.0), (-1.4, 0)], 0.04, pos=R(0, 1.18, -7), bevel=0.0,
             sharp=True)
    lib.slab(rug_cream, [(0, -1.4), (0.95, 0), (0, 1.4), (-0.95, 0)], 0.04, pos=R(0, 1.2, -7), bevel=0.0,
             sharp=True)
    for z in (-13, -1):
        rbox(rug_gold, (6, 0.04, 0.3), (0, 1.18, z), bevel=0)
    for x in (-5.3, -3.5, -1.7, 0.1, 1.9, 3.7, 5.3):  # fringe at both ends
        for z in (-14.55, 0.55):
            rbox(rug_cream, (0.12, 0.04, 0.5), (x, 1.07, z), bevel=0)

    # Runner rug in the back area, between the back glass cases
    rbox(rug_gold, (6.4, 0.08, 10.4), (0, 1.09, 23.5), bevel=0.03)
    rbox(accent_rug, (5.8, 0.1, 9.8), (0, 1.1, 23.5), bevel=0.02)

    # Ceiling light over the checkout
    rbox(gold, (4.4, 0.25, 4.4), (0, 16.72, 10), bevel=0.08)
    rbox(glow, (3.8, 0.2, 3.8), (0, 16.62, 10), bevel=0.05)

    # Guitar wall on the back wall (left): planked board with a frame and three guitars
    rbox(board, (9, 6, 0.2), (-13.5, 8, 31.7), bevel=0.03)
    for x in (-16.5, -14.5, -12.5, -10.5):
        rbox(Look("PlankLine", (170, 130, 85)), (0.06, 6, 0.05), (x, 8, 31.58), bevel=0)
    for y in (4.9, 11.1):
        rbox(wood, (9.4, 0.25, 0.35), (-13.5, y, 31.65), bevel=0.06)
    for x in (-18.1, -8.9):
        rbox(wood, (0.25, 6.4, 0.35), (x, 8, 31.65), bevel=0.06)
    colors = (Look("GuitarRed", (220, 60, 60), roughness=0.2), Look("GuitarBlue", (60, 120, 230), roughness=0.2),
              Look("GuitarOrange", (240, 160, 50), roughness=0.2))
    for look, gx in zip(colors, (-16.3, -13.5, -10.7)):
        guitar(lib, look, gx, 5.3, 31.25)

    # Rod for the "WE BUY GOLD" banner (the banner itself is a part) in the middle of the back wall
    lib.rod(gold, R(-5.3, 16.45, 31.75), R(5.3, 16.45, 31.75), 0.06)
    for x in (-5.4, 5.4):
        lib.sphere(gold, 0.16, pos=R(x, 16.45, 31.75), segments=12, rings=8)

    # Paintings above the front wall shelves (one per side wall, facing into the room)
    skies = (Look("SkyBlue", (120, 190, 240)), Look("SkyOrange", (240, 170, 110)))
    hills = Look("Hills", (95, 195, 85))
    for s, sky in zip(SIDES, skies):
        x = s * 18.8
        for z in (-8.5, -3.5):
            rbox(gold, (0.3, 3.6, 0.3), (x, 13.2, z), bevel=0.1, bevel_segments=2)
        for y in (11.4, 15.0):
            rbox(gold, (0.3, 0.3, 5.3), (x, y, -6), bevel=0.1, bevel_segments=2)
        rbox(sky, (0.1, 3.3, 4.8), (x - s * 0.05, 13.2, -6), bevel=0)
        lib.slab(hills, [(-2.4, 0), (2.4, 0), (2.4, 0.9), (1.2, 1.4), (0.2, 0.8), (-1.0, 1.5), (-2.4, 0.8)], 0.06,
                 pos=R(x - s * 0.12, 11.55, -6), rot=(90, 0, 90), bevel=0)
        lib.cylinder(Look("Sun", (255, 235, 130)), 0.4, 0.06, pos=R(x - s * 0.12, 14.1, -5.0), rot=(0, 90, 0),
                     verts=24, bevel=0)

    # Stacked cardboard boxes in the back-right corner, with tape
    for size, pos, turn in (((2.6, 2.2, 2.6), (16.8, 2.1, 30.3), 0), ((2.0, 1.6, 2.0), (16.6, 4.0, 30.2), 15),
                            ((2.2, 1.8, 2.2), (17.0, 1.9, 27.4), -10)):
        sx, sy, sz = size
        x, y, z = pos
        lib.box(cardboard, (sx, sz, sy), pos=R(x, y, z), rot=lib.rturn(turn), bevel=0.06)
        lib.box(tape, (0.35, sz + 0.02, 0.02), pos=R(x, y + sy / 2, z), rot=lib.rturn(turn), bevel=0)
