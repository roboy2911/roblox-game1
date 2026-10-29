"""Shop prop: leafy indoor plant in a marble pot with a gold rim. Origin: bottom center."""

import math
import random

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    marble = Look("Marble", (240, 240, 245), "Marble", roughness=0.25)
    gold = lib.GOLD
    soil = Look("Soil", (70, 50, 35), roughness=1.0)
    leaf = Look("Leaf", (95, 195, 85), "Grass", roughness=0.7)
    dark_leaf = Look("DarkLeaf", (60, 150, 65), "Grass", roughness=0.7)
    stem = Look("Stem", (80, 120, 50), roughness=0.7)

    lib.lathe(marble, [(0.0, 0.0), (0.6, 0.0), (0.65, 0.1), (0.75, 1.4), (0.85, 1.6), (0.85, 1.72),
                       (0.78, 1.72), (0.7, 1.55), (0.0, 1.55)], segments=48)
    lib.torus(gold, 0.84, 0.05, pos=(0, 0, 1.68), major_seg=48, minor_seg=8)
    lib.torus(gold, 0.66, 0.04, pos=(0, 0, 0.2), major_seg=48, minor_seg=8)
    lib.cylinder(soil, 0.74, 0.05, pos=(0, 0, 1.6), verts=32, bevel=0)

    # Long leaves arching out of the pot in every direction
    random.seed(11)
    blade = [(0.0, 0.0), (0.18, 0.4), (0.2, 0.9), (0.1, 1.3), (0.0, 1.45), (-0.1, 1.3), (-0.2, 0.9), (-0.18, 0.4)]
    for k in range(22):
        a = 2 * math.pi * k / 22 + random.uniform(-0.15, 0.15)
        lean = random.uniform(8, 32)
        length = random.uniform(2.0, 3.0)
        look = leaf if k % 2 else dark_leaf
        outline = [(x * length / 1.8, y * length / 1.45) for x, y in blade]
        r = 0.15 + lean / 200
        lib.slab(look, outline, 0.04, pos=(r * math.cos(a), r * math.sin(a), 1.6),
                 rot=(90 - lean, 0, math.degrees(a) - 90), bevel=0.012, resolution=4)
    for k in range(5):
        a = 2 * math.pi * k / 5
        lib.tube(stem, [(0, 0, 1.6), (0.2 * math.cos(a), 0.2 * math.sin(a), 2.4),
                        (0.4 * math.cos(a), 0.4 * math.sin(a), 3.0)], 0.03)
        lib.blob(dark_leaf, 0.35, pos=(0.45 * math.cos(a), 0.45 * math.sin(a), 3.2), seed=k * 1.3,
                 scale=(1.0, 1.0, 0.7), subdivisions=2)
