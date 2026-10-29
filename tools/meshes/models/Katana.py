"""Katana and its scabbard on a two-tier wooden stand, blade along X, front -Y. About 1.4 studs tall."""

import math


def build(lib):
    Look = lib.Look
    stand = Look("Stand", (60, 30, 25), "Wood", roughness=0.35, reflectance=0.05)
    steel = Look("Blade", (215, 220, 230), "Metal", metallic=1.0, roughness=0.12, reflectance=0.35)
    gold = lib.GOLD
    wrap = Look("Wrap", (35, 35, 45), "Fabric", roughness=0.9)
    skin = Look("Ray", (240, 235, 220), roughness=0.6)
    saya = Look("Scabbard", (25, 20, 22), roughness=0.1, reflectance=0.1)

    # Stand: base and two curved uprights with notches for the sword and scabbard
    lib.box(stand, (3.0, 0.6, 0.14), pos=(0, 0, 0.07), bevel=0.04, bevel_segments=3)
    upright = [(-0.16, 0.0), (0.16, 0.0), (0.12, 0.45), (0.2, 0.55), (0.2, 0.62), (0.08, 0.6), (0.06, 0.9),
               (0.16, 1.02), (0.16, 1.1), (0.04, 1.08), (-0.1, 1.0), (-0.12, 0.5)]
    for x in (-0.95, 0.95):
        lib.slab(stand, upright, 0.18, pos=(x, 0, 0.14), rot=(90, 0, 90), bevel=0.03)

    # Scabbard on the lower tier
    z1 = 0.76
    lib.box(saya, (2.5, 0.09, 0.14), pos=(0.15, -0.04, z1), bevel=0.04, bevel_segments=3)
    lib.box(gold, (0.06, 0.1, 0.15), pos=(1.42, -0.04, z1), bevel=0.02)
    lib.box(gold, (0.05, 0.1, 0.15), pos=(-1.08, -0.04, z1), bevel=0.02)

    # Sword on the upper tier: curved blade with a sharp tip
    z2 = 1.24
    pts = []
    n = 12
    for k in range(n + 1):
        t = k / n
        x = -0.75 + 2.3 * t
        curve = 0.06 * math.sin(math.pi * t * 0.9)
        pts.append((x, curve + 0.03))
    tip = (1.62, 0.07)
    back = [(x, y - 0.11 + 0.02 * (i / n)) for i, (x, y) in enumerate(pts)]
    outline = [p for p in back] + [tip] + list(reversed(pts))
    lib.slab(steel, outline, 0.035, pos=(0, -0.04, z2 - 0.04), rot=(90, 0, 0), bevel=0.008, sharp=True)
    # Collar, guard, grip with diamond wrap, and end cap
    lib.box(gold, (0.06, 0.06, 0.13), pos=(-0.78, -0.04, z2 + 0.0), bevel=0.012)
    lib.cylinder(gold, 0.16, 0.035, pos=(-0.83, -0.04, z2), rot=(0, 90, 0), verts=32, bevel=0.01)
    lib.cylinder(skin, 0.055, 0.68, pos=(-1.2, -0.04, z2), rot=(0, 90, 0), verts=16, bevel=0.01)
    for k in range(7):
        x = -0.9 - k * 0.09
        lib.box(wrap, (0.06, 0.12, 0.12), pos=(x, -0.04, z2), rot=(45, 0, 0), bevel=0.02)
    lib.lathe(gold, [(0.06, 0.0), (0.06, 0.05), (0.03, 0.07), (0.0, 0.07)], pos=(-1.54, -0.04, z2),
              rot=(0, -90, 0), segments=16)
