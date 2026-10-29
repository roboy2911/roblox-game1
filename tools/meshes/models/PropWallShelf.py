"""Wall shelf unit with three levels, its back against the wall and the open front facing -Y.
Origin: bottom center. Shelf levels are 2.7, 5.4 and 8.1 studs up.
Parts named "Accent" take the shop's own color."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    rbox = lib.rbox
    white = Look("White", (250, 250, 250), roughness=0.4)
    trim = Look("Trim", (236, 224, 200), roughness=0.5)
    gold = lib.GOLD
    accent = Look("Accent", (140, 80, 220), roughness=0.35)

    # Back, sides with rounded front edges, crown on top, colored plinth
    rbox(white, (14, 9.4, 0.4), (0, 4.7, 1.6), bevel=0.05)
    for x in (-7.2, 7.2):
        rbox(white, (0.4, 9.4, 3.2), (x, 4.7, 0), bevel=0.12, bevel_segments=2)
        rbox(trim, (0.5, 9.0, 0.15), (x, 4.7, -1.55), bevel=0.06)
    rbox(white, (14.8, 0.4, 3.4), (0, 9.6, 0), bevel=0.1, bevel_segments=2)
    rbox(trim, (15.2, 0.35, 3.6), (0, 9.95, -0.05), bevel=0.15, bevel_segments=3)
    rbox(gold, (15.0, 0.12, 0.15), (0, 9.4, -1.72), bevel=0.04)
    rbox(accent, (14.4, 0.6, 3.2), (0, 0.3, 0), bevel=0.08, bevel_segments=2)
    rbox(gold, (14.5, 0.12, 0.15), (0, 0.62, -1.55), bevel=0.04)

    # Three shelf levels with gold lips and little gold brackets
    for level in (1, 2, 3):
        y = level * 2.7
        rbox(white, (14, 0.3, 2.8), (0, y, 0), bevel=0.06)
        rbox(gold, (14, 0.35, 0.15), (0, y + 0.1, -1.45), bevel=0.06)
        for x in (-4.6, 0, 4.6):
            lib.slab(gold, [(0.0, 0.0), (1.2, 0.0), (0.0, -0.8)], 0.12, pos=lib.R(x, y - 0.15, 1.4),
                     rot=(90, 0, -90), bevel=0.03, sharp=True)
