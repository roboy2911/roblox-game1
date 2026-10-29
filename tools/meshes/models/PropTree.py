"""Town prop: round leafy tree. Origin: bottom of the trunk."""

import math

KEEP_ORIGIN = True


def build(lib):
    Look = lib.Look
    bark = Look("Bark", (115, 80, 55), "Wood", roughness=0.9)
    leaf = Look("Leaf", (95, 195, 85), "Grass", roughness=0.8)
    dark_leaf = Look("DarkLeaf", (60, 150, 65), "Grass", roughness=0.8)

    # Trunk that flares at the roots and splits into branches
    lib.lathe(bark, [(0.0, 0.0), (0.95, 0.0), (0.7, 0.25), (0.55, 0.8), (0.5, 3.0), (0.45, 5.0), (0.0, 5.2)],
              segments=12)
    for x, y, z in ((1.6, 0.4, 6.4), (-1.4, -0.6, 6.6), (0.2, 1.4, 7.0), (0.1, -1.2, 6.8)):
        lib.tube(bark, [(0, 0, 4.4), (x * 0.5, y * 0.5, 5.4), (x, y, z)], 0.22, resolution=4)
    for k in range(4):

        a = math.pi / 4 + k * math.pi / 2
        lib.tube(bark, [(0.4 * math.cos(a), 0.4 * math.sin(a), 0.6), (0.9 * math.cos(a), 0.9 * math.sin(a), 0.08),
                        (1.2 * math.cos(a), 1.2 * math.sin(a), 0.0)], 0.16, resolution=4)

    # Leafy crown made of lumpy clumps
    lib.blob(leaf, 3.0, pos=(0, 0, 7.6), seed=1.0, lumps=0.2, detail=0.1, subdivisions=3)
    for (x, y, z), r, look in (((1.9, 0.8, 6.4), 2.1, dark_leaf), ((-1.8, -0.9, 6.6), 2.0, leaf),
                               ((0.3, 1.8, 8.6), 1.8, dark_leaf), ((-0.6, -1.5, 8.9), 1.7, dark_leaf),
                               ((0.8, -0.6, 9.8), 1.5, leaf)):
        lib.blob(look, r, pos=(x, y, z), seed=x + 2 * y, lumps=0.22, detail=0.1, subdivisions=3)
