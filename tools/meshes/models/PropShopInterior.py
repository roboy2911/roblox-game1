"""Shop interior details: wood wall panels, rug, guitar wall, office door, paintings, boxes,
ceiling light and crown molding. Same coordinates as PropShopExterior (origin: shop center at
ground level). The banner and door sign stay as parts because they carry text."""

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

    # Dark wood panels along the lower walls: frame, raised panels, gold rail, baseboard
    def wainscot_run(length, place):
        """place(along, out) -> Roblox position; along runs the wall, out comes into the room."""
        n = int(length // 3.2)
        for k in range(n):
            a = -length / 2 + (k + 0.5) * length / n
            yield a, length / n, place

    rbox(wood, (38, 4, 0.2), (0, 3, 15.9), bevel=0.02)
    rbox(gold, (38, 0.3, 0.4), (0, 5.15, 15.8), bevel=0.12, bevel_segments=3)
    rbox(wood, (38, 0.5, 0.35), (0, 1.25, 15.82), bevel=0.08)
    for a, w, _ in wainscot_run(38, None):
        rbox(wood_light, (w - 0.7, 2.4, 0.12), (a, 3.1, 15.76), bevel=0.06, bevel_segments=2)
    for s in SIDES:
        rbox(wood, (0.2, 4, 32), (s * 18.9, 3, 0), bevel=0.02)
        rbox(gold, (0.4, 0.3, 32), (s * 18.8, 5.15, 0), bevel=0.12, bevel_segments=3)
        rbox(wood, (0.35, 0.5, 32), (s * 18.82, 1.25, 0), bevel=0.08)
        for a, w, _ in wainscot_run(32, None):
            if -13.5 < a < 1.5:
                continue  # hidden behind the wall shelves
            rbox(wood_light, (0.12, 2.4, w - 0.7), (s * 18.76, 3.1, a), bevel=0.06, bevel_segments=2)

    # Crown molding where the walls meet the ceiling
    rbox(trim, (38, 0.6, 0.6), (0, 16.5, 15.7), bevel=0.2, bevel_segments=3)
    rbox(trim, (38, 0.6, 0.6), (0, 16.5, -15.7), bevel=0.2, bevel_segments=3)
    for s in SIDES:
        rbox(trim, (0.6, 0.6, 32), (s * 18.7, 16.5, 0), bevel=0.2, bevel_segments=3)

    # Rug from the door to the counter: gold border, cream line, colored field, center medallion
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

    # Ceiling light over the back of the shop
    rbox(gold, (4.4, 0.25, 4.4), (0, 16.72, 10), bevel=0.08)
    rbox(glow, (3.8, 0.2, 3.8), (0, 16.62, 10), bevel=0.05)

    # Guitar wall: planked board with a frame, three guitars, a rod for the banner above
    rbox(board, (10, 6, 0.2), (-10, 8, 15.7), bevel=0.03)
    for x in (-14.4, -12.2, -10, -7.8, -5.6):
        rbox(Look("PlankLine", (170, 130, 85)), (0.06, 6, 0.05), (x + 1.1, 8, 15.58), bevel=0)
    for y in (4.9, 11.1):
        rbox(wood, (10.4, 0.25, 0.35), (-10, y, 15.65), bevel=0.06)
    for x in (-15.1, -4.9):
        rbox(wood, (0.25, 6.4, 0.35), (x, 8, 15.65), bevel=0.06)
    colors = (Look("GuitarRed", (220, 60, 60), roughness=0.2), Look("GuitarBlue", (60, 120, 230), roughness=0.2),
              Look("GuitarOrange", (240, 160, 50), roughness=0.2))
    for look, gx in zip(colors, (-13, -10, -7)):
        guitar(lib, look, gx, 5.3, 15.25)
    lib.rod(gold, R(-15.3, 16.0, 15.75), R(-4.7, 16.0, 15.75), 0.06)
    for x in (-15.4, -4.6):
        lib.sphere(gold, 0.16, pos=R(x, 16.0, 15.75), segments=12, rings=8)

    # Staff-only office door: gold frame with molding, paneled wood door, knob and kick plate
    for x in (0.85, 5.15):
        rbox(gold, (0.35, 8.8, 0.35), (x, 5.4, 15.75), bevel=0.1, bevel_segments=2)
    rbox(gold, (4.65, 0.4, 0.35), (3, 9.7, 15.75), bevel=0.1, bevel_segments=2)
    lib.slab(gold, [(-0.9, 0.0), (0.9, 0.0), (0.6, 0.35), (0.0, 0.55), (-0.6, 0.35)], 0.2,
             pos=R(3, 9.9, 15.7), rot=(90, 0, 0), bevel=0.04)
    rbox(wood, (4, 8.2, 0.3), (3, 5.1, 15.5), bevel=0.05)
    for y in (3.0, 7.0):
        for x in (2.05, 3.95):
            rbox(wood_light, (1.4, 3.0 if y == 3.0 else 2.4, 0.12), (x, y, 15.32), bevel=0.06, bevel_segments=2)
    lib.sphere(gold, 0.2, pos=R(4.5, 5.0, 15.25), segments=16, rings=10)
    rbox(gold, (0.25, 0.6, 0.06), (4.5, 5.0, 15.33), bevel=0.03)
    rbox(gold, (3.6, 0.6, 0.06), (3, 1.4, 15.33), bevel=0.02)

    # Paintings above the shelves (one per side wall, facing into the room)
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

    # Stacked cardboard boxes in the back-left corner, with tape
    for size, pos, turn in (((2.6, 2.2, 2.6), (-16.8, 2.1, 14.3), 0), ((2.0, 1.6, 2.0), (-16.6, 4.0, 14.2), 15),
                            ((2.2, 1.8, 2.2), (-17.0, 1.9, 11.4), -10)):
        sx, sy, sz = size
        x, y, z = pos
        lib.box(cardboard, (sx, sz, sy), pos=R(x, y, z), rot=lib.rturn(turn), bevel=0.06)
        lib.box(tape, (0.35, sz + 0.02, 0.02), pos=R(x, y + sy / 2, z), rot=lib.rturn(turn), bevel=0)
