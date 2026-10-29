"""Town prop: marble fountain with a gold bowl (the water spray is added in the game).
Origin: bottom center."""

import math

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    gold = Look("Gold", (255, 196, 54), "Metal", metallic=1.0, roughness=0.2, reflectance=0.2)
    water = Look("Water", (80, 180, 255), "Glass", roughness=0.0, transparency=0.3, reflectance=0.1)

    # Round basin with a thick rounded rim, hollow inside
    basin = [(0.0, 0.0), (7.8, 0.0), (8.0, 0.15), (8.0, 1.65), (8.15, 1.8), (8.1, 2.05), (7.8, 2.15),
             (7.45, 2.05), (7.35, 1.8), (7.35, 0.4), (0.0, 0.4)]
    lib.lathe(marble, basin, segments=96)
    lib.torus(gold, 7.7, 0.08, pos=(0, 0, 2.15), major_seg=96, minor_seg=8)
    lib.cylinder(water, 7.36, 0.2, pos=(0, 0, 1.7), verts=96, bevel=0)
    # Panels around the outside of the basin
    for k in range(16):
        a = 2 * math.pi * k / 16
        lib.box(marble, (0.4, 0.2, 1.2), pos=(8.05 * math.cos(a), 8.05 * math.sin(a), 0.9),
                rot=(0, 0, math.degrees(a) + 90), bevel=0.06)

    # Center column turned on a lathe, with the gold bowl on top
    column = [(0.0, 0.4), (1.5, 0.4), (1.5, 0.8), (1.2, 1.0), (0.9, 1.6), (0.8, 3.0), (0.9, 3.6), (1.2, 4.0),
              (1.1, 4.3), (0.6, 4.6), (0.5, 5.4), (0.7, 5.8), (0.0, 5.8)]
    lib.lathe(marble, column, segments=48)
    bowl = [(0.0, 5.7), (0.7, 5.75), (1.6, 5.9), (2.6, 6.3), (3.1, 6.75), (3.15, 6.95), (2.95, 7.0),
            (2.5, 6.75), (1.5, 6.5), (0.0, 6.45)]
    lib.lathe(gold, bowl, segments=64)
    lib.cylinder(water, 2.7, 0.15, pos=(0, 0, 6.8), verts=64, bevel=0)
    for k in range(8):
        a = 2 * math.pi * k / 8
        lib.sphere(gold, 0.14, pos=(3.12 * math.cos(a), 3.12 * math.sin(a), 6.75), segments=12, rings=8)
    lib.lathe(gold, [(0.0, 0.0), (0.35, 0.0), (0.2, 0.5), (0.12, 0.8), (0.0, 0.85)], pos=(0, 0, 6.5), segments=24)
