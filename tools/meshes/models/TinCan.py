"""Old tin can with its lid half open, front facing -Y. About 1.2 studs tall."""

import math


def build(lib):
    Look = lib.Look
    tin = Look("Tin", (175, 180, 190), "Metal", metallic=1.0, roughness=0.35, reflectance=0.1)
    label = Look("Label", (205, 50, 50), roughness=0.6)
    stripe = Look("Stripe", (250, 235, 200), roughness=0.6)
    rust = Look("Rust", (140, 75, 40), "CorrodedMetal", roughness=0.9)

    # Can with rolled rims and ridges
    r = 0.4
    profile = [(0.0, 0.0), (r - 0.02, 0.0), (r + 0.015, 0.03), (r, 0.07)]
    for k in range(6):
        z = 0.1 + k * 0.17
        profile += [(r, z), (r - 0.012, z + 0.04), (r, z + 0.08)]
    profile += [(r, 1.06), (r + 0.015, 1.09), (r - 0.02, 1.11), (r - 0.04, 1.08), (0.0, 1.07)]
    lib.lathe(tin, profile, segments=48)

    # Paper label with a cream stripe, slightly torn at the front
    lib.lathe(label, [(r + 0.01, 0.22), (r + 0.01, 0.88)], segments=48, cap_bottom=False)
    lib.lathe(stripe, [(r + 0.014, 0.5), (r + 0.014, 0.62)], segments=48, cap_bottom=False)

    # Lid bent up on its hinge, with a jagged edge
    lid = []
    for k in range(24):
        a = 2 * math.pi * k / 24
        rr = (r - 0.03) * (0.96 if k % 2 else 1.0)
        lid.append((rr * math.cos(a), rr * math.sin(a)))
    lib.slab(tin, lid, 0.02, pos=(0, 0.16, 1.4), rot=(-55, 0, 0), bevel=0.005, sharp=True)

    # A few rust spots
    for x, z, a in ((0.2, 0.15, 30), (-0.3, 0.95, 140), (0.05, 0.98, 75)):
        c, s = math.cos(math.radians(a)), math.sin(math.radians(a))
        lib.sphere(rust, 0.06, pos=(r * c, -r * s, z), scale=(1.0, 1.0, 0.6), segments=12, rings=8)
