"""Diamond ring in an open velvet box, front facing -Y. About 1.4 studs tall."""

import math


def build(lib):
    Look = lib.Look
    velvet = Look("Velvet", (150, 20, 45), "Fabric", roughness=0.9)
    satin = Look("Satin", (245, 240, 235), "Fabric", roughness=0.5)
    gold = lib.GOLD
    diamond = Look("Diamond", (215, 245, 255), "Glass", roughness=0.0, transparency=0.15, reflectance=0.4)

    # Box base with a gold trim and a satin cushion that holds the ring
    lib.box(velvet, (0.9, 0.9, 0.5), pos=(0, 0, 0.25), bevel=0.1, bevel_segments=4)
    lib.box(gold, (0.92, 0.92, 0.04), pos=(0, 0, 0.5), bevel=0.01)
    lib.box(satin, (0.74, 0.74, 0.08), pos=(0, 0, 0.5), bevel=0.04, bevel_segments=3)
    lib.box(velvet, (0.72, 0.12, 0.08), pos=(0, 0.06, 0.56), bevel=0.04, bevel_segments=3)
    lib.box(velvet, (0.72, 0.12, 0.08), pos=(0, -0.08, 0.56), bevel=0.04, bevel_segments=3)

    # Lid swung open at the back, with satin lining facing forward
    lid_y, lid_z = 0.46, 0.5
    lib.box(velvet, (0.9, 0.16, 0.9), pos=(0, lid_y + 0.02, lid_z + 0.45), rot=(-12, 0, 0), bevel=0.08, bevel_segments=4)
    lib.box(satin, (0.74, 0.02, 0.74), pos=(0, lid_y - 0.07, lid_z + 0.45), rot=(-12, 0, 0), bevel=0.01)
    lib.box(gold, (0.92, 0.04, 0.04), pos=(0, lid_y - 0.03, lid_z + 0.02), bevel=0.01)

    # Ring standing in the slot: gold band, four prongs and a big diamond
    rz = 0.78
    lib.torus(gold, 0.17, 0.03, pos=(0, -0.01, rz), rot=(0, 90, 0), major_seg=48, minor_seg=12)
    top = rz + 0.2
    lib.lathe(gold, [(0.0, 0.0), (0.05, 0.0), (0.08, 0.06), (0.0, 0.06)], pos=(0, -0.01, top - 0.04), segments=24)
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        lib.rod(gold, (0.04 * math.cos(a), -0.01 + 0.04 * math.sin(a), top - 0.02),
                (0.1 * math.cos(a), -0.01 + 0.1 * math.sin(a), top + 0.12), 0.012, verts=8)
    lib.gem(diamond, 0.13, pos=(0, -0.01, top + 0.12), rot=(180, 0, 0), facets=12, height=1.0)
    # Two small side stones
    for side in (-1, 1):
        lib.gem(diamond, 0.04, pos=(0, -0.01 + side * 0.09, top + 0.0), rot=(180 - side * 30, 0, 0), facets=8)
