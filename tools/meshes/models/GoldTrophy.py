"""Golden trophy cup on a marble base, front facing -Y. About 2.1 studs tall."""

import math


def build(lib):
    Look = lib.Look
    gold = lib.GOLD
    marble = Look("Marble", (40, 40, 52), "Marble", roughness=0.25)
    ruby = Look("Ruby", (220, 30, 60), "Glass", roughness=0.05, reflectance=0.3)
    plate = Look("Plate", (235, 225, 190), "Metal", metallic=0.8, roughness=0.3)

    # Two-step marble base with a gold band and name plate
    lib.box(marble, (1.0, 1.0, 0.24), pos=(0, 0, 0.12), bevel=0.04, bevel_segments=3)
    lib.box(gold, (1.03, 1.03, 0.04), pos=(0, 0, 0.25), bevel=0.01)
    lib.box(marble, (0.78, 0.78, 0.2), pos=(0, 0, 0.37), bevel=0.04, bevel_segments=3)
    lib.box(plate, (0.46, 0.02, 0.12), pos=(0, -0.395, 0.37), bevel=0.008)
    lib.box(gold, (0.5, 0.015, 0.16), pos=(0, -0.391, 0.37), bevel=0.004)

    # Stem and cup turned on a lathe: (radius, height) from bottom to the rim and back down inside
    profile = [
        (0.24, 0.47), (0.22, 0.5), (0.12, 0.56), (0.08, 0.62), (0.07, 0.72), (0.13, 0.77), (0.14, 0.8),
        (0.13, 0.83), (0.07, 0.88), (0.065, 0.97), (0.1, 1.02), (0.2, 1.06), (0.34, 1.13), (0.45, 1.27),
        (0.52, 1.45), (0.55, 1.65), (0.57, 1.82), (0.61, 1.9), (0.62, 1.94), (0.6, 1.96), (0.57, 1.95),
        (0.53, 1.85), (0.51, 1.65), (0.48, 1.45), (0.41, 1.3), (0.3, 1.2), (0.0, 1.17),
    ]
    lib.lathe(gold, profile, segments=56)
    # Decorative ring around the cup
    lib.torus(gold, 0.555, 0.02, pos=(0, 0, 1.62), major_seg=56, minor_seg=8)

    # Curly handles on both sides
    for side in (-1, 1):
        pts = [(side * 0.52, 0, 1.78), (side * 0.78, 0, 1.86), (side * 0.9, 0, 1.68),
               (side * 0.8, 0, 1.42), (side * 0.6, 0, 1.3), (side * 0.47, 0, 1.33)]
        lib.tube(gold, pts, 0.04, resolution=10)
        lib.sphere(gold, 0.055, pos=(side * 0.47, 0, 1.33), segments=16, rings=10)

    # Ruby set in a gold star on the front of the cup
    star = []
    for k in range(10):
        r = 0.16 if k % 2 == 0 else 0.07
        a = math.pi / 2 + k * math.pi / 5
        star.append((r * math.cos(a), r * math.sin(a)))
    lib.slab(gold, star, 0.04, pos=(0, -0.515, 1.52), rot=(90 - 14, 0, 0), bevel=0.01, sharp=True)
    lib.gem(ruby, 0.06, pos=(0, -0.55, 1.52), rot=(90 - 14, 0, 0), facets=8)
