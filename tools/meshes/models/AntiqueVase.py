"""Blue-and-white porcelain vase with gold trim, front facing -Y. About 2.1 studs tall."""

import math


def build(lib):
    Look = lib.Look
    porcelain = Look("Porcelain", (245, 245, 250), roughness=0.15, reflectance=0.05)
    blue = Look("Blue", (40, 80, 180), roughness=0.2)
    gold = lib.GOLD

    # Vase body turned on a lathe: foot, round belly, slim neck, flared lip
    profile = [(0.0, 0.0), (0.3, 0.0), (0.32, 0.04), (0.3, 0.12), (0.36, 0.2), (0.5, 0.4), (0.62, 0.65),
               (0.64, 0.85), (0.58, 1.08), (0.42, 1.28), (0.26, 1.42), (0.22, 1.55), (0.23, 1.7),
               (0.3, 1.88), (0.38, 2.0), (0.39, 2.04), (0.35, 2.04), (0.28, 1.92), (0.2, 1.75), (0.18, 1.5),
               (0.0, 1.45)]
    lib.lathe(porcelain, profile, segments=64)

    # Blue painted bands (thin shells hugging the body)
    def band(z0, z1, push=0.008):
        pts = [(r + push, z) for r, z in profile if z0 <= z <= z1]
        lib.lathe(blue, pts, segments=64, cap_bottom=False)
    band(0.0, 0.2)
    band(1.42, 1.56)
    band(1.88, 2.04)

    # Gold rings at the shoulder and lip
    lib.torus(gold, 0.6, 0.02, pos=(0, 0, 1.1), major_seg=64, minor_seg=8)
    lib.torus(gold, 0.38, 0.018, pos=(0, 0, 2.03), major_seg=64, minor_seg=8)
    lib.torus(gold, 0.31, 0.016, pos=(0, 0, 0.04), major_seg=64, minor_seg=8)

    # Blue flowers painted around the belly: a center dot and five petals
    for k in range(6):
        a = 2 * math.pi * k / 6 - math.pi / 2
        r, z = 0.645, 0.78
        c, s = math.cos(a), math.sin(a)
        deg = math.degrees(a) + 90
        lib.cylinder(blue, 0.05, 0.02, pos=(r * c, r * s, z), rot=(90, 0, deg), verts=16, bevel=0)
        for p in range(5):
            pa = 2 * math.pi * p / 5
            px, pz = 0.09 * math.cos(pa), 0.09 * math.sin(pa)
            lib.sphere(blue, 0.05, pos=((r - 0.01) * c - px * s, (r - 0.01) * s + px * c, z + pz),
                       scale=(1.0, 1.0, 1.0), segments=10, rings=6)
        # Leafy vine between the flowers
        a2 = a + math.pi / 6
        lib.tube(blue, [(0.63 * math.cos(a2 - 0.25), 0.63 * math.sin(a2 - 0.25), 0.65),
                        (0.645 * math.cos(a2), 0.645 * math.sin(a2), 0.82),
                        (0.63 * math.cos(a2 + 0.25), 0.63 * math.sin(a2 + 0.25), 0.68)], 0.012)

    # Two little handles on the neck
    for side in (-1, 1):
        lib.tube(gold, [(side * 0.24, 0, 1.75), (side * 0.38, 0, 1.72), (side * 0.4, 0, 1.55),
                        (side * 0.3, 0, 1.42)], 0.025)
