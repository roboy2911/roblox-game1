"""Royal crown on a velvet cushion, front facing -Y. About 1.5 studs tall."""

import math


def build(lib):
    Look = lib.Look
    gold = lib.GOLD
    velvet = Look("Velvet", (160, 20, 45), "Fabric", roughness=0.9)
    cushion = Look("Cushion", (110, 25, 120), "Fabric", roughness=0.9)
    ermine = Look("Ermine", (248, 246, 240), "Fabric", roughness=1.0)
    spots = Look("Spots", (25, 25, 30), "Fabric", roughness=1.0)
    pearl = Look("Pearl", (250, 245, 235), "SmoothPlastic", roughness=0.15, reflectance=0.1)
    gems = [
        Look("Ruby", (220, 30, 60), "Glass", roughness=0.05, reflectance=0.3),
        Look("Sapphire", (40, 90, 230), "Glass", roughness=0.05, reflectance=0.3),
        Look("Emerald", (30, 190, 100), "Glass", roughness=0.05, reflectance=0.3),
    ]

    # Puffy cushion with gold tassels
    lib.box(cushion, (1.5, 1.5, 0.3), pos=(0, 0, 0.15), bevel=0.12, bevel_segments=5)
    for x in (-0.7, 0.7):
        for y in (-0.7, 0.7):
            lib.sphere(gold, 0.06, pos=(x, y, 0.2), segments=12, rings=8)
            lib.lathe(gold, [(0.0, 0.0), (0.05, 0.02), (0.035, 0.14), (0.0, 0.16)],
                      pos=(x * 1.05, y * 1.05, 0.02), segments=12)

    base = 0.3  # crown sits on top of the cushion
    # Fur trim at the bottom, with black ermine spots
    lib.torus(ermine, 0.62, 0.08, pos=(0, 0, base + 0.06), major_seg=48, minor_seg=12)
    for k in range(12):
        a = 2 * math.pi * k / 12
        lib.sphere(spots, 0.022, pos=(0.7 * math.cos(a), 0.7 * math.sin(a), base + 0.08), segments=8, rings=6)

    # Gold band (a thick ring)
    band = [(0.58, base + 0.1), (0.63, base + 0.1), (0.64, base + 0.42), (0.6, base + 0.44), (0.57, base + 0.42)]
    lib.lathe(gold, band, closed=True, segments=64)
    lib.torus(gold, 0.635, 0.018, pos=(0, 0, base + 0.42), major_seg=64, minor_seg=8)

    # Velvet cap inside
    lib.sphere(velvet, 0.56, pos=(0, 0, base + 0.42), scale=(1, 1, 0.75))

    # Pointed leaves around the top, with a pearl on each tip; gems in between on the band
    leaf = [(-0.11, 0.0), (0.11, 0.0), (0.08, 0.12), (0.0, 0.3), (-0.08, 0.12)]
    for k in range(8):
        a = 2 * math.pi * k / 8
        deg = math.degrees(a)
        c, s = math.cos(a), math.sin(a)
        lib.slab(gold, leaf, 0.04, pos=(0.61 * c, 0.61 * s, base + 0.42), rot=(90, 0, deg + 90), bevel=0.012)
        lib.sphere(pearl, 0.04, pos=(0.61 * c, 0.61 * s, base + 0.75), segments=12, rings=8)
        a2 = a + math.pi / 8
        c2, s2 = math.cos(a2), math.sin(a2)
        lib.gem(gems[k % 3], 0.065, pos=(0.645 * c2, 0.645 * s2, base + 0.26),
                rot=(90, 0, math.degrees(a2) + 90), facets=8)

    # Four arches meeting at the top, lined with pearls
    for k in range(4):
        a = 2 * math.pi * k / 4 + math.pi / 4
        c, s = math.cos(a), math.sin(a)
        pts = [(0.6 * c, 0.6 * s, base + 0.44), (0.56 * c, 0.56 * s, base + 0.72),
               (0.36 * c, 0.36 * s, base + 0.95), (0.0, 0.0, base + 1.0)]
        lib.tube(gold, pts, 0.035, resolution=10)
        for t, (r, z) in enumerate([(0.585, 0.6), (0.5, 0.84), (0.3, 0.97)]):
            lib.sphere(pearl, 0.03, pos=(r * c, r * s, base + z + 0.03), segments=10, rings=6)

    # Orb and cross on top
    lib.sphere(gold, 0.1, pos=(0, 0, base + 1.07))
    lib.box(gold, (0.05, 0.05, 0.24), pos=(0, 0, base + 1.27), bevel=0.01)
    lib.box(gold, (0.16, 0.05, 0.05), pos=(0, 0, base + 1.3), bevel=0.01)
