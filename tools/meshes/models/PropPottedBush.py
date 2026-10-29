"""Shop prop: round topiary bush in a marble pot, beside the front door. Origin: bottom center."""

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    gold = lib.GOLD
    leaf = Look("Leaf", (95, 195, 85), "Grass", roughness=0.8)
    dark_leaf = Look("DarkLeaf", (60, 150, 65), "Grass", roughness=0.8)

    # Square planter with gold trim
    lib.box(marble, (2.0, 2.0, 1.5), pos=(0, 0, 0.75), bevel=0.08, bevel_segments=3)
    lib.box(marble, (2.2, 2.2, 0.18), pos=(0, 0, 1.6), bevel=0.05, bevel_segments=2)
    lib.box(gold, (2.24, 2.24, 0.06), pos=(0, 0, 1.68), bevel=0.02)
    lib.box(gold, (2.04, 2.04, 0.06), pos=(0, 0, 0.18), bevel=0.02)

    # Bushy ball made of a few lumpy clumps
    lib.blob(leaf, 1.25, pos=(0, 0, 2.9), seed=2.0, lumps=0.18, detail=0.12, subdivisions=4)
    for (x, y, z), s in (((0.6, -0.5, 3.4), 0.6), ((-0.7, -0.3, 2.6), 0.55), ((0.2, 0.7, 3.5), 0.55),
                         ((-0.3, -0.6, 3.7), 0.5)):
        lib.blob(dark_leaf, s, pos=(x, y, z), seed=x * 5 + y, lumps=0.2, detail=0.15, subdivisions=3)
